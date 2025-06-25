#!/bin/bash

# Function to check if xclip is installed and install it if not
check_and_install_xclip() {
  if ! command -v xclip &> /dev/null; then
    echo "xclip not found. Installing xclip..."
    sudo apt-get update && sudo apt-get install -y xclip
  fi
}

# Check and install xclip if needed
check_and_install_xclip

API_KEY="sk-proj-..." # put your key here
MODEL="gpt-4o"
SYSTEM_PROMPT="You are a ubuntu terminal command assistant. You respond only with the command that the user is asking for. If multiple steps are needed you create a multi-step command concatinated to run in series. When asked for further clarification you respond with simple answers. You don't use markdown."
USER_PROMPT="$*"
MEMORY_FILE="$HOME/.local/bin/askgpt.memory" 
 
# Read last 10 question-response pairs (30 lines: q, a, ---)
MEMORY_CONTENT=$(tail -n 30 "$MEMORY_FILE" 2>/dev/null)

# Function to safely escape JSON
json_escape() {
  echo "$1" | jq -aRs .
}

# Build memory messages
MEMORY_MESSAGES=()
while IFS= read -r line; do
  case "$line" in
    question:*)
      USER_CONTENT="${line#question: }"
      USER_ESCAPED=$(json_escape "$USER_CONTENT")
      MEMORY_MESSAGES+=("{\"role\": \"user\", \"content\": $USER_ESCAPED}")
      ;;
    response:*)
      ASSISTANT_CONTENT="${line#response: }"
      ASSISTANT_ESCAPED=$(json_escape "$ASSISTANT_CONTENT")
      MEMORY_MESSAGES+=("{\"role\": \"assistant\", \"content\": $ASSISTANT_ESCAPED}")
      ;;
  esac
done <<< "$MEMORY_CONTENT"

# Add system and user messages
SYSTEM_ESCAPED=$(json_escape "$SYSTEM_PROMPT")
USER_ESCAPED=$(json_escape "$USER_PROMPT")

# Create full messages JSON
MESSAGES_JSON="[ {\"role\": \"system\", \"content\": $SYSTEM_ESCAPED}"
for msg in "${MEMORY_MESSAGES[@]}"; do
  MESSAGES_JSON+=", $msg"
done
MESSAGES_JSON+=", {\"role\": \"user\", \"content\": $USER_ESCAPED} ]"

# Send request
RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": $MESSAGES_JSON
  }")

CMD=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

# Output
if [[ -n "$CMD" ]]; then
  echo "$CMD"
  echo "$CMD" | xclip -selection clipboard

  # Save to memory
  {
    echo "question: $USER_PROMPT"
    echo "response: $CMD"
    echo "---"
  } >> "$MEMORY_FILE"

  # Keep last 10 pairs
  tail -n 30 "$MEMORY_FILE" > "$MEMORY_FILE.tmp" && mv "$MEMORY_FILE.tmp" "$MEMORY_FILE"
else
  echo "Error: No response from OpenAI API"
  echo "$RESPONSE" | jq
fi
