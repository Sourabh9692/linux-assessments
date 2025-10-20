#!/bin/sh
# add-new-local-user.sh - Create a local user non-interactively (POSIX sh)

# 1) Enforce superuser
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run with sudo or as root." >&2
  exit 1
fi

# 2) Usage
usage() {
  echo "Usage: $0 USER_NAME [COMMENT]..." >&2
  echo "Create an account on the local system with the name of USER_NAME and a" >&2
  echo "comments field of COMMENT." >&2
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

USER_NAME="$1"
shift
COMMENT="$*"

# 3) Generate a strong password (64 hex chars)
PASSWORD="$(head -c 32 /dev/urandom | sha256sum | awk '{print $1}')"

# 4) Create the user with home and comment
if ! useradd -m -c "$COMMENT" "$USER_NAME" >/dev/null 2>&1; then
  echo "The account for '$USER_NAME' could not be created." >&2
  exit 1
fi

# 5) Set the password
if ! printf "%s:%s\n" "$USER_NAME" "$PASSWORD" | chpasswd >/dev/null 2>&1; then
  echo "The password for '$USER_NAME' could not be set." >&2
  exit 1
fi

# 6) Force password change at first login
if ! passwd -e "$USER_NAME" >/dev/null 2>&1; then
  echo "Could not expire the password for '$USER_NAME'." >&2
  exit 1
fi

# 7) Output results
HOSTNAME_NOW="$(hostname)"
echo
echo "username:"
echo "$USER_NAME"
echo
echo "password:"
echo "$PASSWORD"
echo
echo "host:"
echo "$HOSTNAME_NOW"
