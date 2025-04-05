# Используем базовый образ Ubuntu
FROM ubuntu:latest

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    nginx \
    python3 \
    python3-venv \
    python3-pip \
    openssh-server \
    sudo

# Создаем виртуальное окружение и устанавливаем Flask
RUN python3 -m venv /opt/venv
RUN /opt/venv/bin/pip install flask

# Создаем пользователя www-data и настраиваем права
RUN usermod -aG sudo www-data

# Создаем пользователя ssh и устанавливаем пароль
RUN useradd -m -s /bin/bash ssh && echo "ssh:sshbashcrawlaccesspass" | chpasswd

RUN useradd -m -s /bin/bash user

RUN touch /home/user/.bash_history && \
    chown user:user /home/user/.bash_history

# Настраиваем SSH-сервер
RUN mkdir -p /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN echo "AllowUsers ssh" >> /etc/ssh/sshd_config

# Генерация ключей SSH
RUN ssh-keygen -A

# Создаем файл flag.txt в домашней директории пользователя ssh
RUN echo "CTF{Ch3Ck_.B45H_H15t0rY_1N_H0m3_D1r}" > /home/ssh/flag.txt

# Копируем файлы игры в директорию Nginx
COPY bashcrawl /var/www/html/bashcrawl

# Копируем Python-приложение
COPY app.py /var/www/html/app.py

# Настраиваем конфигурацию Nginx
COPY nginx.conf /etc/nginx/nginx.conf

COPY index.html /var/www/html/index.html

# Установите владельца и группу для директорий
RUN chown -R www-data:www-data /var/www/html
RUN chown -R user:user /var/www/html/bashcrawl

# Открываем порты для Nginx и SSH
EXPOSE 80 22

RUN echo "1  echo 'ssh:sshbashcrawlaccesspass' > /home/user/ssh_creds" > /home/user/.bash_history
RUN echo "2  cd /home/user/" >> /home/user/.bash_history
RUN echo "3  rm ssh_creds" >> /home/user/.bash_history
RUN echo "4  sudo -u user /opt/venv/bin/python /var/www/html/app.py &" >> /home/user/.bash_history

# Запускаем Nginx, SSH-сервер и Flask-приложение
#CMD service ssh start && /opt/venv/bin/python /var/www/html/app.py & nginx -g 'daemon off;'
CMD service ssh start && sudo -u user /opt/venv/bin/python /var/www/html/app.py & nginx -g 'daemon off;'

