#!/opt/venv/bin/python
from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/run_command', methods=['POST'])
def run_command():
    command = request.form.get('command')
    # Задаем стандартную директорию выполнения
    working_directory = '/var/www/html/bashcrawl'
    
    if command:
        # Используем bash для выполнения команды
        result = subprocess.run(f'bash -c "{command}"', shell=True, capture_output=True, text=True, cwd=working_directory)
        return jsonify(output=result.stdout, error=result.stderr)
    return jsonify(error="No command provided"), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

