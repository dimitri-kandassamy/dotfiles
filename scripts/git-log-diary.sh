#!/usr/bin/env bash
# Convert the current repo's git log into a markdown diary, one file per
# year, grouped by month. Filters out merge/typo/lint/format commits.
#
# Usage: run from inside any git repo. Output goes to ./diary/<year>.md.

set -euo pipefail
shopt -s nocasematch

OUTPUT_DIR="diary"
EXCLUDE_REGEX='merge|typo|lint|format'

# Field separator inside a record (ASCII unit separator); records themselves
# are NUL-separated via `git log -z`, so multi-line bodies survive intact.
US=$'\x1f'

mkdir -p "$OUTPUT_DIR"

echo "Extracting git history..."

current_year=""
current_month=""
output_file=""

# One `git log` pass, NUL-separated records. Author date (%ad), not committer
# date — a diary should reflect when the work was done, not when it was rebased.
#
# Sorted by date rather than relying on --reverse: author dates are not
# monotonic in commit order (rebases, cherry-picks, long-lived branches), and
# the year/month headers below assume they are. Without the sort, revisiting an
# earlier year truncates the file already written for it. Sorting on %at (unix
# timestamp) rather than %ad keeps commits made on the same day in chronological
# order, which a plain date sort would lose.
while IFS= read -r -d '' record || [[ -n "$record" ]]; do
  rest="${record#*"$US"}"                    # drop the %at sort key
  date="${rest%%"$US"*}"; rest="${rest#*"$US"}"
  author="${rest%%"$US"*}"; rest="${rest#*"$US"}"
  subject="${rest%%"$US"*}"
  body="${rest#*"$US"}"

  # %b keeps the trailing blank lines git pads the body with
  while [[ "$body" == *$'\n' ]]; do body="${body%$'\n'}"; done

  if [[ "$subject $body" =~ $EXCLUDE_REGEX ]]; then
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
done < <(git log --reverse --no-merges -z --date=short \
  --format="%at${US}%ad${US}%an${US}%s${US}%b" \
  | LC_ALL=C sort -z -s -t "$US" -k1,1n)

echo "Done. Diary saved in ./$OUTPUT_DIR/"
