#!/bin/bash
# ================================
# Run all SQL scripts in sql_scripts folder on MariaDB
# ================================

# Database connection settings
DB_NAME="lucca_simplified"
DB_USER="your_user"
DB_PASS="your_password"
DB_HOST="localhost"
DB_PORT=3306

# Folder with SQL scripts
SQL_FOLDER="./sql_scripts"

# Log file
LOG_FILE="./etl_log.txt"

echo "=== Starting ETL job at $(date) ===" | tee -a "$LOG_FILE"

# Execute all SQL files in order
for sql_file in "$SQL_FOLDER"/*.sql; do
    echo "Executing $sql_file ..." | tee -a "$LOG_FILE"
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$sql_file"
    if [ $? -ne 0 ]; then
        echo "❌ Error executing $sql_file" | tee -a "$LOG_FILE"
        exit 1
    fi
done

echo "=== ETL job finished successfully at $(date) ===" | tee -a "$LOG_FILE"
