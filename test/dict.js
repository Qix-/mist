'use strict';

var fs = require('fs');
var contents = fs.readFileSync(process.argv[2]).toString();
contents = contents.replace("{qux}", "Qix");
fs.writeFileSync(process.argv[3], contents);
