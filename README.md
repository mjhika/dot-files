## Usage

Everything deploys through `./dot`, driven by the `manifest` file
(`repo-path -> $HOME target`, with optional per-OS filters for
macOS / Linux / FreeBSD).

```sh
git clone https://github.com/mjhika/dot-files && cd dot-files

./dot install          # symlink every manifest entry into $HOME (backs up what's there)
./dot install -m copy  # copy instead, for hosts where the clone won't stick around
./dot install -n       # dry run
./dot check            # per-entry state: linked / copy / drifted / missing
./dot doctor           # healthcheck: core tools, languages, PATH + env sanity
```

`dot` is POSIX sh so it runs on a bare box before any of these configs exist.
