Waiter = require './Waiter'
nextTick = require './nextTick'
Priority = require './Priority'
{requestAnimationFrame, cancelAnimationFrame} = require './raf'

module.exports = class Timing

	self = @

	@requestAnimationFrame: requestAnimationFrame

	@cancelAnimationFrame: cancelAnimationFrame

	constructor: ->

		@nanoTime = 0

		@time = 0

		@speed = 1

		@tickNumber = 0

		@_rafId = 0

		@_waiter = new Waiter

		@_boundLoop = (t) =>

			@_loop t

			return

		@_started = no

		@_before = new Priority

		@_on = new Priority

		@_after = new Priority

	nextTick: (fn) ->

		nextTick fn

		return

	wait: (ms, fn) ->

		callTime = @time + ms + 8

		@_waiter.setTimeout callTime, fn

		return

	every: (ms, fn) ->

		@_waiter.setInterval ms, fn, @time

		return

	cancelEvery: (fn) ->

		@_waiter.cancelInterval fn

		return

	beforeNextFrame: (fn) ->

		@_before.onNextTick fn

		return

	cancelBeforeNextFrame: (fn) ->

		@_before.cancelNextTick fn

		return

	beforeEachFrame: (fn) ->

		@_before.onEachTick fn

		return

	cancelBeforeEachFrame: (fn) ->

		@_before.cancelEachTick fn

		return

	onNextFrame: (fn) ->

		@_on.onNextTick fn

		return

	cancelOnNextFrame: (fn) ->

		@_on.cancelNextTick fn

		return

	onEachFrame: (fn) ->

		@_on.onEachTick fn

		return

	cancelOnEachFrame: (fn) ->

		@_on.cancelEachTick fn

		return

	afterNextFrame: (fn) ->

		@_after.onNextTick fn

		return

	cancelAfterNextFrame: (fn) ->

		@_after.cancelNextTick fn

		return

	afterEachFrame: (fn) ->

		@_after.onEachTick fn

		return

	cancelAfterEachFrame: (fn) ->

		@_after.cancelEachTick fn

		return

	_loop: (t) ->

		@_rafId = requestAnimationFrame @_boundLoop

		@tick t

		return

	tick: (t) ->

		@tickNumber++

		t = t * @speed

		@nanoTime = t

		t = parseInt t

		@time = t

		@_waiter.tick t

		@_before.tick t

		@_on.tick t

		@_after.tick t

		return

	start: ->

		return if @_started

		@_rafId = requestAnimationFrame @_boundLoop

		return

	stop: ->

		return if not @_started

		cancelAnimationFrame @_rafId

		return