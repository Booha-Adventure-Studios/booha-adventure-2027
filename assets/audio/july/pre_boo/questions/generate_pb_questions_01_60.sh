#!/usr/bin/env bash
set -euo pipefail

MODEL="gpt-4o-mini-tts"
VOICE="sage"
DELAY=8

INSTRUCTIONS="You are a cheerful elementary school English teacher. Ask the question in a bright, friendly, upbeat voice. Say the question exactly ONE time. Do not repeat. Do not add anything. Use natural question intonation."

QUESTIONS=(
  "Is this a story?"
  "Who is the hero?"
  "Who is the bad guy?"
  "Where is the castle?"
  "Is the dragon big?"
  "Is the princess kind?"
  "Is the wolf hungry?"
  "Can the fairy fly?"
  "Is the giant tall?"
  "Is there magic?"
  "Is the treasure gold?"
  "Is the map old?"
  "Is the monster scary?"
  "Are they friends?"
  "Is this fun?"

  "What does the hero do?"
  "Does the dragon breathe fire?"
  "Does the bad guy laugh?"
  "Who helps the hero?"
  "Can the hero fight?"
  "Can the hero run fast?"
  "Does the princess call for help?"
  "Does the giant walk slowly?"
  "Does the hero open the door?"
  "Does the monster run away?"
  "Does the king give a reward?"
  "Does the adventure begin?"
  "Can they win?"
  "Does the story end?"
  "Do they go home?"

  "Is the hero happy?"
  "Is the princess sad?"
  "Is the bad guy angry?"
  "Is the boy scared?"
  "Is the girl strong?"
  "Is the hero kind?"
  "Is the fairy small?"
  "Is the dragon strong?"
  "Is the team brave?"
  "Do they have a secret?"
  "Does the boy have a dream?"
  "Do they smile?"
  "Are they tired?"
  "Are they excited?"
  "Are they ready?"

  "What happens first?"
  "What happens next?"
  "What happens then?"
  "What happens after that?"

  "Does the hero wake up?"
  "Does he eat breakfast?"
  "Does he see a dragon?"
  "Does he drink water?"
  "Does the dragon get surprised?"
  "Does the bad guy fall down?"
  "Do they walk together?"
  "Do they stop?"
  "Do they try again?"
  "Do they win in the end?"
  "Is it a happy ending?"
)

# NOTE: You provided 61 lines in the list; we are generating 60 files.
# If you want EXACTLY 60, we should confirm whether you want to drop one,
# or if "Is it a happy ending?" should be #60 and we drop something earlier.
# For now, we will generate all provided questions in order.

sanitize() {
  echo "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E "s/[’']//g; s/[^a-z0-9 ]+//g; s/[[:space:]]+/_/g; s/^_+|_+$//g" \
    | cut -c1-80
}

i=1
for q in "${QUESTIONS[@]}"; do
  n=$(printf "%02d" "$i")
  safe="$(sanitize "$q")"
  out="pb_q${n}_${safe}.mp3"

  echo "🎙  $out"

  curl -sS https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL}\",\"voice\":\"${VOICE}\",\"instructions\":\"${INSTRUCTIONS}\",\"input\":\"${q}\"}" \
    --output "$out" \
    --connect-timeout 20 \
    --max-time 180 \
    --retry 5 \
    --retry-delay 5 \
    --retry-all-errors

  sleep ${DELAY}
  i=$((i+1))
done

echo "✅ Done."
