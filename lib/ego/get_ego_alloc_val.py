#!/usr/bin/env python

import sys
import json

def csv2json(_fp, _key):
  ''' TODO: speicify user-defined name as primary key'''
  #the columns are on the first line separated by ;
  columns = _fp.readline().strip('\n').replace('"', '').split(",")
  objs = {}
  rows = _fp.readlines()
  for row in rows:
    fields = row.strip('\n').replace('"', '').split(",")
    obj = {}
    for column in columns:
      obj[column] = fields[columns.index(column)]
      objs[fields[columns.index(_key)]] = obj
  
  return json.dumps(objs)

if __name__ == "__main__":
  ''' TODO: handle multiple lines of same alloc id or same client name '''
  csv_file = sys.argv[1]
  primary_key = sys.argv[2] # content format is key,val
  name = sys.argv[3]

  fp = open(csv_file, 'r')
  dkey = primary_key.replace('"', '').split(',')
  dobj =  csv2json(fp, dkey[0])
  print "{0}:{1}".format(name, json.loads(dobj)[dkey[1]][name])

