#!/usr/bin/env python

#
# this test can be executed after infrastructure has been provisioned
# test payloads has been stored in correspoinding directory
#
# TODO: we can migrate to AWS mocks in the future

import os, sys

script_dir = os.path.dirname( os.path.realpath(__file__) )
sys.path.insert(0, script_dir + os.sep + "lib")

import unittest, boto3, json
import main, common, pprint

import logging
log = logging.getLogger()
log.setLevel(logging.INFO)

p = pprint.PrettyPrinter(indent=4)
p.format = common.my_safe_repr

session    = boto3.Session()
r53_client = session.client('route53')

def read_json(file):
  with open( file, 'r') as stream:
    return json.load(stream)

def get_hosted_zone_id(name):
  resp = r53_client.list_hosted_zones_by_name(
      MaxItems=1,
      DNSName=name
    )
  return resp['HostedZoneId']

class SimplisticTest(unittest.TestCase):


  # def test_message_extraction(self):
  #   payload = read_json('payloads/launching1.json')
  #   message = main.message(payload)
  #   self.assertEqual('autoscaling:EC2_INSTANCE_LAUNCHING', 
  #                    message['LifecycleTransition'],
  #                    msg='Test that we can read message attributes')
  #   self.assertEqual('_etcd-server._tcp.small.k8s.akranga.net', 
  #                    message['NotificationMetadata']['etcd_srv_dicsovery_server'],
  #                    msg='Test that we can read message attributes')



  # def test_describe_asg(self):
  #   payload = read_json('payloads/launching1.json')
  #   message = main.message(payload)
  #   name = message['AutoScalingGroupName']
  #   self.assertEqual("master-small-k8s-akranga-net", name)

  #   asg = main.describe_asg(name)
  #   self.assertIsNot(0, len(asg))
  #   self.assertEqual('master-small-k8s-akranga-net', asg['LaunchConfigurationName'])


  # def test_asg_running_instances(self):
  #   payload = read_json('payloads/launching1.json')
  #   message = main.message(payload)

  #   name = message['AutoScalingGroupName']

  #   i = main.asg_running_instances(name)
  #   log.info("ASG running instances are:", i)
  #   self.assertIsNot(0, len(i))
  #   self.assertIsNotNone(i[0]['InstanceId'])

  # def test_validation(self):
  #   msg = {}
  #   self.assertFalse( main.valid( msg ) )
  #   msg = {'Records': []}
  #   self.assertFalse( main.valid( msg ) )
  #   msg = {'Records': [{'EventSource': 'Sns'}]}
  #   self.assertFalse( main.valid( msg ) )
  #   msg = {'Records': [
  #           {'EventSource': 'Sns', 
  #             'Sns': {}
  #           }]}
  #   self.assertFalse( main.valid( msg ) )
  #   msg = {'Records': [
  #           {'EventSource': 'Sns', 
  #            'Sns': {'Message': 'iamstring'}
  #           }]}
  #   self.assertTrue(  msg )

  # def test_etcd_srv_dicsovery_server_srv(self):
  #   instances = [{ 'PrivateDnsName': 'private-lorem', 
  #                  'PublicDnsName': 'public-lorem' },
  #                { 'PrivateDnsName': 'private-ipsum', 
  #                  'PublicDnsName': 'public-ipsum' }]
  #   srv_records = main.etcd_srv_dicsovery_server_srv(instances)
  #   self.assertItemsEqual([{'Value' : '0 0 2380 private-lorem'}, 
  #                          {'Value' : '0 0 2380 private-ipsum'}], srv_records)

  # def test_etcd_srv_dicsovery_client_srv(self):
  #   instances = [{ 'PrivateDnsName': 'private-lorem', 
  #                  'PublicDnsName': 'public-lorem' },
  #                { 'PrivateDnsName': 'private-ipsum', 
  #                  'PublicDnsName': 'public-ipsum' }]
  #   srv_records = main.etcd_srv_dicsovery_client_srv(instances)
  #   self.assertItemsEqual([{'Value' : '0 0 2379 private-lorem'}, 
  #                          {'Value' : '0 0 2379 private-ipsum'}], srv_records)

  # def test_handler(self):
  #   payload = read_json('payloads/terminating1.json')
  #   main.handler(payload, {})
  #   self.assertTrue(True)

  # def test_sns_wakeup_message(self):
  #   payload = read_json('payloads/sns-test.json')
  #   main.handler(payload, {})
  #   self.assertTrue(True)



if __name__ == '__main__':
  unittest.main()

