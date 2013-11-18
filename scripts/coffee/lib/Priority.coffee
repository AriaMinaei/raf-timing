{array} = require 'utila'

module.exports = class Priority

	constructor: ->

		@_toCallOnce = []

		@_toCallContinously = []

		@_toCancelCallingContinously = []

	once: (fn) ->

		@_toCallOnce.push fn

		return

	cancelOnce: (fn) ->

		array.pluckOneItem @_toCallOnce, fn

		return

	_callOnces: (t) ->

		return if @_toCallOnce.length < 1

		toCallNow = @_toCallOnce

		@_toCallOnce = []

		for fn in toCallNow

			fn t

		return

	continous: (fn) ->

		@_toCallContinously.push fn

		return

	cancelContinous: (fn) ->

		@_toCancelCallingContinously.push fn

		return

	_callContinous: (t) ->

		return if @_toCallContinously.length < 1

		for toCancel in @_toCancelCallingContinously

			array.pluckOneItem @_toCallContinously, toCancel

		@_toCancelCallingContinously.length = 0

		for fn in @_toCallContinously

			fn t

		return

	tick: (t) ->

		@_callOnces t

		@_callContinous t

		return