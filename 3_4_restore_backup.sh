#!/bin/bash


BACKUP_USER="linu"
BACKUP_HOST="192.168.232.188"
BACKUP_DIR="/home/linu/backuphome" # Папка для хранения бэкапов на сервере
SOURCE_DIR="/home/linu"            # Локальная папка для восстановления

echo "Available backups:"
# Получаем список папок бэкапов с сервера
backups=$(ssh "$BACKUP_USER@$BACKUP_HOST" "ls -d $BACKUP_DIR/20[0-9][0-9]-*")

# Выводим пронумерованный список бекапов
select backup_path in $backups; do
    if [ -n "$backup_path" ]; then
        echo "You have selected a backup: $(basename "$backup_path")"
        break
    else
        echo "Incorrect selection. Try again."
    fi
done

# Подтверждение действия
read -p "ATTENTION! Current data $SOURCE_DIR will be overwritten by data from the backup. Continue? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Starting recovery..."
    # Перенос выбранного бэкапа в локальную директорию для восстановления
    rsync -avz --delete "$BACKUP_USER@$BACKUP_HOST:$backup_path/" "$SOURCE_DIR/"
    echo "Recovery completed successfully!"
else
    echo "Cancelled."
fi
