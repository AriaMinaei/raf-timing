module.exports =

	request: do ->

		return window.requestAnimationFrame if window.requestAnimationFrame

		return window.mozRequestAnimationFrame if window.mozRequestAnimationFrame

		return window.webkitRequestAnimationFrame if window.webkitRequestAnimationFrame

	cancel: do ->

		return window.cancelAnimationFrame if window.cancelAnimationFrame

		return window.mozCancelAnimationFrame if window.mozCancelAnimationFrame

		return window.webkitCancelAnimationFrame if window.webkitCancelAnimationFrame