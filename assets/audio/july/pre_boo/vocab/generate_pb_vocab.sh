#!/usr/bin/env bash
set -euo pipefail

MODEL="gpt-4o-mini-tts"
VOICE="sage"
DELAY=8

# IMPORTANT: force ONE clean word, no repeat, no question tone
INSTRUCTIONS="You are a cheerful elementary school English teacher. Speak brightly and friendly. Say ONLY the given word or phrase exactly ONE time. Do NOT repeat it. Do NOT add extra words. Do NOT add 'dot' or 'period'. Do NOT sound like a question. Use a clear, neutral falling intonation."

WORDS=(
  "story" "hero" "bad guy" "king" "queen" "prince" "princess" "dragon" "wolf" "witch"
  "giant" "fairy" "monster" "castle" "forest"
  "magic" "spell" "sword" "shield" "treasure" "map" "door" "key" "cave" "tower"
  "horse" "friend" "enemy" "team" "adventure"
  "happy" "sad" "angry" "scared" "brave" "strong" "fast" "slow" "big" "small"
  "dark" "light" "funny" "kind" "secret"
  "once" "today" "first" "next" "then" "after" "last"
  "because" "but" "and"
  "help" "fight" "run" "find" "win"
)

sanitize() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 ]+//g; s/[[:space:]]+/_/g; s/^_+|_+$//g'
}

i=1
for word in "${WORDS[@]}"; do
  n=$(printf "%02d" "$i")
  safe="$(sanitize "$word")"
  out="pb_v${n}_${safe}.mp3"

  echo "🎙  $out  <-  $word"

  curl -sS https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL}\",\"voice\":\"${VOICE}\",\"instructions\":\"${INSTRUCTIONS}\",\"input\":\"${word}\"}" \
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
