#!/bin/bash

SOURCE="/home/linu"       # Локальная папка для создания бэкапа
DESTINATION="/tmp/backup" # Папка для хранения бэкапов на сервере
LOG_TAG="BACKUP_SCRIPT"   # Таг для лога

# Создание бэкапа
rsync -av --delete "$SOURCE" "$DESTINATION"

# Добавление сообщения в лог
if [ $? -eq 0 ]; then
    logger -p user.info -t "$LOG_TAG" "Home directory backup completed successfully"
else
    logger -p user.err -t "$LOG_TAG" "Failed to create backup of home directory"
fi
