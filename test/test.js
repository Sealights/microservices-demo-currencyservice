var add = require('../src/add.js');
var expect = require('chai').expect;

describe('add', function() {
  it('1 test add  2', function() {
    expect(add(1, 1)).to.be.equal(2);
  });
});