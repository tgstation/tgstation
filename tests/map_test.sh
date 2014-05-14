#!/bin/bash
dme=tgstation.dme
exitcode=0

compile(){
  sed -i "$1" $dme
  DreamMaker $dme
  exitcode=$?
  if [ $exitcode -ne 0 ]; then
    exit $exitcode # Error!
  fi
}


compile 's/tgstation2.dm/metastation.dm/g'
compile 's/metastation.dm/ministation.dm/g'
compile 's/ministation.dm/tgstation2.dm/g' # This will put it back like it was, so make sure you put the default map last.
