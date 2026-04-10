#!/usr/bin/env bash

set -euo pipefail

OUTPUT_DIR="diary"
TMP_FILE="$(mktemp)"

# Patterns to exclude (case-insensitive)
EXCLUDE_REGEX="merge|typo|lint|format"

mkdir -p "$OUTPUT_DIR"

echo "Extracting git history..."

git log --reverse \
  --no-merges \
  --date=short \
  --pretty=format:"%ad|||%an|||%s|||%b<<<END>>>" \
  > "$TMP_FILE"

current_year=""
current_month=""
output_file=""

echo "Building diary..."

while IFS= read -r entry; do
  # Split fields
  date=$(echo "$entry" | cut -d '|' -f1)
  author=$(echo "$entry" | cut -d '|' -f4)
  subject=$(echo "$entry" | cut -d '|' -f7)
  body=$(echo "$entry" | cut -d '|' -f10)

  # Filter noise
  full_msg="$subject $body"
  if echo "$full_msg" | grep -Eiq "$EXCLUDE_REGEX"; then
    continue
  fi

  year="${date:0:4}"
  month="${date:0:7}"

  # Create new file per year
  if [[ "$year" != "$current_year" ]]; then
    current_year="$year"
    output_file="$OUTPUT_DIR/$year.md"
    echo "# Developer Diary — $year" > "$output_file"
    echo "" >> "$output_file"
    current_month=""
  fi

  # Add month section
  if [[ "$month" != "$current_month" ]]; then
    current_month="$month"
    echo "## $month" >> "$output_file"
    echo "" >> "$output_file"
  fi

  # Write entry
  {
    echo "### $subject"
    echo ""
    echo "- **Author:** $author"
    echo "- **Date:** $date"
    echo ""
    [[ -n "$body" ]] && echo "$body"
    echo ""
    echo "---"
    echo ""
  } >> "$output_file"

done < <(awk -v RS="<<<END>>>" '{print}' "$TMP_FILE")

rm "$TMP_FILE"

echo "Done. Diary saved in ./$OUTPUT_DIR/"