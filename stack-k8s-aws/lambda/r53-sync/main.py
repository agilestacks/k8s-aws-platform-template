#
# This lambda provides backbone for etcd clustering using
# DNS discovery feature. For more information see:
#
# https://coreos.com/etcd/docs/latest/clustering.html#dns-discovery
#
import os, sys

script_dir = os.path.dirname( os.path.realpath(__file__) )
sys.path.insert(0, script_dir + os.sep + "lib")

import pprint, json, boto3, jsonschema, botocore, pystache
import common as c

import logging
log = logging.getLogger()
log.setLevel(logging.INFO)

# import logging as log
# log.basicConfig(level=log.DEBUG, format='%(levelname)s: %(message)s')

event_schema = {
  'type' : 'object',
  'properties' : {
    'Records' : {
      'type' : 'array',
      'required': True,
      'minItems': 1,
      'items': {
        'type': 'object',
        'properties': {
          'EventSource': {
            'type': 'string',
            'required': True
          },
          'Sns': {
            'type': 'object',
            'required': True,
            'properties': {
              'Message': {
                'type': 'string',
                'required': True
              },
              'MessageId': {
                'type': 'string',
                'required': True
              }
            }
          }
        }
      }
    }
  }
}

ags_hook_msg_schema = {
  'type' : 'object',
  'properties' : {
    'NotificationMetadata' : {
      'type': 'object',
      'required': True,
      'properties': {
        'HostedZoneId' : {
          'type': 'string',
          'required': True
        },
        'Changes' : {
          'type': 'array',
          'required': True,
          'minItems': 1,
          'items': {
            'type': 'object',
            'properties': {
              'Action': {
                'type': 'string',
                'required': True
              },
              'Name': {
                'type': 'string',
                'required': True
              },
              'Type': {
                'type': 'string',
                'required': True
              },
              'TTL': {
                'type': 'string',
                'required': True
              },
              'Template': {
                'type': 'string',
                'required': True
              }
            }
          }
        }
      }
    },
    'LifecycleHookName' : {
      'type': 'string',
      'required': True
    },
    'AutoScalingGroupName' : {
      'type': 'string',
      'required': True
    },
    'LifecycleActionToken' : {
      'type': 'string',
      'required': True
    }
  }
}

sns_test_msg_schema = {
  'type' : 'object',
  'properties' : {
    'Event' : {
      'type': 'string',
      'required': True
    },
    'AutoScalingGroupName': {
      'type': 'string',
      'required': True
    }
  }
}


desired_wakeup_tags_schema = {
  'type' : 'object',
  'properties' : {
    'DesiredCapacity' : {
      'type': 'string',
      'required': True
    },
    'InitialCapacity': {
      'type': 'string',
      'required': True
    },
    'MinSize' : {
      'type': 'string',
      'required': True
    },
    'MaxSize': {
      'type': 'string',
      'required': True
    }
  }
}

session    = boto3.Session()
ec2_client = session.client('ec2')
r53_client = session.client('route53')
asg_client = session.client('autoscaling')

pp = pprint.PrettyPrinter()

def describe_asg(name):
  resp = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[name])['AutoScalingGroups']
  return resp[0] if len(resp) else []


def asg_running_instances(name):
  running_state = ["InService", "Pending", "Pending:Wait", "Pending:Proceed"]
  healthy = ['Healthy']
  asg = describe_asg(name)
  if 'Instances' not in asg:
    return []

  running = [i for i in asg.get('Instances') if i['LifecycleState'] in running_state and i['HealthStatus'] in healthy]
  if len(running) == 0:
    return []

  running = ec2_client.describe_instances(InstanceIds=[i['InstanceId'] for i in running])
  result = []
  for i in running.get('Reservations', [{}]):
    for j in i.get('Instances', [{}]):
      result.append({
        'InstanceId':       j.get('InstanceId'),
        'InstanceType':     j.get('InstanceType'),
        'PrivateDnsName':   j.get('PrivateDnsName'),
        'PrivateIpAddress': j.get('PrivateIpAddress'),
        'PublicDnsName':    j.get('PublicDnsName'),
        'PublicIpAddress':  j.get('PublicIpAddress')
      })
  return result

def message(payload):
  if 'Records' in payload:
    payload = payload['Records'][0]
  message = payload.get('Sns', {}).get('Message', {})
  if isinstance(message, str):
    message = json.loads(message)
    metadata = message.get('NotificationMetadata', {})
    if isinstance(metadata, str):
      metadata = json.loads(metadata)
      message['NotificationMetadata'] = metadata
  return message

