timeoutPool = require './pool/timeout'
intervalPool = require './pool/interval'
{array} = require 'utila'

module.exports = class Waiter

	constructor: ->

		@_timeouts = []

		@_intervals = []

		@_toRemoveFromIntervals = []

	wait: (callTime, fn) ->

		item = timeoutPool.give callTime, fn

		array.injectByCallback @_timeouts, item, shouldInjectCallItem

		return

	_callFromSchedule: (t) ->

		return if @_timeouts.length < 1

		loop

			return if @_timeouts.length < 1

			item = @_timeouts[0]

			return if item.time > @timeInMs

			timeoutPool.take item

			@_timeouts.shift()

			item.fn t

		return

	tick: (t) ->

		@_callFromSchedule t

		@_callIntervals t

		return

	every: (ms, fn, currentTimeInMs) ->

		@_intervals.push intervalPool.give ms, currentTimeInMs, 0, fn

		return

	cancelEvery: (fn) ->

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