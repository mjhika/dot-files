## Usage

Everything deploys through `./dot`, driven by the `manifest` file
(`repo-path -> $HOME target`, with optional per-OS filters for
macOS / Linux / FreeBSD and profiles: `full` for a dev machine,
`server` for a minimal bashrc + vimrc + tmux.conf kit).

```sh
git clone https://github.com/mjhika/dot-files && cd dot-files

./dot install          # symlink every manifest entry into $HOME (backs up what's there)
./dot install -m copy  # copy instead, for hosts where the clone won't stick around
./dot install -n       # dry run
./dot check            # per-entry state: linked / copy / drifted / missing
./dot doctor           # healthcheck: core tools, languages, PATH + env sanity
```

Quick server setup:

```sh
git clone --depth 1 https://github.com/mjhika/dot-files && cd dot-files
./dot install -p server  # just .bashrc, .vimrc, .tmux.conf
./dot doctor -p server   # server-baseline healthcheck only
```

`dot` is POSIX sh so it runs on a bare box before any of these configs exist.
