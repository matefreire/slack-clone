#!/bin/bash
set -u

USER_NAME="${REMOTE_USER:-node}"
WORKSPACE="${WORKSPACE_FOLDER:-/workspaces/slack-clone}"

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

own() {
  local path="$1"
  [ -e "$path" ] || return 0
  run_as_root chown -R "${USER_NAME}:${USER_NAME}" "$path" || true
}

own "$WORKSPACE"
own "/home/${USER_NAME}"

NODE_UID="$(id -u "$USER_NAME" 2>/dev/null || true)"
OWNER_UID="$(stat -c '%u' "$WORKSPACE" 2>/dev/null || true)"

if [ -n "${NODE_UID}" ] && [ -n "${OWNER_UID}" ] && [ "${OWNER_UID}" != "${NODE_UID}" ]; then
  run_as_root chmod -R a+rwX "$WORKSPACE" || true
fi
