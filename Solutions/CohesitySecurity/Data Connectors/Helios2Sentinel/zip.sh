#!/bin/zsh
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "$SCRIPTPATH"

TEMP_DIR="OUTPUT_DIR"

find "$SCRIPTPATH"/ -type f -iname \*.csproj | while read ss; \
do \
    echo "ss --> $ss"
    SCRIPT=$(realpath "$ss")
    cd $(dirname "$SCRIPT")

    filename=$(basename -- "$ss")
    extension="${filename##*.}"
    filename="${filename%.*}"
    echo "filename --> $filename"
    dotnet clean
    dotnet publish -o "$TEMP_DIR"
    cd ./"$TEMP_DIR"/
    zip -r ./"$filename".zip ./*
    mv -fv ./"$filename".zip ../Package/
    cd ../
    rm -fr ./"$TEMP_DIR"/
done
