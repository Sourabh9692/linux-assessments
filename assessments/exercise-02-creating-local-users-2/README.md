# Exercise 03 – Creating Local Users (Script 2)

A POSIX **sh** version of `add-new-local-user.sh` that:
- Must be run as root
- Takes username & comment from arguments
- Auto-generates a strong password
- Creates the user, sets password, forces change on first login
- Prints username, password, and host

## Usage
```sh
chmod 755 add-new-local-user.sh
sudo ./add-new-local-user.sh USER_NAME [COMMENT]...
```

## Examples (from the assessment)
```sh
sudo ./add-new-local-user.sh jlocke "John Locke"
sudo ./add-new-local-user.sh brussell "Bertrand Russell"
sudo ./add-new-local-user.sh philapp "Philosophy Application User"
```

### Expected transcript (your generated password will differ)
```
$ sudo ./add-new-local-user.sh jlocke "John Locke"
username:
jlocke

password:
<64-hex-chars>

host:
localusers
```

## Verify
```sh
tail -n 3 /etc/passwd
# ... expect entries for jlocke, brussell, philapp

su - jlocke   # will force a new password on first login
exit
```

---

*Prepared on 2025-10-19*
