#!/bin/sh
set -eu

UNLOCK_REPO="${UNLOCK_REPO:-vithorcoelho/chatwoot-unlock}"
UNLOCK_REF="${UNLOCK_REF:-main}"
BASE_URL="https://raw.githubusercontent.com/${UNLOCK_REPO}/${UNLOCK_REF}"

copy_file() {
  rel_path="$1"
  dst_path="/app/${rel_path}"
  tmp_file="/tmp/$(basename "$rel_path").unlock"

  echo "[unlock] downloading ${BASE_URL}/${rel_path}"
  curl -fsSL "${BASE_URL}/${rel_path}" -o "${tmp_file}"

  mkdir -p "$(dirname "$dst_path")"
  cp "${tmp_file}" "${dst_path}"
  rm -f "${tmp_file}"

  echo "[unlock] applied ${dst_path}"
}

copy_file "app/views/super_admin/settings/show.html.erb"
copy_file "db/seeds.rb"

echo "[unlock] done"
