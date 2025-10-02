#!/bin/bash

# ===============================
# ETL Runner - Execute all SQL scripts
# Logs are stored in $LOG_ROOT/YYYY-MM/etl_log_YYYY-MM-DD.log
# ===============================

set -euo pipefail

WITH_INIT=false

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-init)
            WITH_INIT=true
            shift
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Usage: $0 [--with-init]"
            exit 1
            ;;
    esac
done

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
SQL_INIT_FOLDER="${SQL_INIT_FOLDER:-./sql_scripts_init}"

# Function to execute SQL scripts from a given folder
run_sql_scripts() {
    local folder="$1"
    local label="$2"

    if [ ! -d "$folder" ]; then
        echo "⚠️  $label folder '$folder' does not exist, skipping"
        return
    fi

    shopt -s nullglob
    local sql_files=("$folder"/*.sql)
    if [ ${#sql_files[@]} -eq 0 ]; then
        echo "⚠️  No SQL files found in '$folder', skipping"
        return
    fi

    for sql_file in "${sql_files[@]}"; do
        echo "Executing $label script: $sql_file ..." | tee -a "$LOG_FILE"
        if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$sql_file"; then
            echo "❌ Error executing $sql_file" | tee -a "$LOG_FILE"
            exit 1
        fi
    done
}

# Create monthly log folder
MONTH_DIR="$LOG_ROOT/$(date +'%Y-%m')"
mkdir -p "$MONTH_DIR"

# Log file name: etl_log_YYYY-MM-DD.log
LOG_FILE="$MONTH_DIR/etl_log_$(date +'%Y-%m-%d').log"

echo "=== Starting ETL job at $(date) ===" | tee -a "$LOG_FILE"

# Run init scripts if requested
if [ "$WITH_INIT" = true ]; then
    run_sql_scripts "$SQL_INIT_FOLDER" "INIT"
fi

# Run main scripts
run_sql_scripts "$SQL_FOLDER" "MAIN"

echo "=== ETL job finished successfully at $(date) ===" | tee -a "$LOG_FILE"
