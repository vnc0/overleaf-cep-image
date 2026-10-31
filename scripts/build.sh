#!/usr/bin/env bash
# Build one image for one architecture, natively (no emulation).
#
#   scripts/build.sh <overleaf-cep|overleaf-cep-git-bridge> <amd64|arm64> [--push]
#
# Used by CI and runnable locally. Reads upstream.env, fetches the pinned
# upstream commit, builds, and optionally pushes <registry>/<image>:<tag>-<arch>.
set -euo pipefail

image="${1:?usage: build.sh <overleaf-cep|overleaf-cep-git-bridge> <amd64|arm64> [--push]}"
arch="${2:?missing arch}"
push="${3:-}"

HERE="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
. "$HERE/upstream.env"

REGISTRY="${REGISTRY:-ghcr.io/vnc0}"
TAG="${VERSION}-r${REVISION}"
PLATFORM="linux/${arch}"
SOURCE_URL="${SOURCE_URL:-https://github.com/vnc0/overleaf-cep-image}"

SRC="${UPSTREAM_DIR:-$(mktemp -d)}"
if [ ! -d "$SRC/.git" ]; then
  git init -q "$SRC"
  git -C "$SRC" fetch -q --depth 1 "https://github.com/${UPSTREAM_REPO}.git" "$UPSTREAM_SHA"
  git -C "$SRC" checkout -q FETCH_HEAD
fi
[ "$(git -C "$SRC" rev-parse HEAD)" = "$UPSTREAM_SHA" ] || { echo "upstream checkout is not $UPSTREAM_SHA" >&2; exit 1; }

labels=(
  --label "org.opencontainers.image.source=${SOURCE_URL}"
  --label "org.opencontainers.image.version=${TAG}"
  --label "org.opencontainers.image.licenses=AGPL-3.0-only"
  --label "org.opencontainers.image.authors=https://github.com/vnc0"
  --label "com.overleaf.ce.upstream=https://github.com/${UPSTREAM_REPO}"
  --label "com.overleaf.ce.revision=${UPSTREAM_SHA}"
)
out="${REGISTRY}/${image}:${TAG}-${arch}"

# Upstream's yarn step fetches git dependencies and builds them against the npm
# registry, which fails sporadically on CI runners. Layers that succeeded are
# cached, so a retry only repeats the failed step.
build() {
  local n
  for n in 1 2 3; do
    docker build "$@" && return 0
    echo "docker build failed (attempt $n/3)" >&2
    sleep 20
  done
  return 1
}

case "$image" in
  overleaf-cep)
    cd "$SRC"
    cp server-ce/.dockerignore .dockerignore
    build --platform "$PLATFORM" --pull --progress=plain \
      -f server-ce/Dockerfile-base -t "overleaf-cep-base:${TAG}-${arch}" .
    build --platform "$PLATFORM" --progress=plain \
      -f server-ce/Dockerfile \
      --build-arg "OVERLEAF_BASE_TAG=overleaf-cep-base:${TAG}-${arch}" \
      -t "overleaf-cep-core:${TAG}-${arch}" .
    build --platform "$PLATFORM" --progress=plain \
      -f "$HERE/texlive/Dockerfile" \
      --build-arg "BASE_IMAGE=overleaf-cep-core:${TAG}-${arch}" \
      --build-arg "TEXLIVE_MIRROR=${TEXLIVE_MIRROR}" \
      --label "org.opencontainers.image.title=Overleaf Extended CE (unofficial)" \
      --label "org.opencontainers.image.description=Unofficial build of ${UPSTREAM_REPO} with full TeX Live. Not affiliated with Overleaf." \
      "${labels[@]}" -t "$out" "$HERE/texlive"
    ;;
  overleaf-cep-git-bridge)
    build --platform "$PLATFORM" --progress=plain \
      -f "$HERE/git-bridge/Dockerfile" \
      --label "org.opencontainers.image.title=Overleaf git-bridge (unofficial)" \
      --label "org.opencontainers.image.description=git-bridge from ${UPSTREAM_REPO}, built for amd64 and arm64. Not affiliated with Overleaf." \
      "${labels[@]}" -t "$out" "$SRC/services/git-bridge"
    ;;
  *) echo "unknown image: $image" >&2; exit 2 ;;
esac

echo "built $out"
[ "$push" = "--push" ] && docker push "$out"
exit 0
