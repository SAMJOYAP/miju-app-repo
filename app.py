from flask import Flask, request, render_template_string
import sqlite3
import os
import subprocess

app = Flask(__name__)

# 취약점 1: SQL Injection
@app.route('/user/<username>')
def get_user(username):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    # SQL Injection 취약점 (파라미터화되지 않은 쿼리)
    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)
    user = cursor.fetchone()
    conn.close()
    return str(user) if user else "User not found"

# 취약점 2: Command Injection
@app.route('/ping')
def ping():
    host = request.args.get('host', 'localhost')
    # Command Injection 취약점
    try:
        result = subprocess.check_output(f'ping -c 1 {host}', shell=True)
        return result.decode()
    except:
        return "Ping failed"

# 취약점 3: XSS (Cross-Site Scripting)
@app.route('/search')
def search():
    query = request.args.get('q', '')
    # XSS 취약점 (사용자 입력을 이스케이프하지 않음)
    template = f'<h1>Search Results for: {query}<h1>'
    return render_template_string(template)

# 취약점 4: Hardcoded Secrets
SECRET_KEY = 'hardcoded-secret-key-12345'
API_KEY = 'sk-1234567890abcdef'
AWS_ACCESS_KEY = 'AKIAIOSFODNN7EXAMPLE'
AWS_SECRET_KEY = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'

# 취약점 5: Path Traversal
@app.route('/file')
def read_file():
    filename = request.args.get('name', 'default.txt')
    # Path Traversal 취약점
    try:
        with open(f'/app/data/{filename}', 'r') as f:
            return f.read()
    except:
        return "File not found"

# 취약점 6: Insecure Deserialization
import pickle
@app.route('/deserialize', methods=['POST'])
def deserialize():
    data = request.get_data()
    # Insecure Deserialization 취약점
    try:
        obj = pickle.loads(data)
        return str(obj)
    except:
        return "Deserialization failed"

# 취약점 7: Weak Crypto
from hashlib import md5
@app.route('/hash/<password>')
def hash_password(password):
    # 취약한 해시 알고리즘 사용
    return md5(password.encode()).hexdigest()

# 취약점 8: SSRF (Server-Side Request Forgery)
import requests
@app.route('/fetch')
def fetch_url():
    url = request.args.get('url')
    # SSRF 취약점
    try:
        response = requests.get(url)
        return response.text
    except:
        return "Request failed"

@app.route('/')
def home():
    return '''
    <h1>Vulnerable Flask App</h1>
    <p>Endpoints:</p>
    <ul>
        <li>/user/&lt;username&gt; - SQL Injection</li>
        <li>/ping?host=&lt;host&gt; - Command Injection</li>
        <li>/search?q=&lt;query&gt; - XSS</li>
        <li>/file?name=&lt;filename&gt; - Path Traversal</li>
        <li>/hash/&lt;password&gt; - Weak Crypto</li>
        <li>/fetch?url=&lt;url&gt; - SSRF</li>
    </ul>
    '''

@app.route('/health')
def health():
    return {'status': 'healthy', 'app': 'vulnerable-flask-app'}

if __name__ == '__main__':
    # 취약점 9: Debug Mode in Production
    app.run(host='0.0.0.0', port=5000, debug=True)
