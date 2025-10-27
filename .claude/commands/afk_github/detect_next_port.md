# Detect Next Available Port for AFK GitHub

Detect the next available port for the AFK GitHub webhook server.

## Task

1. Check if PORT is already set in `.env`
2. If set, verify it's available (not in use)
3. If not set or in use, find the next available port starting from 8001
4. Update or create the PORT entry in `.env`
5. Report the port to the user

## Implementation

```bash
#!/bin/bash
# Wrapped in bash heredoc for zsh compatibility

bash << 'EOFSCRIPT'
set -e

# Check if .env exists
if [ ! -f .env ]; then
    touch .env
    echo "Created .env file"
fi

# Function to check if port is in use
check_port() {
    lsof -i:$1 >/dev/null 2>&1
    return $?
}

# Check if PORT is already in .env - use grep/cut instead of source
CURRENT_PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d'=' -f2)

if [ -n "$CURRENT_PORT" ]; then
    echo "PORT is set to $CURRENT_PORT in .env"
    if check_port $CURRENT_PORT; then
        echo "⚠️  Port $CURRENT_PORT is already in use"
        CURRENT_PORT=""
    else
        echo "✅ Port $CURRENT_PORT is available"
        exit 0
    fi
fi

# Find next available port starting from 8001
PORT=8001
while check_port $PORT; do
    echo "Port $PORT is in use, trying next..."
    PORT=$((PORT + 1))
    if [ $PORT -gt 8100 ]; then
        echo "❌ No available ports found in range 8001-8100"
        exit 1
    fi
done

# Update .env
if grep -q "^PORT=" .env 2>/dev/null; then
    # Update existing PORT line (handle both macOS and Linux sed)
    if [ "$(uname)" = "Darwin" ]; then
        sed -i '' "s/^PORT=.*/PORT=$PORT/" .env
    else
        sed -i "s/^PORT=.*/PORT=$PORT/" .env
    fi
else
    # Add PORT line
    echo "PORT=$PORT" >> .env
fi

echo ""
echo "✅ Port $PORT is available and set in .env"
echo ""

# Verify the change
echo "Verification:"
grep "^PORT=" .env
EOFSCRIPT
```

## Expected Output

- Port number that will be used for the webhook server
- Confirmation that `.env` has been updated
