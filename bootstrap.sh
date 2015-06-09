#!/bin/bash
success=true

npm install

if [ -z "$1" ] || [ "$1" == "ninja" ]; then
  shift
  (cd ext/ninja && ./configure.py --bootstrap) || exit 1
fi

if [ -z "$1" ] || [ "$1" == "mist" ]; then
  shift
  echo -en "\x1b[1;31m"
  node node_modules/coffee-script/bin/coffee -cbm --no-header -o bin src/mist.coffee || success=false
  node node_modules/coffee-script/bin/coffee -cbm --no-header -o bin src/mist-ninja-builder.coffee || success=false
  node node_modules/coffee-script/bin/coffee -cbm --no-header -o bin src/mist-globber.coffee || success=false
  node node_modules/pegjs/bin/pegjs --plugin pegjs-coffee-plugin -o speed src/mist-parser.pegcs bin/mist-parser.js || success=false
  echo -en "\x1b[0m"
fi

if [ -z "$1" ] || [ "$1" == "test" ]; then
  shift
  NINJA=`pwd`/ext/ninja/ninja node bin/mist.js
  (cd test/hello && node ../../bin/mist.js) && test/hello/hello-mist || exit 1
  (cd test/foreach && node ../../bin/mist.js) || exit 1
  (cd test/group && node ../../bin/mist.js) || exit 1
fi

$success && echo "Built successfully" || exit 1
echo
