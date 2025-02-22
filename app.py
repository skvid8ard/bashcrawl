#!/opt/venv/bin/python
from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)
current_directory = "/var/www/html/bashcrawl"

@app.route('/run_command', methods=['POST'])
def run_command():
    global current_directory
    command = request.form.get('command')
    
    if command:
        # Обрабатываем команду cd отдельно
        if command.startswith("cd "):
            new_dir = command[3:].strip()
            potential_directory = os.path.abspath(os.path.join(current_directory, new_dir))
            
            if os.path.isdir(potential_directory):
                current_directory = potential_directory
                return jsonify(output=f"Directory changed to {current_directory}")
            else:
                return jsonify(error=f"No such directory: {new_dir}")

        # Запускаем команду в текущей директории
        result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=current_directory)
        return jsonify(output=result.stdout, error=result.stderr)
    
    return jsonify(error="No command provided"), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

