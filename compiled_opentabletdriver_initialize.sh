#!/bin/bash
export DOTNET_ROOT=/home/user/dotnet
export PATH=$PATH:/home/user/dotnet

otdaemon

sleep 2

# Launch the application and store the process ID in a variable
setsid /home/user/.local/bin/opentabletdriver/OpenTabletDriver.UX.Gtk > /dev/null 2>&1 &
APP_PID=$!

# Wait for the application to initialize
sleep 2

# Use xdotool to find the terminal window that was opened by the script and close it
TERMINAL_WINDOW=$(xdotool search --onlyvisible --class "Terminal" | tail -1)
if [ -n "$TERMINAL_WINDOW" ]; then
  xdotool windowclose "$TERMINAL_WINDOW"
fi

# Detach the background process from the terminal session
disown "$APP_PID"
