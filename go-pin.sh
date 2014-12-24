#!/bin/bash
ROOT="$GOPATH/src"
NAME=$0
ACTION=${1-help}

function freeze_git() {
  cd "$ROOT"
  find -type d -iname ".git" | while read repo; do 
    cd "$ROOT"
    cd "$repo/.."
    REV=$(git rev-parse HEAD)
    echo "git $REV ${repo:2:-5}"
  done
}

function freeze_hg() {
  cd "$ROOT"
  find -type d  -iname ".hg" | while read repo; do 
    cd "$ROOT"
    cd "$repo/.."
    REV=$(hg identify -i)
    echo "hg $REV ${repo:2:-4}"
  done  
}

function freeze_bzr() {
  cd "$ROOT"
  find -type d  -iname ".bzr" | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    REV=$(bzr log -l1 --show-ids | grep revision-id | cut -c14-)
    echo "bzr $REV ${repo:2:-5}"
  done
}

function freeze_svn() {
  cd "$ROOT"
  find -type d  -iname ".svn" | while read repo; do
    cd "$ROOT"
    cd "$repo/.."
    REV=$(svn info | grep Revision | egrep -o [0-9]+)
    echo "svn $REV ${repo:2:-5}"
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
  CD="cd $REPO"
  $CD || (git clone "http://$REPO" "$REPO" || git clone "ssh://$REPO" "$REPO") 
  cd "$ROOT"
  $CD
  CHK="git checkout -q $HASH"
  echo "$CHK"
  $CHK || (git fetch && $CHK)
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
   while read TYPE HASH REPO; do
      cd "$ROOT"
      echo "$REPO"
      case "$TYPE" in
        git) reset_git "$REPO" "$HASH" ;;
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
  find -iname ".git" | while read repo; do 
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    git fetch
    git reset --hard origin/master
    echo
  done
}

function update_hg() {
  find -iname ".hg" | while read repo; do 
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    hg pull
    echo
  done
}

function update_bzr() {
  find -iname ".bzr" | while read repo; do 
    cd "$ROOT"
    cd "$repo/.."
    echo "$repo"
    bzr pull
    echo
  done
}

function update_svn() {
  find -iname ".svn" | while read repo; do 
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
    echo "Usage: $NAME freeze|reset|update|help"
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
}



if [ "x$GOPATH" == "x" ]; then
  echo "Error: missing \$GOPATH variable"
  exit 2
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