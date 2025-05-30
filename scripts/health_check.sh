#!/bin/bash

# Health check script for dbt
set -e

LOG_FILE="/var/log/dbt/health_check_$(date +%Y%m%d).log"
mkdir -p /var/log/dbt

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if we can connect to Snowflake
log "🔍 Performing health check..."

# Test dbt debug (checks connection)
if dbt debug --profiles-dir /root/.dbt > /tmp/debug.log 2>&1; then
    log "✅ Snowflake connection successful"
else
    log "❌ Snowflake connection failed"
    cat /tmp/debug.log | tee -a "$LOG_FILE"
    exit 1
fi

# Check if target directory exists and has content
if [ -d "target" ] && [ "$(ls -A target)" ]; then
    log "✅ dbt target directory has content"
else
    log "⚠️  dbt target directory is empty - may need initial run"
fi

# Check recent log files
RECENT_LOGS=$(find /var/log/dbt -name "dbt_*.log" -mtime -1 | wc -l)
log "📋 Found $RECENT_LOGS recent dbt log files"

log "🎉 Health check completed"