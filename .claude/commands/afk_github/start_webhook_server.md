# Start Webhook Server

Start the ADW webhook server to listen for GitHub events.

## Task

1. Verify all prerequisites are met (PORT, env vars, ADW system)
2. Start the webhook server using uv
3. Run in background and log to file
4. Verify server is running

## Implementation

```bash
# Load environment variables
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    exit 1
fi

source .env

if [ -z "$PORT" ]; then
    echo "❌ PORT not set in .env"
    exit 1
fi

# Check if webhook server script exists
if [ ! -f adws/adw_triggers/trigger_webhook.py ]; then
    echo "❌ Webhook server not found at adws/adw_triggers/trigger_webhook.py"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

LOG_FILE="logs/afk_github_webhook_${PORT}.log"

# Check if server is already running
if lsof -i:$PORT | grep -q Python; then
    echo "⚠️  Server already running on port $PORT"
    PID=$(lsof -ti:$PORT)
    echo "PID: $PID"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "To stop: kill $PID"
    echo "To view logs: tail -f $LOG_FILE"
    exit 0
fi

echo "Starting webhook server on port $PORT..."
echo "Log file: $LOG_FILE"
echo ""

# Start the webhook server in background
cd adws
nohup uv run python adw_triggers/trigger_webhook.py --port $PORT > "../$LOG_FILE" 2>&1 &
SERVER_PID=$!
cd ..

# Give it a moment to start
sleep 2

# Check if it's running
if lsof -i:$PORT | grep -q Python; then
    echo "✅ Webhook server started successfully"
    echo "PID: $SERVER_PID"
    echo "Port: $PORT"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "To view logs: tail -f $LOG_FILE"
    echo "To stop: kill $SERVER_PID"
    echo ""
    echo "Test health endpoint:"
    echo "  curl http://localhost:$PORT/health"
else
    echo "❌ Failed to start webhook server"
    echo "Check logs: cat $LOG_FILE"
    exit 1
fi

echo ""
echo "=========================================="
echo "Webhook Server Running"
echo "=========================================="
echo "Local URL:  http://localhost:$PORT"
echo "Health:     http://localhost:$PORT/health"
echo "Webhook:    http://localhost:$PORT/gh-webhook"
echo ""
echo "Waiting for GitHub webhook events..."
echo "=========================================="
echo ""
```

## Expected Output

- Confirmation that webhook server is running
- PID and log file location
- Health check URL
