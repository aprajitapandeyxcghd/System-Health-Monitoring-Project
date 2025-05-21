#!/bin/bash

# === Configuration ===
CPU_THRESHOLD=80        # CPU usage percent threshold to trigger alert
MEM_THRESHOLD=80        # Memory usage percent threshold
DISK_THRESHOLD=90       # Disk usage percent threshold (for root partition)
EMAIL_TO="youremail@example.com"  # Change to your email address
SEND_EMAIL=true         # Set false to disable email alerts
LOG_FILE="./system_health.log"    # Log file location

# === Get current timestamp ===
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# === Get CPU usage percentage ===
# `top` shows CPU idle %, so 100 - idle = usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \
  sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
  awk '{print 100 - $1}')

# === Get Memory usage percentage ===
MEM_TOTAL=$(free | grep Mem | awk '{print $2}')
MEM_USED=$(free | grep Mem | awk '{print $3}')
MEM_USAGE=$(( 100 * MEM_USED / MEM_TOTAL ))

# === Get Disk usage percentage (root /) ===
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# === Get count of running processes ===
PROC_COUNT=$(ps aux --no-heading | wc -l)

# === Check network connectivity by pinging Google DNS ===
ping -c 1 8.8.8.8 > /dev/null 2>&1
NET_STATUS=$?

# === Prepare alert message if thresholds exceeded ===
ALERTS=""

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
  ALERTS+="CPU usage high: ${CPU_USAGE}%\n"
fi

if (( MEM_USAGE > MEM_THRESHOLD )); then
  ALERTS+="Memory usage high: ${MEM_USAGE}%\n"
fi

if (( DISK_USAGE > DISK_THRESHOLD )); then
  ALERTS+="Disk usage high: ${DISK_USAGE}%\n"
fi

if (( NET_STATUS != 0 )); then
  ALERTS+="Network connectivity issue detected\n"
fi

# === Write system health report to log file ===
{
  echo "[$TIMESTAMP] System Health Report"
  echo "CPU Usage: ${CPU_USAGE}%"
  echo "Memory Usage: ${MEM_USAGE}%"
  echo "Disk Usage (root): ${DISK_USAGE}%"
  echo "Running Processes: ${PROC_COUNT}"
  echo "Network Status: $( [ $NET_STATUS -eq 0 ] && echo 'OK' || echo 'FAIL' )"
  if [[ -n $ALERTS ]]; then
    echo -e "\nALERTS:\n$ALERTS"
  else
    echo "All metrics within thresholds."
  fi
  echo "-----------------------------------"
} >> "$LOG_FILE"

# === Send email alert if alerts exist and email enabled ===
if [[ -n $ALERTS && "$SEND_EMAIL" = true ]]; then
  echo -e "Subject: System Health Alert\n\n$ALERTS" | sendmail "$EMAIL_TO"
fi
