#!/bin/bash
success=true

if [ -z "$1" ] || [ "$1" == "deps" ]; then
  npm install || exit 1
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

if [ -z "$1" ] || [ "$1" == "mist" ]; then
  echo -en "\x1b[1;31m"
  function cofc {
    node node_modules/coffee-script/bin/coffee -cbm --no-header -o $*
  }
  mkdir -p bin/tmp/bin
  mkdir -p bin/tmp/lib/parser
  # only the bare necessities to get mist to build itself
  cp package.json bin/tmp/package.json
  cofc bin/tmp/bin src/mist.coffee || exit 1
  cofc bin/tmp/bin src/mist-build.coffee || exit 1
  cofc bin/tmp/lib src/lib/globber.coffee || exit 1
  cofc bin/tmp/lib src/lib/hasher.coffee || exit 1
  cofc bin/tmp/lib src/lib/mist-resolver.coffee || exit 1
  cofc bin/tmp/lib src/lib/mistfile.coffee || exit 1
  cofc bin/tmp/lib src/lib/utils.coffee || exit 1
  cofc bin/tmp/lib/renderer src/lib/renderer/ninja.coffee || exit 1
  node node_modules/pegjs/bin/pegjs --plugin pegjs-coffee-plugin -o speed src/lib/parser/mist-parser.pegcs bin/tmp/lib/parser/mist-parser.js || exit 1
  node node_modules/pegjs/bin/pegjs --plugin pegjs-coffee-plugin -o speed src/lib/parser/mist-preprocessor.pegcs bin/tmp/lib/parser/mist-preprocessor.js || exit 1
  echo -en "\x1b[0m"
  NINJA=`pwd`/bin/ninja/ninja node bin/tmp/bin/mist.js || exit 1
  rm -rf bin/tmp
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

if [ -z "$1" ] || [ "$1" == "test" ]; then
  npm test || exit 1
  [ ! -z "$1" ] && shift && [ -z "$1" ] && exit
fi

echo "Built successfully"
