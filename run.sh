#!/usr/bin/env -S bash

set -e
set -a
set -x

export TARGET_REPO="${1}"
export TARGET_CHART="${2}"
export TARGET_CHART_VERSION="${3}"
export INPUT_FILES="${4}"
export COMMIT_MESSAGE="${5}"
export PR_TITLE="${6}"
export AUTHOR="${7}"

export REPO="$(pwd)"
export TMP="$(mktemp -d)"

function cleanup {
  rm -rf "${TMP}"
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

  templates="${TARGET_CHART}/templates"
  mkdir -p "${templates}"
  cp "${REPO}/"${INPUT_FILES} "${templates}"

  chart="${TARGET_CHART}/Chart.yaml"
  current_version=$(grep "^version:" "${chart}" | awk '{print $2}')
  sed -i "s/^version: .*/version: ${TARGET_CHART_VERSION}/" "${chart}"

  git add .
  git commit -m "${COMMIT_MESSAGE}"
  git push --force origin chore-move-crds

  if [ -z "${prs}" ] || [ "${prs}" -eq 0 ]; then
    gh pr create --title="${PR_TITLE}" --body="# 🤖 Beep-boop, moving CRDs"
  fi
}

trap cleanup EXIT
main
