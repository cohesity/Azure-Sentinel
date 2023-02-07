#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

./zip.sh
unzip ./Package/IncidentProducer.zip -d IncidentProducer.output1
git checkout ./Package/IncidentProducer.zip
unzip ./Package/IncidentProducer.zip -d IncidentProducer.output2
kdiff3 IncidentProducer.output1 IncidentProducer.output2
git clean -fd
git checkout ./Package/*.zip
