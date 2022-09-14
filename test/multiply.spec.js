const multiply = require('../src/multiply.js');
const expect = require('chai').expect;

describe('calculate result', function () {

  it('1 mul 1 test', function () {
    expect(multiply(1, 1)).to.be.equal(1);
  });

  it('3 * 100 = 300', function () {
    expect(multiply(3, 100)).to.be.equal(300);
  });

  it('5 * 5 = 25', function () {
    expect(multiply(5, 5)).to.be.equal(25);
  });

});
