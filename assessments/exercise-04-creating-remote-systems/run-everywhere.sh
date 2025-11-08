#!/usr/bin/env bash
#
# run-everywhere.sh
# Execute the given command on every server listed in a server file.
# Default server list: /vagrant/servers
#
# Usage: ./run-everywhere.sh [-nsv] [-f FILE] COMMAND
# See the usage() function below for text displayed on error.
#

set -o pipefail    # pipeline returns non-zero if any component fails
# (we do NOT enable -u because we want to show friendly messages for missing args)

SERVER_LIST="/vagrant/servers"
DRY_RUN=false
USE_SUDO=false
VERBOSE=false

usage() {
  cat >&2 <<'USAGE'
Usage: ./run-everywhere.sh [-nsv] [-f FILE] COMMAND
Executes COMMAND as a single command on every server.
  -f FILE  Use FILE for the list of servers. Default: /vagrant/servers.
  -n       Dry run mode. Display the COMMAND that would have been executed and exit.
  -s       Execute the COMMAND using sudo on the remote server.
  -v       Verbose mode. Displays the server name before executing COMMAND.
USAGE
}

# --- Enforce: do NOT run this script as root locally ---
if [[ "$(id -u)" -eq 0 ]]; then
  echo "Do not execute this script as root. Use the -s option to run remote commands with sudo." >&2
  usage
  exit 1
fi

# --- Parse options ---
while getopts ":f:nsv" opt; do
  case "${opt}" in
    f)
      SERVER_LIST="${OPTARG}"
      ;;
    n)
      DRY_RUN=true
      ;;
    s)
      USE_SUDO=true
      ;;
    v)
      VERBOSE=true
      ;;
    \?)
      echo "Illegal option -- ${OPTARG}" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

# Remove parsed options; the rest is the command to run
shift $((OPTIND - 1))

# If no command supplied -> usage (stderr) and exit 1
if [[ "$#" -lt 1 ]]; then
  usage
  exit 1
fi

# Compose the command to run on remote host as a single string.
# We preserve arguments/quoting by using "$@" when building the variable.
# Using printf %q would attempt to shell-escape, but SSH remote needs the exact string.
REMOTE_CMD="$*"

# Confirm server list file exists and is readable
if [[ ! -r "${SERVER_LIST}" ]]; then
  echo "Cannot open server list file ${SERVER_LIST}." >&2
  exit 1
fi

# Track the final exit status: 0 or most recent non-zero ssh exit
final_exit=0

# Read each server (skip blank lines and comments)
while IFS= read -r server || [[ -n "$server" ]]; do
  # Trim leading/trailing whitespace
  server="${server%%[[:space:]]}"    # remove trailing
  server="${server##[[:space:]]}"    # remove leading
  # Skip blank or comment lines
  [[ -z "${server}" || "${server:0:1}" == "#" ]] && continue

  ssh_cmd=( ssh -o ConnectTimeout=2 "${server}" )

  # If user wants sudo on remote, prepend sudo on the remote side
  if [[ "${USE_SUDO}" == true ]]; then
    # Note: we pass the command as a single argument to ssh so remote shell interprets it correctly.
    full_cmd="sudo ${REMOTE_CMD}"
  else
    full_cmd="${REMOTE_CMD}"
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    # Dry run: display what we WOULD run
    echo "DRY RUN: ${ssh_cmd[*]} ${full_cmd}"
    continue
  fi

  # Verbose: print server name before running (exact behavior from exercise)
  if [[ "${VERBOSE}" == true ]]; then
    echo "${server}"
  fi

  # Execute: use ssh and capture exit status
  # Use -- to guard against commands that start with hyphen
  "${ssh_cmd[@]}" -- "${full_cmd}"
  ssh_exit=$?

  if [[ ${ssh_exit} -ne 0 ]]; then
    echo "Execution on ${server} failed." >&2
    final_exit=${ssh_exit}
  fi

done < "${SERVER_LIST}"

exit ${final_exit}

