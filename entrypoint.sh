#!/bin/sh

set -e

mkdir -p /home/runner/work/_temp ; 

if [ -n "$NPM_AUTH_TOKEN" ]; then
  # Respect NPM_CONFIG_USERCONFIG if it is provided, default to $HOME/.npmrc
  NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG-"$HOME/.npmrc"}"
  NPM_REGISTRY="${NPM_REGISTRY}"
  NPM_REGISTRY_URL="$NPM_REGISTRY_SCHEME://$NPM_REGISTRY"
  NPM_STRICT_SSL="${NPM_STRICT_SSL-true}"
  NPM_REGISTRY_SCHEME="https"
  
  # Allow registry.npmjs.org to be overridden with an environment variable
  printf "//%s/:_authToken=%s\\nregistry=%s\\nstrict-ssl=%s" "$NPM_REGISTRY" "$NPM_AUTH_TOKEN" "$NPM_REGISTRY_URL" "$NPM_STRICT_SSL" > "$NPM_CONFIG_USERCONFIG"
  echo "$(cat /home/runner/work/_temp/.npmrc)"
fi

# initialize git
remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git config http.sslVerify false
git config user.name "Merge Release"
git config user.email "actions@users.noreply.github.com"
git remote add merge-release "${remote_repo}"
git remote --verbose
git show-ref # useful for debugging
git branch --verbose

if [ "$GITHUB_REPOSITORY" = "mikeal/merge-release" ]
then
  echo "node merge-release-run.js"
  sh -c "node merge-release-run.js $*"
else
  echo "npx merge-release"
  sh -c "npx merge-release $*"
fi
git push "${remote_repo}" --tags
