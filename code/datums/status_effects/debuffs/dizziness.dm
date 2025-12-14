/datum/status_effect/dizziness
	id = "dizziness"
	tick_interval = 2 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/dizziness/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/dizziness/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_dizziness))
	return TRUE

/datum/status_effect/dizziness/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	// In case our client's offset is somewhere wacky from the dizziness effect
	owner.client?.pixel_x = initial(owner.client?.pixel_x)
	owner.client?.pixel_y = initial(owner.client?.pixel_y)

/// Signal proc that self deletes our dizziness effect
/datum/status_effect/dizziness/proc/clear_dizziness(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/dizziness/tick(seconds_between_ticks)
	// How much time is left, in seconds
	var/amount = duration / 10
	if(amount <= 0)
		return

	// How strong the dizziness effect is on us.
	// If we're resting, the effect is 5x as strong, but also decays 5x fast.
	// Meaning effectively, 1 tick is actually dizziness_strength ticks of duration
	var/dizziness_strength = owner.resting ? 5 : 1

	// How much time will be left, in seconds, next tick
	var/next_amount = max((amount - (dizziness_strength * seconds_between_ticks * 0.1)), 0)

	// If we have a dizziness strength > 1, we will subtract ticks off of the total duration
	if(remove_duration((dizziness_strength - 1) * seconds_between_ticks))
		return

	// Now we can do the actual dizzy effects.
	// Don't bother animating if they're clientless.
	if(!owner.client)
		return

	// Want to be able to offset things by the time the animation should be "playing" at
	var/time = world.time
	var/delay = 0
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	// This shit is annoying at high strengthvar/pixel_x_diff = 0
	var/list/view_range_list = getviewsize(owner.client.view)
	var/view_range = view_range_list[1]
	var/amplitude = amount * (sin(amount * (time)) + 1)
	var/x_diff = clamp(amplitude * sin(amount * time), -view_range, view_range)
	var/y_diff = clamp(amplitude * cos(amount * time), -view_range, view_range)
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
