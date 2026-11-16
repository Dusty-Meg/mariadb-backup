#!/bin/sh

DATE=`date +"%Y%m%d-%H%M%S"`

# TODO: use the one defined in entrypoint file
CREDENTIALS="-u ${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} -P ${MARIADB_PORT}"

# Get the list of databases, skipping the virtual/system schemas, which hold no data of
# our own and can't be dumped (performance_schema and sys error out on MySQL).
# -N drops the header row; the exact-match pattern avoids skipping e.g. "app_information_schema".
LIST_DATABASES=$(mariadb ${CREDENTIALS} -N -e "SHOW DATABASES;" | grep -Ev "^(information_schema|performance_schema|sys)$")

# cd ${BACKUP_FOLDER}
for database in ${LIST_DATABASES}; do
    echo "Starting backup of ${database} at $(date "+%F %T")"
    # Backup database in sql file
    mariadb-dump ${CREDENTIALS} ${database} > ${DATE}_${database}.sql #| gzip > ${DATE}_${database}.sql.gz
    echo "Finished backup of ${database} at $(date "+%F %T")"
    if [ "$USE_COMPRESS" = true ]; then
        echo "Starting compression of ${database} at $(date "+%F %T")"
        # Compress sql file with best compression with xz
        XZ_OPT="-6 -T4" tar -Jcf ${DATE}_${database}.sql.tar.xz ${DATE}_${database}.sql
        echo "Finished compression of ${database} at $(date "+%F %T")"
        # Delete sql file
        rm ${DATE}_${database}.sql
    fi
    echo "Starting moving of ${database} at $(date "+%F %T")"
    mv ${DATE}_${database}.sql.tar.xz ${BACKUP_FOLDER}/${DATE}_${database}.sql.tar.xz
    echo "Finished moving of ${database} at $(date "+%F %T")"
done

cd ${BACKUP_FOLDER}
if [ ! -z ${DELETE_AFTER_DAYS} ] && [ ${DELETE_AFTER_DAYS} -gt 0 ]; then
    find . -type f -mtime +${DELETE_AFTER_DAYS} -delete
fi