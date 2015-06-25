var fs = require('fs');
var path = require('path');
var exec = require('child_process').exec;
var should = require('should');

var MistRender = require('../bin/mist-render.js');
var MistClean = require('../bin/mist-clean.js');

var ninjaExec = path.join(process.cwd(), 'bin/ninja/ninja');
var fixtureDir = path.join(__dirname, path.basename(__filename, '.js'));

describe('basic render', function() {
  var ninjaFile = path.join(fixtureDir, 'build.ninja');
  it('should render', function() {
    MistRender({out: ninjaFile, cwd: fixtureDir});
    fs.existsSync(ninjaFile).should.equal(true);
  });

  it('should build', function(done) {
    exec('cd ' + fixtureDir + ' && ' + ninjaExec, function(err, out, stderr) {
      done(err);
    });
  });

  var capturedStdout = '';
  it('should run', function(done) {
    exec('cd ' + fixtureDir + ' && ./basic', function(err, out, stderr) {
      if (err) done(err);
      capturedStdout = out;
      done();
    });
  });

  it('should say \'hello\'', function() {
    capturedStdout.should.equal('Hello, world!\n');
  });

  it('should clean', function(done) {
    MistClean({cwd: fixtureDir, exitcb: function(code) {
      if (code !== 0) {
        done(new Error('Exited with non-zero code: ' + code));
      } else {
        done();
      }
    }});
  });

  after(function() {
    require(path.join(fixtureDir, 'purge.js'));
  });
});

