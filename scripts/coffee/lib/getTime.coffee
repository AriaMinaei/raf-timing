module.exports = getTime = do ->

	if performance? and performance.now?

		return -> performance.now()

	else

		return Date.now() - 1372763687107