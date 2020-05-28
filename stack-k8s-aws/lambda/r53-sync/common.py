import os, sys

script_dir = os.path.dirname( os.path.realpath(__file__) )
sys.path.insert(0, script_dir + os.sep + "lib")

import json

def jsonify(object):
  return json.dumps(object,
                    sort_keys=True,
                    indent=4,
                    separators=(',', ': '))

def merge(doc1, doc2):
  if isinstance(doc1,dict) and isinstance(doc2,dict):
    for k,v in doc2.iteritems():
      if k not in doc1:
        doc1[k] = v
      elif isinstance(doc1[k],list) and isinstance(v,list):
        doc1[k] = doc1[k] + v
      else:
        doc1[k] = merge(doc1[k],v)
  return doc1