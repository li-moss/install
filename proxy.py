# @Author: Li Yuan Rong
# @Date:   2021-06-26 11:38:36
# @Last Modified by:   Li Yuan Rong
# @Last Modified time: 2021-06-26 11:39:20
from flask import Flask, request, render_template, Response, url_for, stream_with_context
from flask_cors import CORS
from requests import get, post
import requests

app = Flask(__name__)
CORS(app)

data_dict={}
proxy_url=''

@app.route('/', methods=['GET', 'POST'])
def index():
   global data_dict
   global proxy_url
   proxy_url = ''
   with open("/etc/hosts", 'r') as file_handle:
        # initialize data
        data_dict={}
        for line in file_handle:
            # add line to list
            if '.home' in line:
                data_dict[line.split()[1].split('.home')[0]] = line.split()[0]

   return render_template('proxy.html', name=data_dict)

@app.route('/<path:path>', methods=['GET', 'POST'])
def proxy(path):
  global proxy_url
  if proxy_url == '':
    proxy_url = 'http://' + path + '/'

  if request.method == 'GET':
    if path=='stream':
      req = requests.get(f'{proxy_url}{path}', stream = True)
      return Response(stream_with_context(req.iter_content(chunk_size=1024)), content_type = req.headers['content-type'])
    else:
      return get(f'{proxy_url}{path}').content
  if request.method == 'POST':
    encoded_data = request.data.decode('utf-8')
    return post(f'{proxy_url}{path}', data=encoded_data.encode('utf-8')).content

if __name__ == "__main__":
   app.run(host="0.0.0.0", port=80, debug=True)
