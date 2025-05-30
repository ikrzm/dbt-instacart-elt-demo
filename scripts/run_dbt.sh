#!/bin/bash

# dbt execution script
# Usage: ./run_dbt.sh [command]
# Commands: deps, run, test, docs, full

set -e

LOG_FILE="/var/log/dbt/dbt_$(date +%Y%m%d_%H%M%S).log"
mkdir -p /var/log/dbt

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_command() {
    log "Running: dbt $1"
    dbt $1 --profiles-dir /root/.dbt 2>&1 | tee -a "$LOG_FILE"
    if [ $? -eq 0 ]; then
        log "✅ Success: dbt $1"
    else
        log "❌ Failed: dbt $1"
        exit 1
    fi
}

# Default to full run if no command specified
COMMAND=${1:-full}

log "🚀 Starting dbt execution: $COMMAND"

case $COMMAND in
    "deps")
        run_command "deps"
        ;;
    "run")
        run_command "run"
        ;;
    "test")
        run_command "test"
        ;;
    "docs")
        run_command "docs generate"
        log "📚 Documentation generated and available at target/"
        ;;
    "full")
        run_command "deps"
        run_command "run"
        run_command "test"
        run_command "docs generate"
        log "🎉 Full dbt pipeline completed successfully!"
        ;;
    *)
        log "❌ Unknown command: $COMMAND"
        log "Available commands: deps, run, test, docs, full"
        exit 1
        ;;
esac

log "✨ dbt execution completed: $COMMAND"