# revoke-ssh-keys

## About this

This is a shell script you run, with a list of servers

Example:

```
revoke-ssh-key.sh mycomputer.company.com server.nonprofit.org othercomputer.government.biz
```

## Assumptions

This tool will:

* Assume you've already removed the key from web apps like Google Compute Engine and GitHub, and

* Assume you have a bad old key in `~/.ssh/id_rsa_old` and `~/.ssh/id_rsa_old.pub`, and

* Assume the old key is still in `ssh-agent` (you can add it if not), and

* Assume you have generated a new key in `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`.

## Actions

* It will check if the machine in question has your _new_ key, and
* If so, it will remove the old key, and
* If it doesn't have the new key, it'll add it.

## Dry-runnable

```
export DRY_RUN=yes
```

## License

GPLv2 or later, at your option.

(C) 2015 Asheesh Laroia