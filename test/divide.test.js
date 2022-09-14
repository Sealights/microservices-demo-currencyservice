const divide = require('../src/divide.js');
const expect = require('chai').expect;

describe('calculate result', function () {

  it('1 / 1 = 1', function () {
    expect(divide(2, 2)).to.be.equal(1);
  });

  it('25 / 5 = 5', function () {
    expect(divide(25, 5)).to.be.equal(5);
  });


  it('25 / 0 = Infinity', function () {
    expect(divide(25, 0)).to.be.equal(Infinity);
  });
});
