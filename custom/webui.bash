#!/usr/bin/env bash

echo 'Webui Custom Bash Profile -> Start'

# general
alias lsa='ls -lsah'
alias ffind='find . -name'
alias filefind='find . -name'
alias myip='ifconfig | grep "inet " | grep -v 127.0.0.1'

# git
alias gitprune='git branch --merged | grep -v "\*" | grep -v master | grep -v dev | xargs -n 1 git branch -d'
alias mybranch='git rev-parse --abbrev-ref HEAD'

# webui
alias webui='cd /gitviews/webui; pwd'
alias clearIdea='rm -rf /gitviews/webui/.idea; echo removed webui .idea'
alias proxy='cd /gitviews/webui-proxy; pwd; ./b run'
alias own_source='sudo chown -R rdasari /gitviews'


git config --system core.autocrlf input

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

# only for webui
function setupssh() {
    git remote set-url origin ssh://git@stash.nane.openenglab.netapp.com:7999/san/webui.git
    cd theme
    git remote set-url origin ssh://git@stash.nane.openenglab.netapp.com:7999/san/webui-theme.git
}

echo 'Webui Custom Bash Profile -> End'



