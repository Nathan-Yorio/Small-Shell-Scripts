#!/bin/bash

while true; do
  # Check if clamscan process is running
  if ps aux | grep -q "[c]lamscan"; then
    # If clamscan is running, get the process ID and try to get the scan progress
    clamscan_pid=$(ps aux | grep "[c]lamscan" | awk '{print $2}')
    # There are some issues with the /proc/pid/fd/1 having no progress written to file
    # occasionally, so perhaps a different method would make more sense in this case
    progress=$(grep "Percentage of progress" /proc/$clamscan_pid/fd/1 | awk '{print $5}')
    if [ -n "$progress" ]; then
      # If progress was retrieved, output the process ID and progress
      echo "Clamscan is running with process ID $clamscan_pid, progress: $progress"
    else
      # If progress could not be retrieved, output a message
      echo "Clamscan is running with process ID $clamscan_pid, but progress could not be retrieved"
    fi
  else
    # If clamscan is not running, output a message
    echo "Clamscan is not running"
  fi

  # Sleep for 1 second before checking again
  sleep 1
done

# Alternative method
##!/bin/bash

# Check if clamscan process is running
#if ps aux | grep -q "[c]lamscan"; then
#  # If clamscan is running, output the process ID and scan progress
#  clamscan_pid=$(pgrep clamscan)
#  progress=$(grep "Progress" /proc/$clamscan_pid/fdinfo/1 | awk '{print $2}')
#  echo "Clamscan is running with process ID $clamscan_pid, progress: $progress"
#else
#  # If clamscan is not running, output a message
#  echo "Clamscan is not running"
#fi
