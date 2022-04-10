/datum/status_effect/dizziness
	id = "dizziness"
	tick_interval = 2 SECONDS
	alert_type = null
	/// The strength of the dizziness on us. The stronger the dizzy, the faster it goes away
	var/dizziness_strength = 1

/datum/status_effect/dizziness(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/dizziness/on_apply()
	RegsiterSignal(owner, COMSIG_LIVING_SET_RESTING, .proc/on_rest)
	return TRUE

/datum/status_effect/dizziness/on_remove()
	UnregsiterSignal(owner, COMSIG_LIVING_SET_RESTING)

/// Signal proc for [COMSIG_LIVING_SET_RESTING]. Whenever we rest, it depletes faster but is more dizzying
/datum/status_effect/dizziness/proc/on_rest(mob/living/source)
	SIGNAL_HANDLER

	dizziness_strength = initial(dizziness_strength)
	if(source.resting)
		dizziness_strength *= 3

/datum/status_effect/dizziness/tick()
	// How much time is left, in seconds
	var/amount = (duration - world.time) / 10
	if(amount <= 0)
		return

	// How much time will be left, in seconds, next tick
	var/next_amount = max((amount - (dizziness_strength * tick_interval)) / 10, 0)

	// If we have a high dizziness strength, we subtract from our duration
	// Meaning if our dizzy effects are stronger, it will also run out faster
	if(dizziness_strength > 1)
		duration -= ((dizziness_strength - 1) * tick_interval)

	// Don't bother animating if they're clientless
	if(!owner.client)
		return

	//Want to be able to offset things by the time the animation should be "playing" at
	var/time = world.time
	var/delay = 0
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	// This shit is annoying at high strengthvar/pixel_x_diff = 0
	var/amplitude = amount * (sin(amount * (time)) + 1)
	var/x_diff = amplitude * sin(amount * time)
	var/y_diff = amplitude * cos(amount * time)
	pixel_x_diff += x_diff
	pixel_y_diff += y_diff
	// Brief explanation. We're basically snapping between different pixel_x/ys instantly, with delays between
	// Doing this with relative changes. This way we don't override any existing pixel_x/y values
	// We use EASE_OUT here for similar reasons, we want to act at the end of the delay, not at its start
	// Relative animations are weird, so we do actually need this
	animate(owner.client, pixel_x = x_diff, pixel_y = y_diff, 3, easing = JUMP_EASING | EASE_OUT, flags = ANIMATION_RELATIVE)
	delay += 0.3 SECONDS // This counts as a 0.3 second wait, so we need to shift the sine wave by that much

	x_diff = amplitude * sin(next_amount * (time + delay))
	y_diff = amplitude * cos(next_amount * (time + delay))
	pixel_x_diff += x_diff
	pixel_y_diff += y_diff
	animate(pixel_x = x_diff, pixel_y = y_diff, 3, easing = JUMP_EASING | EASE_OUT, flags = ANIMATION_RELATIVE)

	// Now we reset back to our old pixel_x/y, since these animates are relative
	animate(pixel_x = -pixel_x_diff, pixel_y = -pixel_y_diff, 3, easing = JUMP_EASING | EASE_OUT, flags = ANIMATION_RELATIVE)
