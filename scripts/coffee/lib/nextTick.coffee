# https://github.com/medikoo/next-tick/blob/master/lib/next-tick.js
module.exports = nextTick = do ->

	if process? and typeof process.nextTick is 'function'

		return process.nextTick

	if typeof setImmediate is 'function'

		return (cb) -> setImmediate cb

	# todo: there was a polyfill for chrome that simulated setImmediate...
	return (cb) -> setTimeout cb, 0