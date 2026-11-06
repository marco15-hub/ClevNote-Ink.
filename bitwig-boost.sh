#!/usr/bin/env bash
# Temporarily select Windows' existing High Performance power plan.
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  printf '%s\n' 'Usage: bash bitwig-boost.sh' \
    'Run in Git Bash on Windows, then start Bitwig Studio.' \
    'After closing Bitwig, press Enter to restore your previous power plan.'
  exit 0
fi
if (( $# )); then
  printf 'Unknown argument: %s\n' "$1" >&2
  exit 2
fi

case "$(uname -s)" in
  MINGW*|MSYS*) ;;
  *) printf '%s\n' 'Run this script in Git Bash on Windows.' >&2; exit 1 ;;
esac

if ! command -v powercfg.exe >/dev/null 2>&1; then
  printf '%s\n' 'Windows powercfg.exe was not found.' >&2
  exit 1
fi

powercfg() {
  # Keep Git Bash from converting Windows switches such as /setactive to paths.
  MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' powercfg.exe "$@"
}

guid_pattern='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
high_performance='8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
switched=0

if ! current_output=$(powercfg /getactivescheme); then
  printf '%s\n' 'Could not read the active power plan. No changes were made.' >&2
  exit 1
fi
if [[ ${current_output,,} =~ $guid_pattern ]]; then
  original_plan=${BASH_REMATCH[0]}
else
  printf '%s\n' 'Could not identify the active power plan. No changes were made.' >&2
  exit 1
fi

if ! plans=$(powercfg /list); then
  printf '%s\n' 'Could not list power plans. No changes were made.' >&2
  exit 1
fi
if [[ ${plans,,} != *"$high_performance"* ]]; then
  printf '%s\n' 'The High Performance power plan is not available. No changes were made.' >&2
  exit 1
fi

restore_plan() {
  if (( ! switched )); then return 0; fi
  switched=0
  if ! current_output=$(powercfg /getactivescheme) || [[ ! ${current_output,,} =~ $guid_pattern ]]; then
    printf 'Could not check the current plan. Restore manually with: powercfg /setactive %s\n' "$original_plan" >&2
    return 1
  fi
  if [[ ${BASH_REMATCH[0]} != "$high_performance" ]]; then
    printf '%s\n' 'The power plan changed during the session; leaving the current plan in place.'
    return 0
  fi
  if ! powercfg /setactive "$original_plan"; then
    printf 'Could not restore the previous plan. Run: powercfg /setactive %s\n' "$original_plan" >&2
    return 1
  fi
  printf '%s\n' 'Previous power plan restored.'
}

trap 'restore_plan' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

if [[ $original_plan == "$high_performance" ]]; then
  printf '%s\n' 'High Performance is already active; the power plan will not be changed.'
else
  printf 'Previous power plan: %s\n' "$original_plan"
  printf 'If the script is interrupted unexpectedly, restore it with: powercfg /setactive %s\n' "$original_plan"
  if ! powercfg /setactive "$high_performance"; then
    printf '%s\n' 'Could not activate High Performance.' >&2
    exit 1
  fi
  switched=1
  printf '%s\n' 'High Performance is active for this session.'
fi

printf '%s\n' \
  'Open Bitwig Studio and use it as usual.' \
  'For audio dropouts, try a larger audio buffer in Bitwig settings.' \
  'After closing Bitwig, press Enter here to finish.'
read -r _ || true
restore_plan
