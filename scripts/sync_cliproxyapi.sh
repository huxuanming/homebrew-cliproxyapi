#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA_PATH="${FORMULA_PATH:-${ROOT_DIR}/Formula/cliproxyapi.rb}"
REPO="${REPO:-router-for-me/CLIProxyAPI}"

if [[ ! -f "${FORMULA_PATH}" ]]; then
  echo "Formula file not found: ${FORMULA_PATH}" >&2
  exit 1
fi

json="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")"
latest_tag="$(printf '%s\n' "${json}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
if [[ -z "${latest_tag}" ]]; then
  echo "Failed to parse latest tag from GitHub API response." >&2
  exit 1
fi

new_url="https://github.com/${REPO}/archive/refs/tags/${latest_tag}.tar.gz"
new_sha256="$(curl -fL "${new_url}" | shasum -a 256 | awk '{print $1}')"
if [[ -z "${new_sha256}" ]]; then
  echo "Failed to calculate sha256 for ${new_url}." >&2
  exit 1
fi

current_url="$(sed -n 's/^  url "\(.*\)"/\1/p' "${FORMULA_PATH}" | head -n1)"
current_sha="$(sed -n 's/^  sha256 "\(.*\)"/\1/p' "${FORMULA_PATH}" | head -n1)"

if [[ "${current_url}" == "${new_url}" && "${current_sha}" == "${new_sha256}" ]]; then
  echo "No update needed: already at ${latest_tag}"
  exit 0
fi

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

awk -v url="${new_url}" -v sha="${new_sha256}" '
  /^  url "/ { print "  url \"" url "\""; next }
  /^  sha256 "/ { print "  sha256 \"" sha "\""; next }
  { print }
' "${FORMULA_PATH}" > "${tmp_file}"

mv "${tmp_file}" "${FORMULA_PATH}"
trap - EXIT

echo "Updated ${FORMULA_PATH}"
echo "  tag:    ${latest_tag}"
echo "  url:    ${new_url}"
echo "  sha256: ${new_sha256}"
