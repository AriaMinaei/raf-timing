Waiter = require './Waiter'
getTime = require './getTime'
nextTick = require './nextTick'
{requestAnimationFrame, cancelAnimationFrame} = require './raf'

module.exports = class Timing

	self = @

	constructor: ->

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

		@_waiter.setTimeout callTime, fn

		return

	every: (ms, fn) ->

		@_waiter.setInterval ms, fn, @timeInMs

		return

	cancelEvery: (fn) ->

		@_waiter.cancelInterval fn

		return

	_loop: (t) ->

		@_rafId = requestAnimationFrame @_boundLoop

		@tick t

		return

	tick: (t) ->

		@tickNumber++

		t = t * @speed

		@time = t

		t = parseInt t

		@timeInMs = t

		@_waiter.tick t

		return

	start: ->

		return if @_started

		@_rafId = requestAnimationFrame @_boundLoop

		return

	stop: ->

		return if not @_started

		cancelAnimationFrame @_rafId

		return