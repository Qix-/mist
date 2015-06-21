#!/bin/bash
success=true

if [ -z "$1" ] || [ "$1" == "npm" ]; then
  npm install
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

if [ -z "$1" ] || [ "$1" == "ninja" ]; then
  (cd ext/ninja && ./configure.py --bootstrap) || exit 1
  mkdir -p bin/ninja
  cp -v ext/ninja/ninja bin/ninja/ninja || exit 1
  cp -v ext/ninja/COPYING bin/ninja/COPYING || exit 1
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

if [ -z "$1" ] || [ "$1" == "mist" ]; then
  echo -en "\x1b[1;31m"
  function cofc {
    node node_modules/coffee-script/bin/coffee -cbm --no-header -o $*
  }
  cofc bin src/mist.coffee || exit 1
  cofc lib src/lib/globber.coffee || exit 1
  cofc lib src/lib/hasher.coffee || exit 1
  cofc lib src/lib/mist-resolver.coffee || exit 1
  cofc lib src/lib/mistfile.coffee || exit 1
  cofc lib src/lib/utils.coffee || exit 1
  cofc lib/renderer src/lib/renderer/ninja.coffee || exit 1
  node node_modules/pegjs/bin/pegjs --plugin pegjs-coffee-plugin -o speed src/lib/mist-parser.pegcs lib/mist-parser.js || exit 1
  echo -en "\x1b[0m"
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

if [ -z "$1" ] || [ "$1" == "test" ]; then
  NINJA=`pwd`/ext/ninja/ninja node bin/mist.js
  (cd test/hello && node ../../bin/mist.js) && test/hello/hello-mist || exit 1
  (cd test/foreach && node ../../bin/mist.js) || exit 1
  (cd test/group && node ../../bin/mist.js) || exit 1
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

echo "Built successfully"
