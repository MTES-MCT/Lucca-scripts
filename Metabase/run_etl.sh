#!/bin/bash

# ===============================
# ETL Runner - Execute all SQL scripts
# Logs are stored in $LOG_ROOT/YYYY-MM/etl_log_YYYY-MM-DD.log
# ===============================

set -euo pipefail

# Load .env if present (useful for local dev)
if [ -f .env ]; then
    # Remove potential Windows line endings
    sed -i 's/\r$//' .env
    source .env
    echo "ℹ️  Loaded variables from .env"
else
    echo "⚠️  No .env file found, expecting variables from environment"
fi

# Required variables (either from .env or environment)
: "${DB_NAME:?❌ DB_NAME is not set}"
: "${DB_USER:?❌ DB_USER is not set}"
: "${DB_PASS:?❌ DB_PASS is not set}"
: "${DB_HOST:?❌ DB_HOST is not set}"
: "${DB_PORT:?❌ DB_PORT is not set}"
: "${LOG_ROOT:?❌ LOG_ROOT is not set}"

# Defaults (can be overridden by .env / env)
SQL_FOLDER="${SQL_FOLDER:-./sql_scripts}"

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
