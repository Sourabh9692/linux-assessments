#!/bin/bash
# add-local-user.sh - Script to add a new local user account.

# 1. Ensure the script is run as root
if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run with sudo or as root." >&2
  exit 1
fi

# 2. Prompt for account details
read -p "Enter the username to create: " USER_NAME
read -p "Enter the name of the person or application using this account: " COMMENT
read -s -p "Enter the password to use for the account: " PASSWORD
echo

# 3. Validate inputs
if [[ -z "$USER_NAME" || -z "$PASSWORD" ]]; then
  echo "Username and password cannot be empty." >&2
  exit 1
fi

# 4. Create the user with home directory and description
if ! useradd -m -c "$COMMENT" "$USER_NAME"; then
  echo "Account could not be created. Exiting." >&2
  exit 1
fi

# 5. Set the password
if ! echo "${USER_NAME}:${PASSWORD}" | chpasswd; then
  echo "Password could not be set. Exiting." >&2
  exit 1
fi

# 6. Force password change on first login
if ! passwd -e "$USER_NAME"; then
  echo "Could not expire password. Exiting." >&2
  exit 1
fi

# 7. Display account information
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
