from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return '''
    <html>
        <head>
            <title>practice app</title>
        </head>
        <body>
            <h1>practice app</h1>
            <p>Built by Github Actions, deployed by Argo CD.</p>
            <p>Secured by DevSecOps Pipeline!</p>
        <body>
    </html>
    '''
@app.route('/healthz')
def health():
    return 'ok', 200

if __name)) == '__main__'
    app.run(host='0.0.0.0', port=8080)
