{array} = require 'utila'
getTime = require './getTime'
timeoutPool = require './pool/timeout'
intervalPool = require './pool/interval'
{request, cancel} = require './raf'

module.exports = class Timing

	@requestAnimationFrame: request

	@cancelAnimationFrame: cancel

	@getTime: getTime

	constructor: (nextFrame = _nextFrame, cancelNextFrame = _cancelNextFrame) ->

		unless typeof nextFrame is 'function'

			throw Error "nextFrame needs to be a function. Leave null for requestAnimationFrame"

		unless typeof cancelNextFrame is 'function'

			throw Error "cancelNextFrame needs to be a function. Leave null for cancelRequestAnimationFrame"

		@_nextFrame = nextFrame

		@_cancelNextFrame = _cancelNextFrame

		@time = 0

		@timeInMs = 0

		@speed = 1

		@_toCallOnNextTick = []

		@_nextTickTimeout = null

		@_toCallLaterAfterFrame = []

		@_toCallOnFrame = []

		@_toCallOnFrames = []

		@_toCancelCallingOnFrame = []

		@_toCallAfterFrames = []

		@_toCancelCallingAfterFrames = []

		@_waitCallbacks = []

		@_intervals = []

		@_toRemoveFromIntervals = []

		@_rafId = 0

		@_tickNumber = 0

		@_boundLoop = (t) =>

			@_loop t

			return

		@_started = no

	nextTick: (fn) ->

		@_toCallOnNextTick.push fn

		unless @_nextTickTimeout

			@_nextTickTimeout = setTimeout =>

				do @_callTick

			, 0

		return

	_callTick: ->

		return if @_toCallOnNextTick.length < 1

		@_nextTickTimeout = null

		toCallNow = @_toCallOnNextTick

		# todo: reuse an existing array instead of creating one
		@_toCallOnNextTick = []

		for fn in toCallNow

			do fn

		return

	afterFrame: (fn) ->

		@_toCallLaterAfterFrame.push fn

		return

	_callFramesScheduledForAfterFrame: (t) ->

		return if @_toCallLaterAfterFrame.length < 1

		loop

			return if @_toCallLaterAfterFrame.length < 1

			toCall = @_toCallLaterAfterFrame

			@_toCallLaterAfterFrame = []

			for fn in toCall

				fn t

		return

	frame: (fn) ->

		@_toCallOnFrame.push fn

		return

	cancelFrame: (fn) ->

		array.pluckOneItem @_toCallOnFrame, fn

		return

	_callFramesScheduledForFrame: (t) ->

		return if @_toCallOnFrame.length < 1

		toCallNow = @_toCallOnFrame

		@_toCallOnFrame = []

		for fn in toCallNow

			fn t

		return

	frames: (fn) ->

		@_toCallOnFrames.push fn

		return

	cancelFrames: (fn) ->

		@_toCancelCallingOnFrame.push fn

		return

	_callFramesScheduledForFrames: (t) ->

		return if @_toCallOnFrames.length < 1

		for toCancel in @_toCancelCallingOnFrame

			array.pluckOneItem @_toCallOnFrames, toCancel

		@_toCancelCallingOnFrame.length = 0

		for fn in @_toCallOnFrames

			fn t

		return

	afterFrames: (fn) ->

		@_toCallAfterFrames.push fn

		return

	cancelAfterFrames: (fn) ->

		@_toCancelCallingAfterFrames.push fn

		return

	_callAfterFrames: (t) ->

		return if @_toCallAfterFrames.length < 1

		for toCancel in @_toCancelCallingAfterFrames

			array.pluckOneItem @_toCallAfterFrames, toCancel

		@_toCancelCallingAfterFrames.length = 0

		for fn in @_toCallAfterFrames

			fn t

		return

	__shouldInjectCallItem: (itemA, itemB, itemToInject) ->

		unless itemA?

			return yes if itemToInject.time <= itemB.time

			return no

		unless itemB?

			return yes if itemA.time <= itemToInject.time

			return no

		return yes if itemA.time <= itemToInject.time <= itemB.time

		return no

	wait: (ms, fn) ->

		callTime = @timeInMs + ms + 8

		item = timeoutPool.give callTime, fn

		array.injectByCallback @_waitCallbacks, item, @__shouldInjectCallItem

		return

	_callWaiters: (t) ->

		return if @_waitCallbacks.length < 1

		loop

			return if @_waitCallbacks.length < 1

			item = @_waitCallbacks[0]

			return if item.time > @timeInMs

			timeoutPool.take item

			@_waitCallbacks.shift()

			item.fn t

		return

	every: (ms, fn) ->

		@_intervals.push intervalPool.give ms, @timeInMs, 0, fn

		return

	cancelEvery: (fn) ->

		@_toRemoveFromIntervals.push fn

		return

	_callIntervals: ->

		return if @_intervals.length < 1

		t = @timeInMs

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

	_loop: (t) ->

		@_rafId = @_nextFrame @_boundLoop

		@tick t

		return

	tick: (t) ->

		@tickNumber++

		t = t * @speed

		@time = t

		t = parseInt t

		@timeInMs = t

		@_callFramesScheduledForFrame t

		@_callFramesScheduledForFrames t

		@_callAfterFrames t

		@_callFramesScheduledForAfterFrame t

		@_callWaiters t

		@_callIntervals t

		return

	start: ->

		return if @_started

		@_rafId = @_nextFrame @_boundLoop

		return

	stop: ->

		return if not @_started

		@_cancelNextFrame @_rafId

		return