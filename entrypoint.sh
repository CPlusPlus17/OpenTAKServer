#!/bin/bash
set -e

echo "Starting OpenTAKServer Processes..."

# Start CoT Parser (Processes messages from RabbitMQ)
echo "Starting CoT Parser..."
cot_parser &

# Start SSL Listener (Port 8089)
echo "Starting SSL EUD Handler..."
eud_handler --ssl &

# Start TCP Listener (Port 8088)
if [[ "${OTS_ENABLE_TCP_STREAMING_PORT}" == "True" || "${OTS_ENABLE_TCP_STREAMING_PORT}" == "1" ]]; then
    echo "Starting TCP EUD Handler..."
    eud_handler &
fi

# Start Main Web API (Foreground)
echo "Starting OpenTAKServer Web API..."
exec opentakserver
