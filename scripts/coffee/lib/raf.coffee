module.exports =

	request: do ->

		return window.requestAnimationFrame.bind(window) if window.requestAnimationFrame

		return window.mozRequestAnimationFrame.bind(window) if window.mozRequestAnimationFrame

		return window.webkitRequestAnimationFrame.bind(window) if window.webkitRequestAnimationFrame

		throw Error "This environment does not support requestAnimationFrame, and no, we're not gonna fall back to setTimeout()!"

	cancel: do ->

		return window.cancelAnimationFrame.bind(window) if window.cancelAnimationFrame

		return window.mozCancelAnimationFrame.bind(window) if window.mozCancelAnimationFrame

		return window.webkitCancelAnimationFrame.bind(window) if window.webkitCancelAnimationFrame

		throw Error "This environment does not support requestAnimationFrame, and no, we're not gonna fall back to setTimeout()!"