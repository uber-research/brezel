#!/bin/bash
#
# This monitoring script is supposed to be run by a cron job.
# The instance will be stopped if the cpu activity, measured
# by the load average in the last 15 minutes, is under a given
# threshold. A minimum uptime is requested to power off.
#

# parameters
readonly LOG_FILE='/var/log/monitor-instance.log'
readonly CPU_AVG_MIN='0.5'
readonly UPTIME_MIN_s='2000'

log_message () {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S')] ${*}" >> "${LOG_FILE}"
}

cpu_under_threshold () {
    awk '{exit $1 < $2 ? 0 : 1}' <<< "${LOAD_15} ${CPU_AVG_MIN}"  
}

uptime_under_minimum () {
    awk '{exit $1 < $2 ? 0 : 1}' <<< "${UPTIME_s} ${UPTIME_MIN_s}"  
}

LOAD_15=$(awk '{print $3}' /proc/loadavg)
UPTIME_s=$(awk '{print int($1)}' /proc/uptime)

log_message "Load avarage (15m) is ${LOAD_15}"
if cpu_under_threshold && ! uptime_under_minimum
then
    log_message "CPU under threshold. Shutting down."
    poweroff
fi
