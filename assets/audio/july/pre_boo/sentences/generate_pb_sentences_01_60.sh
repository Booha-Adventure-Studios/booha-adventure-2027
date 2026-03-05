#!/usr/bin/env bash
set -euo pipefail

MODEL="gpt-4o-mini-tts"
VOICE="sage"
DELAY=8

INSTRUCTIONS="You are a SUPER cheerful elementary school English teacher. Bright, happy, energetic, smiling. Read the sentence exactly ONE time. Do not repeat. Do not add anything. Do not sound like a question. Use confident falling intonation for statements."

SENTENCES=(
  "This is a story."
  "The hero is brave."
  "The bad guy is scary."
  "The king is in the castle."
  "The princess is kind."
  "The dragon is big."
  "The wolf is hungry."
  "The witch has magic."
  "The giant is very tall."
  "The fairy can fly."
  "The monster is in the cave."
  "The horse runs fast."
  "The treasure is gold."
  "The map is old."
  "The team is ready."
  "The hero opens the door."
  "The dragon breathes fire."
  "The bad guy laughs."
  "The hero fights the monster."
  "The princess calls for help."
  "The witch makes a spell."
  "The hero finds a key."
  "The giant walks slowly."
  "The fairy helps the hero."
  "The team enters the forest."
  "The monster runs away."
  "The hero wins the fight."
  "The king gives a reward."
  "The castle door closes."
  "The adventure begins."
  "The hero is happy."
  "The princess is sad."
  "The bad guy is angry."
  "The boy is scared."
  "The girl is strong."
  "The hero is kind."
  "The giant is slow."
  "The fairy is small."
  "The dragon is strong."
  "The team is brave."
  "The hero has a secret."
  "The boy has a dream."
  "The girl smiles again."
  "The hero feels proud."
  "They are friends."
  "First, the hero wakes up."
  "Next, he eats breakfast."
  "Then he goes outside."
  "He sees a dragon."
  "Because he is brave, he fights."
  "But he is tired."
  "He drinks water."
  "After that, he runs."
  "The dragon is surprised."
  "He uses magic."
  "The bad guy falls down."
  "The hero wins."
  "Everyone is happy."
  "The king says thank you."
  "The story ends."
)

sanitize() {
  echo "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9 ]+//g; s/[[:space:]]+/_/g; s/^_+|_+$//g'
}

i=1
for s in "${SENTENCES[@]}"; do
  n=$(printf "%02d" "$i")
  safe="$(sanitize "$s")"
  out="pb_s${n}_${safe}.mp3"

  echo "🎙  $out"

  curl -sS https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL}\",\"voice\":\"${VOICE}\",\"instructions\":\"${INSTRUCTIONS}\",\"input\":\"${s}\"}" \
    --output "$out" \
    --connect-timeout 20 \
    --max-time 180 \
    --retry 5 \
    --retry-delay 5 \
    --retry-all-errors

  sleep ${DELAY}
  i=$((i+1))
done

echo "✅ Done (01–60)."
