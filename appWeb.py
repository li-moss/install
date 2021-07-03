# @Author: Li Yuan Rong
# @Date:   2021-06-26 11:38:36
# @Last Modified by:   Li Yuan Rong
# @Last Modified time: 2021-06-26 11:39:20
from flask import Flask, render_template
from flask_cors import CORS
from flask import make_response

app = Flask(__name__)
CORS(app)

data_dict={}

@app.route('/', methods=['GET', 'POST'])
def index():
   global data_dict
   with open("/etc/hosts", 'r') as file_handle:
        # initialize data
        data_dict={}
        for line in file_handle:
            # add line to list
            if '.home' in line:
                data_dict[line.split()[1].split('.home')[0]] = line.split()[0]

   response = make_response(render_template('index.html', name=data_dict))

#   response.headers['X-Frame-Options'] = 'SAMEORIGIN'
#   response.headers['Access-Control-Allow-Origin'] = '*'
#   response.headers['X-XSS-Protection'] = '1; mode=block'
#   response.headers['Content-Security-Policy'] = frame-ancestors 'self'

   return response
   #return render_template('index.html', name=data_dict)


if __name__ == "__main__":
   app.run(host="0.0.0.0", port=80, threaded=True, debug=True)
