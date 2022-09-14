const add = require('../add.js');
const expect = require('chai').expect;

describe('calculate result', function () {
  it('1 add 1 test', function () {
    expect(add(1, 1)).to.be.equal(2);
  });

  it('10 + 10 = 20', function () {
    expect(add(10, 10)).to.be.equal(20);
  });

  it('-5 + 10 = 5', function () {
    expect(add(-5, 10)).to.be.equal(5);
  });
});
