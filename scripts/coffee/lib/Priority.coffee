{array} = require 'utila'

module.exports = class Priority

	constructor: ->

		@_singles = []

		@_series = []

		@_toCancelFromEachTick = []

	nextTick: (fn) ->

		@_singles.push fn

		return

	cancelNextTick: (fn) ->

		array.pluckOneItem @_singles, fn

		return

	_callSingles: (t) ->

		return if @_singles.length < 1

		toCallNow = @_singles

		@_singles = []

		for fn in toCallNow

			fn t

		return

	eachTick: (fn) ->

		@_series.push fn

		return

	cancelEachTick: (fn) ->

		@_toCancelFromEachTick.push fn

		return

	_callSeries: (t) ->

		return if @_series.length < 1

		for toCancel in @_toCancelFromEachTick

			array.pluckOneItem @_series, toCancel

		@_toCancelFromEachTick.length = 0

		for fn in @_series

			fn t

		return

	tick: (t) ->

		@_callSingles t

		@_callSeries t

		return