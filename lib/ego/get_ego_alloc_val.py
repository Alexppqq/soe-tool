#!/usr/bin/env python

import sys
import json

def csv2json(_fp, _key):
  ''' TODO: speicify user-defined name as primary key'''
  #the columns are on the first line separated by ;
  columns = _fp.readline().replace('"', '').split(",");
  objs = {}
  rows = _fp.readlines();
  for row in rows:
  	fields = row.replace('"', '').split(",")
  	obj = {}
  	for column in columns:
  		obj[column.replace("\n","")] = fields[columns.index(column)].replace("\n","")	 
  	objs[fields[columns.index(_key)]] = obj
  
  return objs, fields[columns.index(_key)]

def get_value(_cnt, _key_val, _name):
  ''' TODO: implement this function to get value of specified name in specified key'''
  return _cnt[_key_val][_name]

if __name__ == "__main__":
  ''' TODO: handle multiple lines of same alloc id or same client name '''
  csv_file = sys.argv[1]
  primary_key = sys.argv[2]
  name = sys.argv[3]

  fp = open(csv_file, 'r')
  dobj,dval =  csv2json(fp, primary_key)
  val = get_value(dobj, dval, name)
  print "{0}:{1}".format(name, val)

