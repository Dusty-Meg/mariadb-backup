FROM alpine:3.22

# TODO: don't use root
# mariadb-connector-c provides the caching_sha2_password plugin needed for MySQL 8.4+ servers
RUN apk add --no-cache mariadb-client mariadb-connector-c tar xz

ENV MARIADB_PORT 3306
ENV BACKUP_FOLDER /app/backup/
ENV USE_COMPRESS true
ENV CRON_TIME "0 */2 * * *"
ENV CRON_FILE /etc/crontabs/root
ENV LOG_FILE /app/log/backup.log
ENV DELETE_AFTER_DAYS 30

COPY --chmod=644 client.cnf /etc/my.cnf.d/client.cnf
COPY entrypoint.sh /entrypoint.sh
COPY backup.sh /app/

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]