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

No signup. No account. Just SSH.

| What it looks like | Example |
|---|---|
| `ssh robert@4.4bsd.dev` | An AI that teaches you FreeBSD |
| `ssh mud@example.com` | A multiplayer roguelike or MUD |
| `ssh paste@example.com` | A terminal-based paste service |
| `ssh status@example.com` | Live dashboards, weather, train times |
| `ssh play@example.com` | Games, puzzles, interactive fiction |

## Commands

#### Bootstrap

> anon bootstrap [OPTIONS]

Bootstraps a new jail.

Options:

| Option | Description |
|---|---|
| `-p PATH` | The jail location |
| `-b BINARY` | The program to serve over sshd |
| `-u USER` | The username that logs into ssh |

#### Serve

> anon serve [OPTIONS]

Serves a new jail running sshd.

Options:

| Option | Description |
|---|---|
| `-n NAME` | The jail name |
| `-p PATH` | The jail location |


## Environment

#### Network

For simplicity, the jail shares the host network and inherits its IPv4
address. The jail's sshd binds to port 22 for standard SSH access. The
host should run its own sshd on a different port (like 2222) so it
doesn't conflict.

## License

0BSD.
