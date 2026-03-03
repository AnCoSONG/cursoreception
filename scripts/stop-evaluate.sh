#!/bin/bash
# Cursoreception: stop hook
# When the agent loop ends successfully on the first pass (loop_count == 0),
# sends a follow-up message to trigger knowledge evaluation.
# loop_limit is set to 1 in hooks.json so this only fires once per conversation.

input=$(cat)

status=$(echo "$input" | grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
loop_count=$(echo "$input" | grep -o '"loop_count"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | sed 's/.*: *//')

if [ "$status" = "completed" ] && [ "$loop_count" = "0" ]; then
  cat << 'EOF'
{
  "followup_message": "Before ending, quickly evaluate: did this session produce any non-obvious knowledge worth preserving? If yes, extract it as a Skill or Rule using cursoreception. If nothing notable, just say 'No extractable knowledge this session.' and stop."
}
EOF
else
  echo '{}'
fi
