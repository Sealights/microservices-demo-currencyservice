const add = require('../add.test.js');
const multiply = require('../multiply.spec.js');
const divide = require('../divide.js');
const subtract = require('../subtract.js');
const expect = require('chai').expect;

describe('try all operations at once', function () {
  it('((14 - 2) / 2 ) * (5 + 1) = 36', function () {
    const operation = multiply(divide(subtract(14, 2), 2), (add(5, 1)));
    expect(operation).to.be.equal(36);
  });
});
