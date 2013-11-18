module.exports = (fn) ->

	toCallOnNextTick.push fn

	unless nextTickTimeout

		nextTickTimeout = nextTick callTick

	return

# https://github.com/medikoo/next-tick/blob/master/lib/next-tick.js
nextTick = do ->

	if process? and typeof process.nextTick is 'function'

		return process.nextTick

	if typeof setImmediate is 'function'

		return (cb) -> setImmediate cb

	return (cb) -> setTimeout cb, 0

callTick = ->

	return if toCallOnNextTick.length < 1

	nextTickTimeout = null

	toCallNow = toCallOnNextTick

	# todo: reuse an existing array instead of creating one
	toCallOnNextTick = []

	for fn in toCallNow

		do fn

	return