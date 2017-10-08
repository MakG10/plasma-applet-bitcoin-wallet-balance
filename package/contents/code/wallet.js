var currencyApiUrl = 'http://api.fixer.io';
var blockchainApiUrl = 'https://blockchain.info/pl';
var bitcoinRateApiUrl = 'https://api.coinmarketcap.com/v1/ticker/bitcoin/';

var currencySymbols = {
	'BTC': 'BTC',
	'mBTC': 'mBTC',
	'Satoshi': 'Sat',
	'USD': '$',  // US Dollar
	'EUR': '€',  // Euro
	'CZK': 'Kč', // Czech Coruna
	'GBP': '£',  // British Pound Sterling
	'ILS': '₪',  // Israeli New Sheqel
	'INR': '₹',  // Indian Rupee
	'JPY': '¥',  // Japanese Yen
	'KRW': '₩',  // South Korean Won
	'PHP': '₱',  // Philippine Peso
	'PLN': 'zł', // Polish Zloty
	'THB': '฿',  // Thai Baht
};

function getBalance(addresses, currency, callback) {
	request(blockchainApiUrl + '/balance?active=' + addresses.join('|'), function(req) {
		var data = JSON.parse(req.responseText);
		var balance = 0;
		
		Object.keys(data).forEach(function(address) {
			balance += data[address].final_balance;
		});
		
		if(currency != 'Satoshi') {
			convert(balance, 'Satoshi', currency, callback);
			return;
		}
		
		callback(balance);
	});
	
	return true;
}

function getAllCurrencies() {
	var currencies = [];
	currencies.push('BTC');
	currencies.push('mBTC');
	currencies.push('Satoshi');
	
	Object.keys(currencySymbols).forEach(function eachKey(key) {
		if(['BTC', 'mBTC', 'Satoshi'].indexOf(key) > -1) return;
		
		currencies.push(key);
	});
	
	return currencies;
}

function convert(value, from, to, callback) {
	if(to === 'BTC') {
		callback(value / 100000000);
		return;
	}
	
	if(to === 'mBTC') {
		callback(value / 100000);
		return;
	}
	
	request(bitcoinRateApiUrl, function(req) {
		var data = JSON.parse(req.responseText);
		var rate = data[0].price_usd;
		
		var usd = value / 100000000 * rate;
		
		if(to === 'USD') {
			callback(usd);
			return;
		}
		
		request(currencyApiUrl + '/latest?base=USD', function(req) {
			var data = JSON.parse(req.responseText);
			var rate = data.rates[to];
			
			callback(usd * rate);
		});
	});
}

function request(url, callback) {
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = (function(xhr) {
		return function() {
			callback(xhr);
		}
	})(xhr);
	xhr.open('GET', url, true);
	xhr.send('');
}
