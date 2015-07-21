#!/bin/bash

# bail on error
set -e

SCRIPT_DIR=$(readlink -f $0 | xargs dirname)

REQUIRES_UPDATE=no
if [[ "$1" == -f ]]; then
  REQUIRES_UPDATE=yes
fi

# install chrome details
if ! grep -qL "deb http://dl.google.com/linux/chrome/deb/ stable main" "/etc/apt/sources.list.d/google.list"; then
  echo "Installing Google key and sources"
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
  REQUIRES_UPDATE=yes
fi

# install virtualbox details
if ! grep -qL "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" "/etc/apt/sources.list.d/virtualbox.list"; then
  echo "Installing VirtualBox key and sources"
  sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" >> /etc/apt/sources.list.d/virtualbox.list'
  wget http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
  REQUIRES_UPDATE=yes
fi

# install spotify details
if ! grep -qL "deb http://repository.spotify.com stable non-free" "/etc/apt/sources.list.d/spotify.list"; then
  echo "Installing Spotify key and sources"
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
  sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list.d/spotify.list'
  REQUIRES_UPDATE=yes
fi

# one big update
if [[ "$REQUIRES_UPDATE" == "yes" ]]; then
  sudo apt-get update
fi

# fonts
sudo sh -c 'echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections'

# one big install
sudo apt-get install vim curl build-essential sublime-text git virtualbox-5.0 jekyll nodejs wine winetricks dropbox google-chrome-stable spotify-client ttf-mscorefonts-installer

if [[ "$REQUIRES_UPDATE" == "yes" ]]; then
  sudo apt-get dist-upgrade
fi

$SCRIPT_DIR/consolas.sh 

#ruby
#if [ ! -L ~/.rvm/rubies/default ]; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable --ruby --ruby=1.9.3 --ruby=2.0.0
  source /home/joe/.rvm/scripts/rvm
  rvm rvmrc warning ignore allGemfiles
  gem install bundler
#fi
