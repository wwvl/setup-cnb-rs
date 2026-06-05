#!/usr/bin/env bash
# Setup cnb-rs for GitHub Actions (Linux / macOS)
#
# Expected environment variables:
#   CNB_RS_VERSION  - version to install (e.g. v1.0.0-alpha.1)
#   CNB_RS_SOURCE   - download source: cnb (default) or github
#   CNB_RS_BIN_DIR  - directory to install the binary to

set -euo pipefail

version="${CNB_RS_VERSION:?CNB_RS_VERSION is required}"
source="${CNB_RS_SOURCE:-cnb}"
bin_dir="${CNB_RS_BIN_DIR:?CNB_RS_BIN_DIR is required}"

cnb_endpoint="${CNB_RS_CNB_ENDPOINT:-https://cnb.cool}"
cnb_repo_slug="wwvo/cnb-rs/cnb-rs"
github_endpoint="https://github.com"
github_repo_slug="wwvo/cnb-rs"


# ── Normalize version ───────────────────────────────────────────
[[ "$version" == v* ]] || version="v${version}"

# ── Detect platform ─────────────────────────────────────────────
os_name="$(uname -s)"
arch_name="$(uname -m)"

case "$os_name" in
  Linux)
    case "$arch_name" in
      x86_64|amd64)  target="x86_64-unknown-linux-musl" ;;
      aarch64|arm64) target="aarch64-unknown-linux-musl" ;;
      *) echo "::error::Unsupported Linux architecture: ${arch_name}"; exit 1 ;;
    esac
    ;;
  Darwin)
    case "$arch_name" in
      x86_64|amd64)  target="x86_64-apple-darwin" ;;
      aarch64|arm64) target="aarch64-apple-darwin" ;;
      *) echo "::error::Unsupported macOS architecture: ${arch_name}"; exit 1 ;;
    esac
    ;;
  *)
    echo "::error::Unsupported operating system: ${os_name}"
    exit 1
    ;;
esac

# ── Build download URL ──────────────────────────────────────────
case "$source" in
  cnb)
    base_url="${cnb_endpoint}/${cnb_repo_slug}/-/releases/download/${version}"
    ;;
  github)
    base_url="${github_endpoint}/${github_repo_slug}/releases/download/${version}"
    ;;
  *)
    echo "::error::Unsupported download source: ${source} (expected: cnb or github)"
    exit 1
    ;;
esac

asset_name="cnb-rs-${version}-${target}.tar.gz"
archive_url="${base_url}/${asset_name}"
checksum_url="${base_url}/sha256sum.txt"

# ── Download ────────────────────────────────────────────────────
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "::group::Download cnb-rs ${version} (${target})"

echo "Downloading ${archive_url}"
curl -fsSL -o "${tmp_dir}/${asset_name}" "$archive_url"

echo "Downloading sha256sum.txt"
curl -fsSL -o "${tmp_dir}/sha256sum.txt" "$checksum_url"

# ── Verify checksum ─────────────────────────────────────────────
expected="$(awk -v name="$asset_name" '$2 == name { print $1 }' "${tmp_dir}/sha256sum.txt" | head -n 1)"

if [[ -n "$expected" ]]; then
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "${tmp_dir}/${asset_name}" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "${tmp_dir}/${asset_name}" | awk '{print $1}')"
  else
    echo "::warning::No SHA-256 tool available; skipping checksum verification"
    actual="$expected"
  fi

  expected_lower="$(printf '%s' "$expected" | tr '[:upper:]' '[:lower:]')"
  actual_lower="$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')"

  if [[ "$actual_lower" != "$expected_lower" ]]; then
    echo "::error::SHA-256 checksum mismatch for ${asset_name}"
    echo "  expected: ${expected_lower}"
    echo "  actual:   ${actual_lower}"
    exit 1
  fi
  echo "Verified SHA-256 checksum"
else
  echo "::warning::No checksum entry found for ${asset_name} in sha256sum.txt"
fi

# ── Extract and install ─────────────────────────────────────────
mkdir -p "${tmp_dir}/extract"
tar -xzf "${tmp_dir}/${asset_name}" -C "${tmp_dir}/extract"

binary_path="${tmp_dir}/extract/cnb-rs-${version}-${target}/cnb-rs"
if [[ ! -f "$binary_path" ]]; then
  binary_path="$(find "${tmp_dir}/extract" -type f -name cnb-rs | head -n 1)"
fi

if [[ -z "${binary_path:-}" || ! -f "$binary_path" ]]; then
  echo "::error::Failed to locate cnb-rs binary in the extracted archive"
  exit 1
fi

mkdir -p "$bin_dir"
install -m 755 "$binary_path" "${bin_dir}/cnb-rs"

echo "::endgroup::"
