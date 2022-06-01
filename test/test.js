var add = require('../src/add.js');
var expect = require('chai').expect;

describe('calculate result', function() {
  it('1 add 1 test', function() {
    expect(add(1, 1)).to.be.equal(2);
  });
});