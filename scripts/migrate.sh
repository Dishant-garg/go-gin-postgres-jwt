#!/usr/bin/env bash
set -euo pipefail

# Load .env into environment (supports KEY=VALUE and KEY = VALUE; ignores comments/blank lines)
if [[ -f ".env" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    # trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # skip blanks and comments
    [[ -z "$line" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue

    # Match: KEY [spaces] = [spaces] VALUE
    if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="${BASH_REMATCH[2]}"

      # trim whitespace around value
      val="${val#"${val%%[![:space:]]*}"}"
      val="${val%"${val##*[![:space:]]}"}"

      # remove optional surrounding quotes
      val="${val%\"}"; val="${val#\"}"
      val="${val%\'}"; val="${val#\'}"

      export "$key=$val"
    fi
  done < ".env"
else
  echo "Warning: .env file not found" >&2
fi

command="${1:-}"
name="${2:-}"

case "$command" in
  up)
    : "${DATABASE_URL:?DATABASE_URL is not set (put it in .env)}"
    migrate -path migrations -database "$DATABASE_URL" up
    ;;
  down)
    : "${DATABASE_URL:?DATABASE_URL is not set (put it in .env)}"
    count="${name:-1}"
    echo "Rolling back ${count} migration(s). Continue? (y/n)"
    read -r confirmation
    if [[ "$confirmation" == "y" ]]; then
      migrate -path migrations -database "$DATABASE_URL" down "$count"
    fi
    ;;
  create)
    if [[ -z "${name:-}" ]]; then
      echo "Usage: $0 create <migration_name>" >&2
      exit 2
    fi
    migrate create -ext sql -dir migrations -seq "$name"
    ;;
  *)
    echo "Usage: $0 {up|down [count]|create <name>}" >&2
    exit 2
    ;;
esac