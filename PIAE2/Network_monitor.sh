#!/bin/bash

# Monitoreo de red
# Author: Karyme Gonzalez, Kevin Ochoa
# Date: 29/09/2024
# Description: Monitorear la conectividad de red con funcionalidades avanzadas.

# Default configurations
DEFAULT_HOST="8.8.8.8"
DEFAULT_INTERVAL=60
DEFAULT_LOGFILE="$HOME/network_monitor.log"

# Global variables
HOST="$DEFAULT_HOST"
INTERVAL="$DEFAULT_INTERVAL"
LOGFILE="$DEFAULT_LOGFILE"
PID_FILE="/tmp/network_monitor.pid"

# Function to display the main menu
show_menu() {
    while true; do
        clear
        echo "====================================="
        echo "        Network Monitor Menu         "
        echo "====================================="
        echo "1. Start Monitoring"
        echo "2. Stop Monitoring"
        echo "3. Generate Report"
        echo "4. Configure Settings"
        echo "5. View Log"
        echo "6. Exit"
        echo "====================================="
        read -p "Select an option [1-6]: " choice
        case $choice in
            1) start_monitoring ;;
            2) stop_monitoring ;;
            3) generate_report ;;
            4) configure_settings ;;
            5) view_log ;;
            6) exit_script ;;
            *) echo "Invalid option. Please select between 1-6."; sleep 2 ;;
        esac
    done
}

# Function to start the monitoring process
start_monitoring() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Monitoring is already running with PID $(cat $PID_FILE)."
    else
        echo "Starting network monitoring..."
        nohup bash "$0" monitor &> /dev/null &
        echo $! > "$PID_FILE"
        echo "Monitoring started with PID $(cat "$PID_FILE")."
    fi
    pause
}

# Function to stop the monitoring process
stop_monitoring() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill "$PID" > /dev/null 2>&1; then
            echo "Monitoring stopped (PID $PID)."
            rm -f "$PID_FILE"
        else
            echo "Failed to stop monitoring. Process may not exist."
            rm -f "$PID_FILE"
        fi
    else
        echo "Monitoring is not running."
    fi
    pause
}

# Function to perform the monitoring (background process)
monitor() {
    # Handle termination signals to exit gracefully
    trap "exit" SIGTERM SIGINT

    while true; do
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        if ping -c 1 "$HOST" > /dev/null 2>&1; then
            echo "$timestamp: SUCCESS - Connected to $HOST" >> "$LOGFILE"
        else
            echo "$timestamp: FAILURE - Cannot connect to $HOST" >> "$LOGFILE"
        fi
        sleep "$INTERVAL"
    done
}

# Function to generate a report from the log file
generate_report() {
    if [ ! -f "$LOGFILE" ]; then
        echo "Log file does not exist. No data to report."
    else
        echo "Generating network connectivity report..."
        echo "========================================="
        echo "Report for Host: $HOST"
        echo "Interval: $INTERVAL seconds"
        echo "Log File: $LOGFILE"
        echo "========================================="

        SUCCESS_COUNT=$(grep -c "SUCCESS" "$LOGFILE")
        FAILURE_COUNT=$(grep -c "FAILURE" "$LOGFILE")
        TOTAL=$((SUCCESS_COUNT + FAILURE_COUNT))

        if [ "$TOTAL" -gt 0 ]; then
            SUCCESS_PERCENT=$((SUCCESS_COUNT * 100 / TOTAL))
            FAILURE_PERCENT=$((FAILURE_COUNT * 100 / TOTAL))
        else
            SUCCESS_PERCENT=0
            FAILURE_PERCENT=0
        fi

        echo "Total Pings: $TOTAL"
        echo "Successful Pings: $SUCCESS_COUNT ($SUCCESS_PERCENT%)"
        echo "Failed Pings: $FAILURE_COUNT ($FAILURE_PERCENT%)"
        echo "========================================="
    fi
    pause
}

# Function to configure settings
configure_settings() {
    while true; do
        echo "Current Settings:"
        echo "1. Host to monitor: $HOST"
        echo "2. Interval (seconds): $INTERVAL"
        echo "3. Log file path: $LOGFILE"
        echo "4. Return to main menu"
        echo "========================================="
        read -p "Select setting to change [1-4]: " config_choice
        case $config_choice in
            1)
                read -p "Enter new host (IP or domain): " new_host
                if [[ -n "$new_host" ]]; then
                    # Simple validation for IP or domain
                    if [[ "$new_host" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || "$new_host" =~ ^([a-zA-Z0-9]+\.)+[a-zA-Z]{2,}$ ]]; then
                        HOST="$new_host"
                        echo "Host updated to $HOST."
                    else
                        echo "Invalid host format."
                    fi
                else
                    echo "Invalid host input."
                fi
                ;;
            2)
                read -p "Enter new interval in seconds: " new_interval
                if [[ "$new_interval" =~ ^[0-9]+$ && "$new_interval" -gt 0 ]]; then
                    INTERVAL="$new_interval"
                    echo "Interval updated to $INTERVAL seconds."
                else
                    echo "Invalid interval input."
                fi
                ;;
            3)
                read -p "Enter new log file path: " new_logfile
                if [[ -n "$new_logfile" ]]; then
                    # Check if the directory is writable
                    LOGDIR=$(dirname "$new_logfile")
                    if [ -d "$LOGDIR" ] && [ -w "$LOGDIR" ]; then
                        LOGFILE="$new_logfile"
                        echo "Log file path updated to $LOGFILE."
                    else
                        echo "Cannot write to the specified directory."
                    fi
                else
                    echo "Invalid log file path."
                fi
                ;;
            4) break ;;
            *) echo "Invalid option."; ;;
        esac
    done
    pause
}

# Function to view the log file
view_log() {
    if [ -f "$LOGFILE" ]; then
        echo "Displaying log file: $LOGFILE"
        echo "========================================="
        if command -v less > /dev/null 2>&1; then
            less "$LOGFILE"
        else
            cat "$LOGFILE"
        fi
    else
        echo "Log file does not exist."
    fi
    pause
}

# Function to exit the script
exit_script() {
    echo "Exiting Network Monitor. Goodbye!"
    exit 0
}

# Function to handle pauses
pause() {
    echo ""
    read -p "Press [Enter] key to continue..." temp
}

# Function to handle errors and invalid inputs globally
error_handler() {
    echo "An unexpected error occurred on line $LINENO. Exiting."
    exit 1
}

# Trap unexpected errors
trap 'error_handler' ERR

# Entry point
if [ "$1" == "monitor" ]; then
    monitor
else
    show_menu
fi

# dar permisos de ejecución 

chmod +x network_monitor.sh

# ejecutar el script 

./network_monitor.sh
