#!/bin/bash
set -e

echo "Starting OpenTAKServer Processes..."

# Wait for RabbitMQ to be ready
echo "Waiting for RabbitMQ..."
until /app/venv/bin/python -c "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.connect(('${OTS_RABBITMQ_SERVER_ADDRESS}', 5672))"; do
    echo "RabbitMQ not ready, retrying in 2s..."
    sleep 2
done
echo "RabbitMQ is up!"

# Start CoT Parser (Processes messages from RabbitMQ)
echo "Starting CoT Parser..."
/app/venv/bin/python -m opentakserver.cot_parser.cot_parser &

# Start SSL Listener (Port 8089)
echo "Starting SSL EUD Handler..."
/app/venv/bin/python -m opentakserver.eud_handler.eud_handler --ssl &

# Start TCP Listener (Port 8088)
if [[ "${OTS_ENABLE_TCP_STREAMING_PORT}" == "True" || "${OTS_ENABLE_TCP_STREAMING_PORT}" == "1" ]]; then
    echo "Starting TCP EUD Handler..."
    /app/venv/bin/python -m opentakserver.eud_handler.eud_handler &
fi

# Start Main Web API (Foreground)
echo "Starting OpenTAKServer Web API..."
exec /app/venv/bin/python -c "from opentakserver.app import start; start()"
