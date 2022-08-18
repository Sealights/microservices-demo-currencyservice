const pino = require("pino");

const logger = pino({
    name: 'currencyservice-server',
    messageKey: 'message',
    levelKey: 'severity',
    useLevelLabels: true
});

module.exports = logger;