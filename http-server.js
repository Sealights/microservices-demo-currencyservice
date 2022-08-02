/*
/*
 * Copyright 2018 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require('express')
const bodyParser = require('body-parser')
const https = require('https');

const { convert, getSupportedCurrencies } = require('./core')


const startHttpServer = () => {
	const app = express()
	const port = 7001

	app.use(bodyParser.urlencoded({ extended: false }))
	app.use(bodyParser.json())

	app.get('/get-supported-currencies', (req, res) => {
		getSupportedCurrencies(req.body, (err, result) => {
			if(err) {
				return res.status(400).send(err)
			}

			return res.send(result)
		})
	})

	app.post('/convert', (req, res) => {
		convert({ request: req.body }, (err, result) => {
			if(err) {
				return res.status(400).send(err)
			}

			callDummyMethod()

			return res.send(result)
		})
	})

	app.listen(port, () => {
		console.log(`Example app listening on port ${port}`)
	})
}

const callDummyMethod = () => {
	const http = require('http');

	const data = JSON.stringify({
		user_id: 'officia commodo tempor qui ut',
	});

	const options = {
		hostname: 'sl-boutique-cartservice',
		port: 7072,
		path: '/EmptyCart',
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		}
	};

	const req = http.request(options, res => {
		console.log(`statusCode: ${res.statusCode}`);

		res.on('data', d => {
			process.stdout.write(d);
		});
	});

	req.on('error', error => {
		console.error(error);
	});

	req.write(data);
	req.end();
}

module.exports = { startHttpServer }
