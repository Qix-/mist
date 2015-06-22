'use strict';

var path = require('path');
var glob = require('glob');
var lcovSourcemap = require("lcov-sourcemap");

var map = {};

process.argv.slice(4).map(function(dir) {
  return glob.sync(dir + '/**/*.map', {
    cwd: process.cwd(),
    root: process.cwd(),
    nosort: true,
    silent: false,
    nodir: true
  });
}).forEach(function(set) {
  set = set || [];
  set.forEach(function(mapFile) {
    mapFile = path.join(process.argv[3], mapFile);
    map[path.basename(mapFile, '.js.map')] = mapFile;
  });
});

lcovSourcemap(process.argv[2], map, process.argv[3])
  .then(console.log.bind(console));
