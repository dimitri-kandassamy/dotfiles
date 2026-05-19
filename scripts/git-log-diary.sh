#!/usr/bin/env bash
# Convert the current repo's git log into a markdown diary, one file per
# year, grouped by month. Filters out merge/typo/lint/format commits.
#
# Usage: run from inside any git repo. Output goes to ./diary/<year>.md.

set -euo pipefail

OUTPUT_DIR="diary"
EXCLUDE_REGEX='merge|typo|lint|format'

mkdir -p "$OUTPUT_DIR"

echo "Extracting git history..."

current_year=""
current_month=""
output_file=""

# Stream commit SHAs and fetch each commit's fields with `git show`. Avoids
# fragile multi-character delimiter parsing on BSD tools (the previous
# implementation relied on gawk-only RS semantics).
git log --reverse --no-merges --pretty=format:'%H' | while IFS= read -r sha; do
  date=$(git show -s --format=%cd --date=short "$sha")
  author=$(git show -s --format=%an "$sha")
  subject=$(git show -s --format=%s "$sha")
  body=$(git show -s --format=%b "$sha")

  if printf '%s\n%s\n' "$subject" "$body" | grep -Eiq "$EXCLUDE_REGEX"; then
    continue
  fi

  year="${date:0:4}"
  month="${date:0:7}"

  if [[ "$year" != "$current_year" ]]; then
    current_year="$year"
    output_file="$OUTPUT_DIR/$year.md"
    printf '# Developer Diary — %s\n\n' "$year" > "$output_file"
    current_month=""
  fi

  if [[ "$month" != "$current_month" ]]; then
    current_month="$month"
    printf '## %s\n\n' "$month" >> "$output_file"
  fi

  {
    printf '### %s\n\n' "$subject"
    printf -- '- **Author:** %s\n' "$author"
    printf -- '- **Date:** %s\n\n' "$date"
    [[ -n "$body" ]] && printf '%s\n\n' "$body"
    printf -- '---\n\n'
  } >> "$output_file"
done

echo "Done. Diary saved in ./$OUTPUT_DIR/"
