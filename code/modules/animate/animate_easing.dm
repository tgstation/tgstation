
/datum/animate_easing
	var/name
	var/description
	var/value

/datum/animate_easing/linear
	name = "Linear"
	description = "Go from one value to another at a constant rate."
	value = LINEAR_EASING

/datum/animate_easing/sine
	name = "Sine"
	description = "The animation follows a sine curve, so it starts off and finishes slowly, with a quicker transition in the middle."
	value = SINE_EASING

/datum/animate_easing/circular
	name = "Circular"
	description = "Similar to a sine curve, but each half of the curve is shaped like a quarter circle."
	value = CIRCULAR_EASING

/datum/animate_easing/quad
	name = "Quadratic"
	description = "A quadratic curve, good for gravity effects."
	value = QUAD_EASING

/datum/animate_easing/cubic
	name = "Cubic"
	description = "A cubic curve, a little more pronounced than a sine curve."
	value = CUBIC_EASING

/datum/animate_easing/bounce
	name = "Bounce"
	description = "This transitions quickly like a falling object, and bounces a few times."
	value = BOUNCE_EASING

/datum/animate_easing/elastic
	name = "Elastic"
	description = "This transitions quickly and overshoots, rebounds, and finally settles down."
	value = ELASTIC_EASING

/datum/animate_easing/back
	name = "Back"
	description = "Goes a little bit backward at first, and overshoots a little at the end."
	value = BACK_EASING

/datum/animate_easing/jump
	name = "Jump"
	description = "Jumps suddenly from the beginning state to the end. With the default or EASE_OUT, this happens at the end of the time slice. With EASE_IN, the jump happens at the beginning. With both flags set, the jump happens at the halfway point."
	value = JUMP_EASING