def valid(msg, schema):
  try:
    log.debug('Validating message %s with schema %s', c.jsonify(msg), c.jsonify(schema))
    jsonschema.Draft3Validator(schema).validate(msg)
  except jsonschema.ValidationError as e:
    log.warning("Message is not valid %s", e.message)
    return False
  return True

def r53_resource_records(r53_zone_id, r53_record_name, r53_type='SRV'):
  return r53_client.list_resource_record_sets(
            HostedZoneId=r53_zone_id,
            StartRecordName=r53_record_name,
            StartRecordType=r53_type,
            MaxItems='1'
         )['ResourceRecordSets'][0]['ResourceRecords']

def is_wakeup_message(msg):
  if valid(msg, sns_test_msg_schema) \
     and msg['Event'] == "autoscaling:TEST_NOTIFICATION":
    return True
  return False

def wakeup_asg(asg):
  log.debug('Initializing ASG: %s', pprint.saferepr(asg))
  tags = { i['Key']: i['Value'] for i in asg['Tags']}
  if not valid(tags, desired_wakeup_tags_schema):
    error = "Autoscaling group doesn't contain correct wakeup tags %s ".format(c.jsonify(tags))
    log.error(error)
    raise ValueError(error)

  initial_capacity = int(tags['InitialCapacity'])
  desired_capacity = int(tags['DesiredCapacity'])
  min_size         = int(tags['MinSize'])
  max_size         = int(tags['MaxSize'])

  if (int(asg['MinSize'])         != min_size or \
      int(asg['MaxSize'])         != max_size or \
      int(asg['DesiredCapacity']) != desired_capacity) and \
      int(asg['MaxSize'])         == initial_capacity:
    log.info('Resizing autoscaling group from initial %i to desired %i capacity', initial_capacity, desired_capacity)
    asg_client.update_auto_scaling_group(
      AutoScalingGroupName=asg['AutoScalingGroupName'],
      MinSize=min_size,
      MaxSize=max_size,
      DesiredCapacity=desired_capacity
    )


def handler(event, context):
  log.info("Incoming event: %s", c.jsonify(event))

  if not valid(event, event_schema):
    raise Exception('This lambda expects SNS events however have got unexpected event', event)

  responses = []

  for rec in event['Records']:
    msg    = message(rec)
    msg_id = rec['Sns']['MessageId']

    log.debug("Checking if incoming message is a SNS test notification")
    if is_wakeup_message(msg):
      log.info('This is an ASG wakeup message. %s', c.jsonify(msg))
      asg_name = msg['AutoScalingGroupName']
      asg_obj  = describe_asg(asg_name)
      wakeup_asg(asg_obj)
      # log.info(c.jsonify(asg_obj))
      continue

    log.debug("Checking if incoming message is valid ASG lifecycle hook message with metadata")
    if not valid(msg, ags_hook_msg_schema):
      log.error( "Unexpected incoming message. Payllad: %s", c.jsonify(msg) )
      continue

    metadata        = msg['NotificationMetadata']
    r53_zone_id     = metadata['HostedZoneId']
    # r53_domain      = metadata['r53_hosted_zone_domain']
    asg_name        = msg['AutoScalingGroupName']
    instances       = asg_running_instances(asg_name)

    try:
      resp = asg_client.complete_lifecycle_action(
        LifecycleHookName     = msg['LifecycleHookName'],
        AutoScalingGroupName  = msg['AutoScalingGroupName'],
        LifecycleActionToken  = msg['LifecycleActionToken'],
        LifecycleActionResult = 'CONTINUE'
      )
      responses.append(resp)
      log.debug("Completed ASG scaling event with: %s", resp)
    except botocore.exceptions.ClientError as e:
      log.error("Cannot finish autoscaling group event %s", e.message)

    log.info("Updating hosted zone %s record set", r53_zone_id)

    changes = {
        'Comment': "Updated by AutoScalingGroupsng group: {}".format(asg_name),
        'Changes': [{
          'Action': i['Action'],
          'ResourceRecordSet': {
            'Name': i['Name'],
            'Type': i['Type'],
            'TTL':  int( i['TTL'] ),
            'ResourceRecords':
              [{ 'Value': pystache.render(i['Template'], j)} for j in instances]
          }
        } for i  in metadata['Changes']]}
    log.info(c.jsonify(changes))
    r53_client.change_resource_record_sets(
      HostedZoneId=r53_zone_id,
      ChangeBatch=changes)
    responses.append( {"MessageId": msg_id, "Result": "Dns records {} and {} has been updated"} )

  return {'Responses': responses}
  # return {'Responses': responses}
