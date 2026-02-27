#!/bin/sh
set -eu

UNLOCK_REPO="${UNLOCK_REPO:-vithorcoelho/chatwoot-unlock}"
UNLOCK_REF="${UNLOCK_REF:-main}"
BASE_URL="https://raw.githubusercontent.com/${UNLOCK_REPO}/${UNLOCK_REF}"

download_file() {
  url="$1"
  dst_path="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${url}" -o "${dst_path}"
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "${dst_path}" "${url}"
    return 0
  fi

  echo "[unlock] neither curl nor wget is available" >&2
  exit 1
}

copy_file() {
  rel_path="$1"
  dst_path="/app/${rel_path}"
  tmp_file="/tmp/$(basename "$rel_path").unlock"

  echo "[unlock] downloading ${BASE_URL}/${rel_path}"
  download_file "${BASE_URL}/${rel_path}" "${tmp_file}"

  mkdir -p "$(dirname "$dst_path")"
  cp "${tmp_file}" "${dst_path}"
  rm -f "${tmp_file}"

  echo "[unlock] applied ${dst_path}"
}

copy_file "app/views/super_admin/settings/show.html.erb"
copy_file "db/seeds.rb"

echo "[unlock] done"
