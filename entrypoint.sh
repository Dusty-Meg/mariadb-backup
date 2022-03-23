BACKUP_CMD="/app/backup.sh"

echo "Starting mariadb-backup..."

# Check parameters
if [ -z ${MARIADB_HOST} ]; then
    echo "FAIL: Parameter MARIADB_HOST is not set"
    exit 1
fi
if [ -z ${MARIADB_USER} ]; then
    echo "FAIL: Parameter MARIADB_USER is not set"
    exit 1
fi
if [ -z ${MARIADB_PASSWORD} ]; then
    echo "FAIL: Parameter MARIADB_PASSWORD is not set"
    exit 1
fi

# Test database connectivity
CREDENTIALS="-u ${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} -P ${MARIADB_PORT}"
mysql ${CREDENTIALS} -e ";"
RET=$?
if [ ${RET} -ne 0 ]; then
    echo "FAIL: connection to ${MARIADB_HOST} failed"
    exit 1
fi

# Create files and folders
mkdir -p $(dirname ${LOG_FILE})
touch ${LOG_FILE}
mkdir -p ${BACKUP_FOLDER}

# Just run the backup script
if [ "$1" = "manual" ]; then
    $BACKUP_CMD
    exit 0
fi

# Init cron if not already done
if [ "$(grep -c ${BACKUP_CMD} ${CRON_FILE})" -eq 0 ]; then
    echo "Initializing cron..."
    echo "${CRON_TIME} ${BACKUP_CMD} >> ${LOG_FILE} 2>&1" | crontab -
    cat ${CRON_FILE}
fi

# Start crond if it's not running
pgrep crond > /dev/null 2>&1
if [ $? -ne 0 ]; then
  /usr/sbin/crond -L /app/log/cron.log
fi

echo "$(date "+%F %T") - Container started" >> ${LOG_FILE}
# tail to infinity and beyond
tail -F ${LOG_FILE} /app/log/cron.log