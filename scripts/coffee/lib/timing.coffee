getTime = require './getTime'
{request, cancel} = require './raf'
nextTick = require './nextTick'
Waiter = require './Waiter'

module.exports = class Timing

	@requestAnimationFrame: request

	@cancelAnimationFrame: cancel

	@getTime: getTime

	constructor: (nextFrame = request, cancelNextFrame = cancel) ->

		unless typeof nextFrame is 'function'

			throw Error "nextFrame needs to be a function. Leave null for requestAnimationFrame"

		unless typeof cancelNextFrame is 'function'

			throw Error "cancelNextFrame needs to be a function. Leave null for cancelRequestAnimationFrame"

		@_nextFrame = nextFrame

		@_cancelNextFrame = cancelNextFrame

		@time = 0

		@timeInMs = 0

		@speed = 1

		@tickNumber

		@_rafId = 0

		@_waiter = new Waiter

		@_boundLoop = (t) =>

			@_loop t

			return

		@_started = no

	nextTick: (fn) ->

		nextTick fn

		return

	wait: (ms, fn) ->

		callTime = @timeInMs + ms + 8

		@_waiter.schedule callTime, fn

		return

	every: (ms, fn) ->

		@_waiter.every ms, fn, @timeInMs

		return

	cancelEvery: (fn) ->

		@_waiter.cancelEvery fn

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

		@_waiter.tick t

		return

	start: ->

		return if @_started

		@_rafId = @_nextFrame @_boundLoop

		return

	stop: ->

		return if not @_started

		@_cancelNextFrame @_rafId

		return