#!/usr/bin/env node
'use strict';

var fs = require('fs');
var spawn = require('child_process').spawn;

try {
  fs.mkdirSync('bin/ninja');
} catch (e) {
  // swallow
}

var proc = spawn('../../ext/ninja/configure.py', ['--bootstrap'], {
  cwd: 'bin/ninja',
  stdio: [null, process.stdout, process.stderr]
});

proc.on('close', process.exit);
