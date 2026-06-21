<p align="center">
  <img width=400 height=200 src="4.4bsd.svg">
</p>

anonssh builds a mini jail on FreeBSD, and its forks.

It can be used to launch terminal-based applications in a
constrained environment that has nothing other than your
application, and its runtime dependencies. The application
can be accessed over a publically accessible sshd instance.

The jail includes only the files needed to run a single program
behind sshd. <br> The sshd instance locks the user into the given
program via `ForceCommand`. 

## Quick start

#### bootstrap

Bootstraps a mini-jail with only what your program needs. <br>
This command will discover shared libraries, set up device nodes,
generate SSH host keys, and only install the dependencies your
program needs.

```
anonssh bootstrap -p /path/to/jail -b /path/to/binary
```

Options:

| Option | Description |
|---|---|
| `-p PATH` | Jail root directory |
| `-b BINARY` | The program to run over SSH |
| `-u USER` | SSH username (default: anonssh) |
| `-f FILE` | File listing extra files to copy into the jail (one per line) |

#### serve

Starts the jail with sshd running. <br>
The jail inherits the host network and binds sshd to port 22.

```
anonssh serve -n jailname -p /path/to/jail
```

Options:

| Option | Description |
|---|---|
| `-n NAME` | Jail name |
| `-p PATH` | Jail root directory |

## Network

The jail shares the host network stack (`ip4: inherit`) and its sshd
binds to port 22. The host should run its own sshd on a different port
(such as 2222) to avoid conflicts.

## Build

Prerequisites: an mruby checkout in a sibling `../mruby` directory.

```
make
make install
```

## License

0BSD.
