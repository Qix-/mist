var path = require('path');
var exec = require('child_process').exec;
var should = require('should');

var MistBuild = require('../bin/mist-build.js');
var MistClean = require('../bin/mist-clean.js');

var fixtureDir = path.join(__dirname, path.basename(__filename, '.js'));

describe('basic', function() {
  describe('compile', function() {
    it('should compile', function(done) {
      MistBuild({cwd: fixtureDir, exitcb: function(code) {
        if (code !== 0) {
          done(new Error('Exited with non-zero code: ' + code));
        } else {
          done();
        }
      }});
    });

    var capturedStdout = '';
    it('should run', function(done) {
      exec('cd ' + fixtureDir + ' && ./basic', function(err, stdout, stderr) {
        if (err) done(err);
        capturedStdout = stdout;
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
  });
});
