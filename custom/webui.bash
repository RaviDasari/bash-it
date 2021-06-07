#!/usr/bin/env bash

# echo 'Webui Custom Bash Profile -> Start'

# general
alias lsa='ls -lsah'
alias ffind='find . -name'
alias filefind='find . -name'
alias myip='ifconfig | grep "inet " | grep -v 127.0.0.1'
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
# alias vnc='/Applications/TigerVNC\ Viewer\ 1.9.0.app/Contents/MacOS/TigerVNC\ Viewer'
alias vcv-dev='/Applications/TigerVNC\ Viewer\ 1.9.0.app/Contents/MacOS/TigerVNC\ Viewer'
alias max_user_watch='echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p'

# git
alias gitprune='git branch --merged | grep -v "\*" | grep -v master | grep -v dev | xargs -n 1 git branch -d'
alias mybranch='git rev-parse --abbrev-ref HEAD'
alias gitrecent='git branch --sort=-committerdate | head -n 20'
alias gcor='git checkout --recurse-submodules'
alias git-tracking="git for-each-ref --format='%(refname:short) <- %(upstream:short)' refs/heads"

# webui
alias webui='cd ~/gitviews/webui; pwd; npm start'
alias webui-git='cd ~/gitviews/webui; pwd; gs'
alias clearIdea='rm -rf ~/gitviews/webui/.idea; echo removed webui .idea'
alias proxy='cd ~/gitviews/webui-proxy; pwd; npm start'
alias own_source='sudo chown -R rdasari ~/gitviews'
alias webmount='sudo mount -t nfs -o resvport,rw 10.197.120.235:~/gitviews /private/nfs'
alias webumount='sudo umount /private/nfs'
alias oc-demo-portal='oc login https://10.197.121.102:8443 --username=cluster-admin'


git config --system core.autocrlf input


function git-set-upstream() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git branch --set-upstream-to=origin/$CURRENT_BRANCH $CURRENT_BRANCH
}

function git-set-u() {
  git-set-upstream
}

function update_theme(){
  echo "this is used to keep ensure the hash doesn't get updated when updating to the latest theme"
  git fetch --recurse-submodules
  
  echo
  cd theme; pwd;
  
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  
  echo
  echo "Stashing your local changes"
  git stash
  
  echo 
  echo "Checking out the $CURRENT_BRANCH"
  git reset --hard origin/$CURRENT_BRANCH
  
  echo
  echo "restoring your stash"
  git stash pop
  
  cd ..
  
  echo "showing theme diff"
  git diff theme 
}

function config_git {
  git config --global push.default current
  git config --global user.name "rdasari"
  git config --global user.email "Ravi.Dasari@netapp.com"
}

function config_git_public {
  git config --global push.default current
  git config --global user.name "RaviDasari"
  git config --global user.email "raviunivers@gmail.com"
}

function gitopen(){
  REPO="$1";
  if [ -z "$1" ]; then REPO="origin" ; fi
  python -m webbrowser -t $(git config --get remote.$REPO.url)
}

function gitpush(){
  REPO="$1";
  if [ -z "$1" ]; then REPO="origin" ; fi
  echo "git push $REPO $(mybranch)"
  git push $REPO $(mybranch);
  gitopen $REPO;
}

function checkout(){
    git checkout $1
 
    git diff theme | grep "\-Subproject"
 
    HASH=$(git diff theme | grep "\-Subproject" | awk '{print $3}')
 
    if [ -z $HASH ];
        then echo Skipping checking out
    else
        echo checking out $HASH
        cd theme
        git checkout $HASH
        cd -
    fi
}

function port-in-use() {
  PORT=$1
  if [ -z "$1" ]; 
    then 
      echo "Port param required ! Ex: port-in-use 3003"; 
    else
      #  netstat -anp tcp | grep LISTEN
      lsof -i tcp:$PORT
  fi
}

function unsafe_chrome() {
  TENANT_NAME=$1
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --user-data-dir=/tmp/foo --ignore-certificate-errors --unsafely-treat-insecure-origin-as-secure=https://${TENANT_NAME}.oci.cloudinsights-qa.netapp.com
}

function setupvm() {
  echo 'Setting up this vm...\n'
  
  echo 'installing gitk'
  sudo yum install git-gui gitk
  echo 'setting up git'
  config_git
  echo 'setting docker for logged in user'
  setup_docker
  echo 'setting up iptables'
  setup_iptables

  echo '\nDone setting up.'
}

function stop_app() {
  ps aux | grep -v grep | grep $@ | awk '{print $2}' | xargs -L1 kill
}

function stopvnc() {
  stop_app "vnc"
}

function runvnc() {
  stop_vnc
  vncserver :1
  vncviewer -Maximize -AutoSelect=0 -LowColourLevel 2 -QualityLevel 0
}

function git-purge() {
  echo "Pulling latest code..."
  git pull
  echo "Deleting local branches that were removed in remote..."
  git fetch -p 
  git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D
  echo "Remaining local branches:"
  git branch -vv
  echo "Done."
}

function touch2() {
  mkdir -p "$(dirname "$1")" && touch "$1"
}

# only for webui
function setupssh() {
    git remote set-url origin ssh://git@stash.nane.openenglab.netapp.com:7999/san/webui.git
    cd theme
    git remote set-url origin ssh://git@stash.nane.openenglab.netapp.com:7999/san/webui-theme.git
}

function runUnitTest() {
  options=$2
  FILE_BASE_PATH=`echo "$1" | sed 's/.*src\///' | sed 's/\.js//'`
  node 'node_modules/.bin/jest' "tests/${FILE_BASE_PATH}.spec.js" $options
}

function runBrowserTest() {
  options=$2
  cd ~/gitviews/webui/browser-tests
  FILE_BASE_PATH=`echo "$1" | sed 's/.*browser-tests\///'`
  echo "Running browser tests for $FILE_BASE_PATH"
  testcafe --live chrome ${FILE_BASE_PATH} $options
}

function countLinesInFolder() {
  FILE_BASE_PATH=`echo "$1" | sed 's/.*src\///'`
  find src/${FILE_BASE_PATH} \
      tests/${FILE_BASE_PATH} \
      browser-tests/src/tests/${FILE_BASE_PATH} -name '*.*' -type f | \
      grep -v __snapshots__ | \
      grep -v .json | \
      xargs wc -l
}

export SCM_GIT_SHOW_MINIMAL_INFO=true
# export DISABLE_BASH_IT_THEME=true

# parse_git_branch() {
#   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
# }

# export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

# echo 'Webui Custom Bash Profile -> End'



