# overleaf-cep-image

Unofficial, reproducible container images for
[yu-i-i/overleaf-cep](https://github.com/yu-i-i/overleaf-cep) (Overleaf
Extended Community Edition), built in the open by GitHub Actions.

> **Not affiliated with or endorsed by Overleaf (Digital Science) or the
> maintainer of overleaf-cep.** "Overleaf" is a trademark of its owner and is
> used here only to describe what the software is.

## Images

| Image | What it is |
|---|---|
| `ghcr.io/vnc0/overleaf-cep` | Overleaf Extended CE with the full TeX Live collection (`scheme-full`) |
| `ghcr.io/vnc0/overleaf-cep-git-bridge` | The Overleaf git-bridge service, built from the same source |

Both are multi-arch (`linux/amd64`, `linux/arm64`), each architecture built
natively on its own runner. Tags are `<version>-r<revision>` (for example
`6.3.0-ext-v5.1-r1`) and `<version>`. There is no `latest`; pin by digest.

## What is built

- Source: the exact upstream commit pinned in [`upstream.env`](upstream.env).
  No patches are applied; `patches/` does not exist until one is needed.
- `overleaf-cep`: upstream's own `server-ce/Dockerfile-base`, then
  [`texlive/Dockerfile`](texlive/Dockerfile), which adds `scheme-full`
  (upstream ships `scheme-basic`, which cannot compile most real documents),
  then upstream's `server-ce/Dockerfile` on top. The first two steps are
  published as a prebuilt `base-<key>-<arch>` tag and reused until the key
  changes (a change to either Dockerfile, the mirror, or a new calendar
  month), which keeps normal builds short.
- `overleaf-cep-git-bridge`: [`git-bridge/Dockerfile`](git-bridge/Dockerfile)
  builds `services/git-bridge` from the same commit. Overleaf's published
  git-bridge image is amd64 only.
- [`scripts/build.sh`](scripts/build.sh) is the only build logic; CI and local
  builds run the same script.

## Verify an image

Every multi-arch image has a build provenance attestation signed by GitHub
Actions:

```sh
gh attestation verify oci://ghcr.io/vnc0/overleaf-cep:6.3.0-ext-v5.1-r1 --owner vnc0
```

The image labels name the source repository
(`org.opencontainers.image.source`) and the upstream commit
(`com.overleaf.ce.revision`).

## Building locally

```sh
scripts/build.sh overleaf-cep arm64      # or amd64; needs Docker, ~25 GB free
scripts/build.sh overleaf-cep-git-bridge arm64
```

## Known limits

- TeX Live is installed from a rolling CTAN mirror, so two builds of the same
  commit can differ in package versions. That is the one non-reproducible
  input; the `REVISION` number records each rebuild.
- Compiles run inside the Overleaf container, not in sandboxed containers.
  TeX Live's shell escape is restricted (`shell_escape=p`), so a document
  cannot run arbitrary commands; `\write18{touch ...}` and Lua `io.popen` were
  tested and are blocked. It can still read any file, and any other process's
  environment, that the compile user can read (`openin_any=a`; tested with
  `\input` and LuaTeX `io.open`, including `/proc/<pid>/environ` of another
  process of the same user). Treat every account as able to read the
  container's configuration and secrets, and only give accounts to people you
  trust. Sandboxed compiles need the Docker socket and are not used here.

## Updating

1. Edit `UPSTREAM_SHA` and `VERSION` in `upstream.env`, reset `REVISION` to 1
   (or bump `REVISION` to rebuild the same commit).
2. Push to `main`. The `build` workflow publishes the new tags.
3. A weekly workflow opens an issue when upstream tags a new release.

## Licence

The build files in this repository are MIT licensed ([LICENSE](LICENSE)).
The images contain software under other licences, chiefly the GNU AGPL-3.0
for Overleaf; see [NOTICE.md](NOTICE.md). The corresponding source for any
image is the upstream commit named in its labels plus the files in this
repository at the tagged revision.
