#/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new-version>"
  exit 1
fi

sudo rm -f /opt/java/current-java && sudo ln -s /opt/java/$1 /opt/java/current-java
