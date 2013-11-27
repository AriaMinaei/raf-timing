array = require 'utila/scripts/js/lib/array'
timeoutPool = require './pool/timeout'
intervalPool = require './pool/interval'

module.exports = class Waiter

	constructor: ->

		@_timeouts = []

		@_intervals = []

		@_toRemoveFromIntervals = []

	setTimeout: (callTime, fn) ->

		item = timeoutPool.give callTime, fn

		array.injectByCallback @_timeouts, item, shouldInjectCallItem

		return

	cancelTimeout: (fn) ->

		throw Error "TODO: Waiter.cancelTimeout() to be implemented"

	_callTimeouts: (t) ->

		return if @_timeouts.length < 1

		while @_timeouts.length

			item = @_timeouts[0]

			return if item.time > t

			timeoutPool.take item

			@_timeouts.shift()

			item.fn t

		return

	tick: (t) ->

		@_callTimeouts t

		@_callIntervals t

		return

	setInterval: (ms, fn, currentTimeInMs) ->

		@_intervals.push intervalPool.give ms, currentTimeInMs, 0, fn

		return

	cancelInterval: (fn) ->

		# todo: make this ID based
		@_toRemoveFromIntervals.push fn

		return

	_callIntervals: (t) ->

		return if @_intervals.length < 1

		for fnToRemove in @_toRemoveFromIntervals

			array.pluckByCallback @_intervals, (item) ->

				return yes if item.fn is fnToRemove
				return no

		for item in @_intervals

			properTimeToCall = item.from + (item.timesCalled * item.every) + item.every

			if properTimeToCall <= t

				item.fn t

				item.timesCalled++

		return

shouldInjectCallItem = (itemA, itemB, itemToInject) ->

	unless itemA?

		return yes if itemToInject.time <= itemB.time

		return no

	unless itemB?

		return yes if itemA.time <= itemToInject.time

		return no

	return yes if itemA.time <= itemToInject.time <= itemB.time

	return no