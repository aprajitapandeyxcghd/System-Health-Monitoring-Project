# System-Health-Monitoring-Project

## Overview
This project is a Bash-based system health monitoring script that tracks key system metrics and generates alerts if any thresholds are exceeded. It monitors:

- CPU usage
- Memory usage
- Disk usage (root partition)
- Number of running processes
- Network connectivity

The script logs these metrics to a file and can send email notifications when system health thresholds are breached.

## Features
- Periodic monitoring of critical system resources
- Logs system status with timestamps to `system_health.log`
- Configurable CPU, memory, and disk usage thresholds
- Network connectivity test via ping to Google DNS (8.8.8.8)
- Email alerts for administrators on threshold breaches
- Designed to run as a cron job for automated continuous monitoring

## Setup Instructions

1. **Clone the repository**

git clone https://github.com/aprajitapandeyxcghd/System-Health-Monitoring-Project.git
cd system-health-monitor

2. **Configure the script**

Open sys_health_monitor.sh in a text editor

Set the desired thresholds and your email address in the configuration section at the top

3.**Make the script executable**

chmod +x sys_health_monitor.sh

4.**Test the script manually**

./sys_health_monitor.sh
Check the generated system_health.log file for output.
