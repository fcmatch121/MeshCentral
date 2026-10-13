#!/usr/bin/env bash
# Builds the fork release assets: portable bundles (tar.gz/zip), Docker image archive, manual, checksums.
# Usage: .github/scripts/package-release.sh <version> <output-dir>
set -euo pipefail

VERSION="${1:?version required}"
OUT="$(mkdir -p "${2:?output dir required}" && cd "$2" && pwd)"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NAME="stressman-${VERSION}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

echo "==> Staging ${NAME}"
mkdir -p "$STAGE/$NAME/meshcentral"
rsync -a \
  --exclude '.git' --exclude '.github' --exclude 'node_modules' \
  --exclude 'docker' --exclude 'docs' \
  "$ROOT/" "$STAGE/$NAME/meshcentral/"
cp "$ROOT/docs/fork-release/MANUAL-ko.md" "$STAGE/$NAME/MANUAL-ko.md"
cp "$ROOT/sample-config.json" "$STAGE/$NAME/config.sample.json"

echo "==> Installing production dependencies"
(cd "$STAGE/$NAME/meshcentral" && npm ci --omit=dev --no-audit --no-fund)

echo "==> Creating portable archives"
tar -C "$STAGE" -czf "$OUT/${NAME}.tar.gz" "$NAME"
(cd "$STAGE" && zip -qr "$OUT/${NAME}.zip" "$NAME")

echo "==> Building Docker image"
docker build -f "$ROOT/docker/Dockerfile" -t "stressman:${VERSION}" "$ROOT"
docker save "stressman:${VERSION}" | gzip > "$OUT/${NAME}-docker-image.tar.gz"

cp "$ROOT/docs/fork-release/MANUAL-ko.md" "$OUT/StressMan-${VERSION}-Manual-ko.md"

echo "==> Checksums"
(cd "$OUT" && sha256sum "${NAME}.tar.gz" "${NAME}.zip" "${NAME}-docker-image.tar.gz" "StressMan-${VERSION}-Manual-ko.md" > SHA256SUMS.txt && cat SHA256SUMS.txt)
