#Author: Xin Yu Pan (panxiny@cn.ibm.com)
#Brief: send HTTP request with GET/PUT/POST/DELETE method and get the response body with JSON format only
#

import requests
from requests.auth import HTTPBasicAuth
import argparse
import json
import base64

class Client(object):
  def __init__(self, _uri, _method, _name, _user, _passwd):
    self.s = requests.session()
    self.uri = _uri
    self.method = _method
    self.name = _name
    self.user = _user
    self.passwd = _passwd

  def url_auth(self):
    auth_uri = "http://{0}:{1}/platform/rest/ego/auth/logon".format(url, port)
    headers = {'Authorization': 'Basic {0}'.format(base64.b64encode(self.user))}
    r = self.s.get(auth_uri, auth=HTTPBasicAuth(self.user, self.passwd))
    if r.status_code != 200:
      print r.json
      exit(-1)

  def url_get(self):
    url_auth()
    headers = {'Accept': 'application/json'}
    r = self.s.get(url, header=headers)
    if r.status_code != 200:
       print r.json
       exit(-1)

    return r.json

if __name__ == '__main__':
  argparser = argparse.ArgumentParser(description='''
      DESCRIPTION: to send HTTP request with GET/PUT/POST/DELETE method and get HTTP response with JSON format
  ''')
  argparser.add_argument('-r', '--url', help='hostname or ip address', default='localhost')
  argparser.add_argument('-p', '--port', help='port number', default='8080')
  argparser.add_argument('-a', '--path', help='URI path', default='')
  argparser.add_argument('-m', '--method', help='URI method: GET, PUT, POST, DELETE', default='')
  argparser.add_argument('-n', '--name', help='EGO REST name: consumer, service', default='')
  argparser.add_argument('-u', '--username', help='user name', default='Admin')
  argparser.add_argument('-x', '--password', help='password', default='Admin')
  args = argparser.parse_args()

  url = args.url
  port = args.port
  path = args.path
  method = args.method
  name = args.name
  user = args.username
  passwd = args.password

  uri = "http://{0}:{1}/platform/rest/ego/{2}/{3}".format(url, port, name, path)
  client = Client(uri, method, name, user, passwd)
  print client.url_get()
