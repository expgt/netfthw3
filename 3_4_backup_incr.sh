#!/bin/bash


USER_NAME="linu"
BACKUP_USER="linu"
BACKUP_HOST="192.168.232.188"
BACKUP_DIR="/home/linu/backuphome" # Папка для бэкапов на сервере
SOURCE_DIR="/home/$USER_NAME"      # Локальная домашняя папка
MAX_BACKUPS=5                      # Сколько копий хранить
DATE_TAG=$(date +"%Y-%m-%d_%H-%M-%S")

# 1. Создаем директорию для текущего бэкапа и инкремент переносим через жесткие ссылки, если есть latest
rsync -avz --delete \
    --link-dest="$BACKUP_DIR/latest" \
    --exclude=".cache" --exclude=".local" \
    "$SOURCE_DIR/" \
    "$BACKUP_USER@$BACKUP_HOST:$BACKUP_DIR/$DATE_TAG/"

# 2. Обновляем символическую ссылку latest на актуальный бэкап
ssh "$BACKUP_USER@$BACKUP_HOST" "ln -sfn $BACKUP_DIR/$DATE_TAG $BACKUP_DIR/latest"

# 3. Удаляем старые бэкапы, если их больше 5
ssh "$BACKUP_USER@$BACKUP_HOST" "bash -s" << EOF
    cd $BACKUP_DIR
    # Считаем и сортируем только папки с резервными копиями (исключая latest)
    backups=\$(ls -d 20[0-9][0-9]-* | sort)
    count=\$(echo "\$backups" | wc -l)

    # Если бэкапов больше, удаляем самые старые
    while [ "\$count" -gt "$MAX_BACKUPS" ]; do
        oldest_backup=\$(echo "\$backups" | head -n 1)
        rm -rf "\$oldest_backup"
        backups=\$(echo "\$backups" | tail -n +2)
        count=\$((count - 1))
    done
EOF

# Сообщаем, успешно или нет выполенено задание
if [ $? -eq 0 ]; then
    echo "Backup completed successfully!"
else
    echo "Cancelled."
fi
