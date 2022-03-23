FROM alpine:3.15.1

# TODO: don't use root
RUN apk add --no-cache mysql-client tar xz

ENV MARIADB_PORT 3306
ENV BACKUP_FOLDER /app/backup/
ENV USE_COMPRESS true
ENV CRON_TIME "0 */2 * * *"
ENV CRON_FILE /etc/crontabs/root
ENV LOG_FILE /app/log/backup.log
ENV DELETE_AFTER_DAYS 30

COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /app/

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]