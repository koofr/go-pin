#!/bin/bash
ROOT=`pwd`
NAME=$0
ACTION=${1-help}

function freeze_git() {
    find -iname ".git" | while read repo; do 
      cd $ROOT
      cd $repo/..
      REV=`git rev-parse HEAD`
      echo "git $REV ${repo:2:-5}"
    done
}

function freeze_hg() {
  find -iname ".hg" | while read repo; do 
    cd $ROOT
    cd $repo/..
    REV=`hg identify -i`
    echo "hg $REV ${repo:2:-4}"
  done  
}

function freeze_bzr() {
  find -iname ".bzr" | while read repo; do
    cd $ROOT
    cd $repo/..
    REV=`bzr log -l1 --show-ids | grep revision-id | cut -c14-`
    echo "bzr $REV ${repo:2:-5}"
  done
}

function freeze_svn() {
  find -iname ".svn" | while read repo; do
    cd $ROOT
    cd $repo/..
    REV=`svn info | grep Revision | egrep -o [0-9]+`
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
  HASH=$1
  CHK="git checkout $HASH"
  $CHK || (git fetch && $CHK)
}

function reset_hg() {
  HASH=$1
  CHK="hg checkout -c $HASH"
  $CHK || (hg pull && $CHK)
}

function reset_bzr() {
  HASH=$1
  CHK="bzr revert -r revid:$HASH"
  $CHK || (bzr pull && $CHK)
}

function reset_svn() {
  HASH=$1
  svn update -r $HASH
}

function reset() {
   while read TYPE HASH REPO; do
      cd $ROOT
      cd "./$REPO"
      echo "$REPO"
      case "$TYPE" in
        git) reset_git $HASH ;;
        hg)  reset_hg  $HASH ;;
        svn) reset_svn $HASH ;;
        bzr) reset_bzr $HASH ;;
        *)   
          echo "Unsupported repo type $TYPE" 
          exit 1
          ;;
      esac
      echo 
    done
}




function update_git() {
  find -iname ".git" | while read repo; do 
    cd $ROOT
    cd $repo/..
    echo $repo
    git fetch
    git reset --hard origin/master
    echo
  done
}

function update_hg() {
  find -iname ".hg" | while read repo; do 
    cd $ROOT
    cd $repo/..
    echo $repo
    hg pull
    echo
  done
}

function update_bzr() {
  find -iname ".bzr" | while read repo; do 
    cd $ROOT
    cd $repo/..
    echo $repo
    bzr pull
    echo
  done
}

function update_svn() {
  find -iname ".svn" | while read repo; do 
    cd $ROOT
    cd $repo/..
    echo $repo
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
    echo "  freeze prints git repositories in current filesystem tree and"
    echo "  their respective commit hashes to stdout"
    echo 
    echo "  reset reads pairs (hash, repository) from stdin and resets the"
    echo "  repositories in filesystem"
    echo 
    echo "  update tries to update all repositories found in current subtree" 
    echo
    echo "  help displays this screen"
}



case "$ACTION" in 
    help)   help   ;;
    freeze) freeze ;;
    reset)  reset  ;;
    update) update ;;
    *)
        echo "Unknown:" $ACTION
        help
        ;;
esac