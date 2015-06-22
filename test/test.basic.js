var exec = require('child_process').exec;
var should = require('should');

describe('basic', function() {
  describe('compile', function() {
    var code = -1;
    var stdout = '';

    before(function(done) {
      exec('cd test/test.basic && mist build', function(rcode, rstdout, rstderr) {
        if (rcode) done(rcode);
        code = rcode ? rcode.error : 0;
        stdout = rstdout;
        done();
      });
    });

    it('should exit with 0', function() {
      code.should.equal(0);
    });
  });
});
