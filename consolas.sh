#!/bin/bash
# courtesy http://www.rushis.com/2013/03/consolas-font-on-ubuntu/

set -e
TARGET_DIR=/usr/share/fonts/microsoft

if [ -f $TARGET_DIR/CONSOLA.TTF ]; then
  # already done
  exit
fi

TMP_DIR=$(mktemp -d)

function cleanup {
  rm -r $TMP_DIR
}
echo "Created $TMP_DIR"
trap cleanup EXIT

cd $TMP_DIR
wget http://download.microsoft.com/download/E/6/7/E675FFFC-2A6D-4AB0-B3EB-27C9F8C8F696/PowerPointViewer.exe
cabextract -L -F ppviewer.cab PowerPointViewer.exe
cabextract ppviewer.cab

sudo mkdir -p $TARGET_DIR
sudo mv *.TTF $TARGET_DIR
