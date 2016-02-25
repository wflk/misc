#!/bin/bash

# codecheck.sh: a simple shell script to check for binaries not
# explicitly signed by Apple
# <jonathan@zdziarski.com>
#
# usage: sudo find / -perm +111 -type f -exec ./codecheck.sh {} \;

authinfo=`/usr/bin/codesign -d -vv $1 2>&1`
valid=0

case "$authinfo" in
  *"Authority=Apple Code Signing Certification Authority"*)
    case "$authinfo" in
      *"Authority=Apple Root CA"*)
        valid=1
    ;;
    esac
  ;;
esac

case "$authinfo" in
  *": code object is not signed at all"*)
      valid=-1
  ;;
esac

case "$authinfo" in
  *": bundle format unrecognized, invalid, or unsuitable"*)
      valid=-2
  ;;
esac

if [[ $valid != 1 ]]
then
    if [[ $valid == -1 ]]
    then
        echo "$1: code object is not signed at all"
    fi

    if [[ $valid == 0 ]]
    then
        echo "$1: invalid or non-apple code signature: $authinfo"
        echo
        echo
    fi
fi
