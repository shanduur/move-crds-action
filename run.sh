#!/usr/bin/env -S bash

set -e
set -a
set -x

export TARGET_REPO="${1}"
export TARGET_DIR="${2}"
export TARGET_CHART="${3}"
export TARGET_CHART_VERSION="${4}"
export INPUT_FILES="${5}"
export COMMIT_MESSAGE="${6}"
export PR_TITLE="${7}"
export AUTHOR="${8}"

export REPO="$(pwd)"
export TMP="$(mktemp -d)"

function cleanup {
  rm -rf "${TMP}"
}

function patch() {
  current_version=$(grep "^version:" "${TARGET_CHART}" | awk '{print $2}')

  sed -i "s/^version: .*/version: ${TARGET_CHART_VERSION}/" "${TARGET_CHART}"
}

function main {
  gh repo clone "${TARGET_REPO}" "${TMP}"

  cd "${TMP}"
  git config "url.https://oauth2:${GH_TOKEN}@github.com/.insteadOf" https://github.com/

  prs=$(gh pr list --json=state,number --state=open --author="${AUTHOR}" --jq='.[].number | length')

  if [ -z "${prs}" ] || [ "${prs}" -eq 0 ]; then
    git checkout -B chore-move-crds
  else
    id=$(gh pr list --json=state,number --state=open --author="${AUTHOR}" --jq='.[].number')
    gh pr checkout "${id}"
  fi

  mkdir -p "${TARGET_DIR}"

  cp "${REPO}/"${INPUT_FILES} "${TARGET_DIR}"

  git add .
  git commit -m "${COMMIT_MESSAGE}"
  git push --force origin chore-move-crds

  if [ -z "${prs}" ] || [ "${prs}" -eq 0 ]; then
    gh pr create --title="${PR_TITLE}" --body="# 🤖 Beep-boop, moving CRDs"
  fi
}

trap cleanup EXIT
main
