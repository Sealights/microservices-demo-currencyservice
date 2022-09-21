const data = require("./data/currency_conversion.json");
const pino = require("pino");

const logger = pino({
	name: 'currencyservice-server',
	messageKey: 'message',
	levelKey: 'severity',
	useLevelLabels: true
});

/**
 * Helper function that gets currency data from a stored JSON file
 * Uses public data from European Central Bank
 */
function _getCurrencyData (callback) {
	const data = require('./data/currency_conversion.json');
	callback(data);
}

/**
 * Helper function that handles decimal/fractional carrying
 */
function _carry (amount) {
	const fractionSize = Math.pow(10, 9);
	amount.nanos += (amount.units % 1) * fractionSize;
	amount.units = Math.floor(amount.units) + Math.floor(amount.nanos / fractionSize);
	amount.nanos = amount.nanos % fractionSize;
	return amount;
}

/**
 * Lists the supported currencies
 */
function getSupportedCurrencies (call, callback) {
	logger.info('Getting supported currencies...');
	_getCurrencyData((data) => {
		callback(null, {currency_codes: Object.keys(data)});
	});
}

/**
 * Converts between currencies
 */
function convert (call, callback) {
	try {
		_getCurrencyData((data) => {
			const request = call.request;

			// Convert: from_currency --> EUR
			const from = request.from;
			const euros = _carry({
				units: from.units / data[from.currency_code],
				nanos: from.nanos / data[from.currency_code]
			});

			euros.nanos = Math.floor(euros.nanos); //FIX BUG-1234

			// Convert: EUR --> to_currency
			const result = _carry({
				units: euros.units * data[request.to_code],
				nanos: euros.nanos * data[request.to_code]
			});

			result.units = Math.floor(result.units);
			result.nanos = Math.floor(result.nanos);
			result.currency_code = request.to_code;

			logger.info(`conversion request successful`);
			callback(null, result);
		});
	} catch (err) {
		logger.error(`conversion request failed: ${err}`);
		callback(err.message);
	}
}


module.exports = {
	convert,
	getSupportedCurrencies
}
