const add = require('../src/add.js');
const multiply = require('../src/multiply.js');
const divide = require('../src/divide.js');
const subtract = require('../src/subtract.js');
const expect = require('chai').expect;

describe('try all operations at once', function () {
  it('((14 - 2) / 2 ) * (5 + 1) = 36', function () {
    const operation = multiply(divide(subtract(14, 2), 2), (add(5, 1)));
    expect(operation).to.be.equal(36);
  });
});
