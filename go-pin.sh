#!/bin/bash
ROOT="$GOPATH/src"
NAME=$0
ACTION=${1-help}

function freeze_git() {
  cd "$ROOT"
  find . -type d -iname ".git" | sort | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    REV=$(git rev-parse HEAD)
    URI=$(git config --get remote.origin.url)
    IMPORT=$(echo $repo | cut -c3- | rev | cut -c6- | rev)
    echo "git $REV $IMPORT $URI"
  done
}


function freeze_hg() {
  cd "$ROOT"
  find . -type d  -iname ".hg" | sort | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    REV=$(hg identify -i)
    IMPORT=$(echo $repo | cut -c3- | rev | cut -c5- | rev)
    echo "hg $REV $IMPORT"
  done
}

function freeze_bzr() {
  cd "$ROOT"
  find . -type d -iname ".bzr" | sort | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    REV=$(bzr log -l1 --show-ids | grep revision-id | cut -c14-)
    IMPORT=$(echo $repo | cut -c3- | rev | cut -c6- | rev)
    echo "bzr $REV $IMPORT"
  done
}

function freeze_svn() {
  cd "$ROOT"
  find . -type d -iname ".svn" | sort | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    REV=$(svn info | grep Revision | egrep -o [0-9]+)
    IMPORT=$(echo $repo | cut -c3- | rev | cut -c6- | rev)
    echo "svn $REV $IMPORT"
  done
}

function freeze() {
  freeze_git
  freeze_hg
  freeze_bzr
  freeze_svn
}

function reset_git() {
  REPO=$1
  HASH=$2
  URI=$3
  CD="cd $REPO"
  if [ ! -d "$REPO" ]; then
    if [ "$URI" != "" ]; then
      git clone "$URI" "$REPO"
    else
      (git clone "http://$REPO" "$REPO" || git clone "ssh://$REPO" "$REPO")
    fi
  fi
  cd "$ROOT"
  $CD
  if [ $(git rev-parse HEAD) != "$HASH" ]; then
      CHK="git checkout -q $HASH"
      echo "($REPO) $CHK"
      $CHK || (git fetch && $CHK)
  fi
}

function reset_hg() {
  REPO=$1
  HASH=$2
  CD="cd ./$REPO"
  $CD || (hg clone "http://$REPO" "$REPO")
  cd "$ROOT"
  $CD
  CHK="hg checkout -c $HASH"
  $CHK || (hg pull && $CHK)
}

function reset_bzr() {
  REPO=$1
  HASH=$2
  CD="cd ./$REPO"
  $CD || (mkdir -p $(dirname "$REPO"); bzr branch "http://$REPO" "$REPO")
  cd "$ROOT"
  $CD
  CHK="bzr revert -r revid:$HASH"
  $CHK || (bzr pull && $CHK)
}

function reset_svn() {
  REPO=$1
  HASH=$2
  CD="cd ./$REPO"
  $CD || (svn checkout "http://$REPO" "$REPO")
  cd "$ROOT"
  $CD
  svn update -r "$HASH"
}

function reset() {
   while read TYPE HASH REPO URI; do
      cd "$ROOT"
      echo "$REPO"
      case "$TYPE" in
        git) reset_git "$REPO" "$HASH" "$URI" ;;
        hg)  reset_hg  "$REPO" "$HASH" ;;
        svn) reset_svn "$REPO" "$HASH" ;;
        bzr) reset_bzr "$REPO" "$HASH" ;;
        *)
          echo "Unsupported repo type $TYPE"
          exit 1
          ;;
      esac
      echo ----------------------------------
      echo
    done
}




function update_git() {
  cd "$ROOT"
  find . -iname ".git" | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    git fetch
    git reset --hard origin/master
    echo
  done
}

function update_hg() {
  cd "$ROOT"
  find . -iname ".hg" | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    hg pull
    echo
  done
}

function update_bzr() {
  cd "$ROOT"
  find . -iname ".bzr" | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    bzr pull
    echo
  done
}

function update_svn() {
  cd "$ROOT"
  find . -iname ".svn" | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    svn update
    echo
  done
}

function update() {
  update_git
  update_hg
  update_bzr
  update_svn
}




function help() {
    echo "Usage: $NAME freeze|reset|update|help [-s]"
    echo
    echo "  'freeze' prints git repositories in current filesystem tree and"
    echo "  their respective commit hashes to stdout"
    echo
    echo "  'reset' reads pairs (hash, repository) from stdin and resets the"
    echo "  repositories in filesystem"
    echo
    echo "  'update' tries to update all repositories found in current subtree"
    echo "  after 'update' you should check your build and perform a freeze"
    echo
    echo "  help displays this screen"
    echo
    echo "  -s disables all output"
}



if [ "x$GOPATH" == "x" ]; then
  echo "Error: missing \$GOPATH variable"
  exit 2
fi


if [ "$2" == "-s" ]; then
    exec > /dev/null 2>&1
fi


case "$ACTION" in
    help)   help   ;;
    freeze) freeze ;;
    reset)  reset  ;;
    update) update ;;
    *)
        echo "Unknown: $ACTION"
        help
        exit 1
        ;;
esac
