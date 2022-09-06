var add = require('../src/add.js');
var multiply = require('../src/multiply.js');
var divide = require('../src/divide.js');
var expect = require('chai').expect;

describe('calculate result', function () {
  it('1 add 1 test', function () {
    expect(add(1, 1)).to.be.equal(2);
  });

  it('1 mul 1 test', function () {
    expect(multiply(1, 1)).to.be.equal(1);
  });

  it('1 div 1 test', function () {
    // failing test
    expect(divide(2, 2)).to.be.equal(2);
  });
});
