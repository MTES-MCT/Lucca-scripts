#!/bin/bash

# ===============================
# ETL Runner - Execute all SQL scripts
# Logs are stored in $LOG_ROOT/YYYY-MM/etl_log_YYYY-MM-DD.txt
# ===============================

set -euo pipefail

# Load database credentials from .env if present
if [ -f .env ]; then
    # Remove potential Windows line endings
    sed -i 's/\r$//' .env
    source .env
else
    echo "❌ .env file not found"
    exit 1
fi

# Defaults (can be overridden in .env)
SQL_FOLDER="${SQL_FOLDER:-./sql_scripts}"
LOG_ROOT="${LOG_ROOT:-./logs}"

# Check SQL folder exists
if [ ! -d "$SQL_FOLDER" ]; then
    echo "❌ SQL folder '$SQL_FOLDER' does not exist"
    exit 1
fi

# Check there are .sql files
shopt -s nullglob
SQL_FILES=("$SQL_FOLDER"/*.sql)
if [ ${#SQL_FILES[@]} -eq 0 ]; then
    echo "❌ No SQL files found in '$SQL_FOLDER'"
    exit 1
fi

# Create monthly log folder
MONTH_DIR="$LOG_ROOT/$(date +'%Y-%m')"
mkdir -p "$MONTH_DIR"

# Log file name: etl_log_YYYY-MM-DD.log
LOG_FILE="$MONTH_DIR/etl_log_$(date +'%Y-%m-%d').log"

echo "=== Starting ETL job at $(date) ===" | tee -a "$LOG_FILE"

# Loop through SQL files
for sql_file in "${SQL_FILES[@]}"; do
    echo "Executing $sql_file ..." | tee -a "$LOG_FILE"
    if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$sql_file"; then
        echo "❌ Error executing $sql_file" | tee -a "$LOG_FILE"
        exit 1
    fi
done

echo "=== ETL job finished successfully at $(date) ===" | tee -a "$LOG_FILE"
