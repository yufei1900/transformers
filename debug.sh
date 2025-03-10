#!/bin/bash

# Command to execute
COMMAND="amd-smi list"

# Log paths
STRACE_LOG="/tmp/strace_amd_smi_list.log"
DMESG_LOG="/tmp/segfault_dmesg.log"
CORE_DUMP_PATTERN="/tmp/core.%e.%p.%h.%t"

# Configure core dump settings
echo "Configuring core dump settings..."
ulimit -c unlimited
echo "$CORE_DUMP_PATTERN" | sudo tee /proc/sys/kernel/core_pattern > /dev/null

# Execute the command and capture its output
echo "Executing command: $COMMAND"
OUTPUT=$($COMMAND 2>&1)
EXIT_STATUS=$?

# Display the output of the command
echo "=== AMD-SMI LIST OUTPUT ==="
echo "$OUTPUT"

# Check command status
if [ $EXIT_STATUS -ne 0 ]; then
  echo "Command failed with exit status $EXIT_STATUS. Capturing diagnostics..."

  # Capture strace output
  strace -o $STRACE_LOG $COMMAND || true

  # Capture dmesg output for segfaults
  sudo dmesg | grep -i segfault > $DMESG_LOG

  # Display Strace output
  echo "=== STRACE OUTPUT ==="
  cat $STRACE_LOG

  # Display dmesg output
  echo "=== DMESG OUTPUT ==="
  cat $DMESG_LOG

  # Display core dump files if they exist
  if ls /tmp/core* 1> /dev/null 2>&1; then
    echo "=== CORE DUMP FILES ==="
    ls -lh /tmp/core*
  else
    echo "No core dump files found."
  fi

else
  echo "Command executed successfully."
fi
