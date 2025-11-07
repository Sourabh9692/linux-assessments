#!/usr/bin/env bash
# show-attackers.sh
# Summarize failed SSH login attempts by IP and print CSV with GeoIP location.

set -Eeuo pipefail
# -e: exit on error
# -E: inherit ERR traps in functions (safe for larger scripts)
# -u: error on unset variables
# -o pipefail: fail a pipeline if any command fails (not just the last)

LOGFILE="${1-}"        # First CLI argument or empty if missing
LIMIT="${LIMIT:-10}"   # Threshold for "too many" attempts; default 10, override with env var

# Validate input file: must be provided and readable
if [[ -z "$LOGFILE" || ! -r "$LOGFILE" ]]; then
  echo "Cannot open log file: $LOGFILE" >&2
  exit 1
fi

# CSV header as required
echo "Count,IP,Location"

# 1) Find failed login lines (common sshd messages).
# 2) Extract the source IP (word after 'from').
# 3) Keep only IPv4 strings.
# 4) Count per IP (uniq -c) and sort descending.
mapfile -t results < <(
  grep -E "Failed password|Invalid user|authentication failure" "$LOGFILE" \
  | awk '{for (i=1;i<=NF;i++) if ($i=="from") {print $(i+1); break}}' \
  | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' \
  | sort \
  | uniq -c \
  | sort -nr
)

# Loop results like: "<count> <ip>"
for line in "${results[@]}"; do
  # First field = count, second field = IP
  count="$(awk '{print $1}' <<<"$line")"
  ip="$(awk '{print $2}' <<<"$line")"

  # Only print if attempts exceed LIMIT
  if (( count > LIMIT )); then
    # Resolve location with geoiplookup if available
    if command -v geoiplookup >/dev/null 2>&1; then
      # Example output: "GeoIP Country Edition: US, United States"
      # Keep everything after colon, then drop the leading country code to keep readable location.
      loc="$(geoiplookup "$ip" | head -n1 | sed -E 's/^[^:]*:\s*//' | sed -E 's/^[A-Z]{2},\s*//')"
      [[ -z "$loc" ]] && loc="Unknown"
    else
      loc="GeoIP tool not installed"
    fi

    # Emit CSV row
    echo "${count},${ip},${loc}"
  fi
done

