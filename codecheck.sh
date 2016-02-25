#!/bin/bash

# codecheck.sh: a simple shell script to check for binaries not
# explicitly signed by Apple
# <jonathan@zdziarski.com>
#
# usage: sudo find / -perm +111 -type f -exec ./codecheck.sh -d {} \;
#     remove -d flag to warn on developer certificates

filename=$1
allowdevcerts=0
if [[ $filename == "-d" ]]
then
    filename=$2
    allowdevcerts=1
fi

authinfo=`/usr/bin/codesign -d -vv "$filename" 2>&1`
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

if [[ $allowdevcerts == 1 ]]
then
    case "$authinfo" in
      *"Authority=Developer ID Certification Authority"*)
    case "$authinfo" in
      *"Authority=Apple Root CA"*)
        valid=1
    ;;
    esac
  ;;
  esac
fi

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
        echo "$filename: code object is not signed at all"
    fi

    if [[ $valid == 0 ]]
    then
        echo "$filename: invalid or non-apple code signature: $authinfo"
        echo
        echo
    fi
fi
