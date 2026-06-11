<p align="center">
  <img width=150 height=150 src="anon.png">
</p>

Anon gives you a single `ssh` command that drops users straight into a
terminal application — no signup, no account required, publicly
accessible via SSH.

It builds a locked-down FreeBSD jail from source, populates it with only
what's needed to run your program behind sshd, and handles the SSH
configuration so the user's session is forced directly into your app via
`ForceCommand`. No shell access, no escape, minimal attack surface.

## Scenarios

| What it looks like | Example |
|---|---|
| `ssh robert@4.4bsd.dev` | An AI that teaches you FreeBSD |
| `ssh mud@example.com` | A multiplayer roguelike or MUD |
| `ssh paste@example.com` | A terminal-based paste service |
| `ssh status@example.com` | Live dashboards, weather, train times |
| `ssh play@example.com` | Games, puzzles, interactive fiction |

No signup. No account. Just SSH.

## How it works

Anon compiles into two static binaries via mruby (about 3MB each, zero
runtime dependencies):

- **`anon`** — a dispatch command that runs `bootstrap`.
- **`bootstrap`** — does the actual work: creates the jail directory
  tree, resolves shared libraries for the target binary and sshd and
  copies them in, generates config files from templates, and creates
  the user account.

The jail contains `/bin/sh` but virtually no programs — just sshd and
your program. Probably around 1% of what a normal FreeBSD install ships.

## Network

For simplicity, the jail shares the host network and inherits its IPv4
address. The jail's sshd binds to port 22 for standard SSH access. The
host should run its own sshd on a different port (like 2222) so it
doesn't conflict.

## Quick start

```sh
git clone https://git.home.network/0x1eef/anon.git
cd anon
make
./bin/anon bootstrap -p /usr/local/jails/myapp -b /path/to/program -u appuser
```

Then point sshd at the jail, and `ssh appuser@host` lands in your app.

## Configuration

Config files live in `share/anon/etc/` and use `.tt` templates for
values like the username and binary path. They're copied into the jail
as-is after template substitution. Modify `rc.conf` or add your own
files there before building.

## Future

`anon serve` will spawn a jail directly — creating it, starting sshd
inside, and managing the lifecycle in one command.

## License

0BSD.
