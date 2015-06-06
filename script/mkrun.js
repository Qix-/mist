'use strict';

var fs = require('fs');

fs.writeFileSync(process.argv[3],
    [
      '#!/bin/sh',
      '\':\' //; exec "$(command -v nodejs || command -v node)" "$0" "$@"',
      fs.readFileSync(process.argv[2]).toString()
    ].join('\n'));
