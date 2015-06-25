var path = require('path');
var fsx = require('fs-extra');

function removeIfExists() {
  for (var i = 0; i < arguments.length; i++) {
    var file = path.join(__dirname, arguments[i]);
    console.error('purge:', file);
    fsx.removeSync(file);
  }
}

removeIfExists('hello', '.mist/');
