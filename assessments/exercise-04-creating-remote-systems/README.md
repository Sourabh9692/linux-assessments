# Exercise 04 – Creating / Managing Remote Systems

## Objective
Automate running a command or script across multiple remote Linux systems using SSH.

## Files Included
- `run-everywhere.sh` — Script to loop through a list of remote hosts and execute a command/script.
- `document.pdf` — Problem description & explanation.
- `host_list.txt` — (you create this) one host per line: `user@host` or `host` (uses current user).

## Prerequisites
- Passwordless SSH (recommended): generate and copy your public key to targets.
  ```sh
  ssh-keygen -t ed25519 -C "you@example.com"
  ssh-copy-id user@host1
  ssh-copy-id user@host2

