#!/bin/bash
npm install
node node_modules/coffee-script/bin/coffee -cbm --no-header -o bin src/mist.coffee
node node_modules/pegjs/bin/pegjs --plugin pegjs-coffee-plugin -o speed -- src/mist-parser.pegcs bin/mist-parser.js
