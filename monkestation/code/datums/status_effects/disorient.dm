/datum/status_effect/incapacitating/disoriented
	id = "disoriented"
	tick_interval = 1 SECONDS
	var/last_twitch = 0
	var/paralyze = 0
	var/stun = 0
	var/knockdown = 0

/datum/status_effect/incapacitating/disoriented/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/disoriented/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/incapacitating/disoriented/tick()
	if(last_twitch < world.time + 7 && (!HAS_TRAIT(owner, TRAIT_IMMOBILIZED)))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, twitch))
		playsound(owner, 'sound/effects/zzzt.ogg', 35, TRUE, 0.5, 1.5)
		last_twitch = world.time
	if(HAS_TRAIT(owner, TRAIT_EXHAUSTED) && (stun || knockdown || paralyze))
		if(knockdown)
			owner.AdjustKnockdown(min(knockdown, 15 SECONDS))
			knockdown = 0

		if(paralyze)
			owner.AdjustParalyzed(min(paralyze, 15 SECONDS))
			paralyze = 0

		if(stun)
			owner.AdjustStun(min(stun, 15 SECONDS))
			stun = 0

///An animation for the object shaking wildly.
/atom/movable/proc/twitch()
	var/degrees = rand(-45,45)
	transform = transform.Turn(degrees)
	var/old_x = pixel_x
	var/old_y = pixel_y
	pixel_x += rand(-3,3)
	pixel_y += rand(-1,1)

	sleep(0.2 SECONDS)

	transform = transform.Turn(-degrees)
	pixel_x = old_x
	pixel_y = old_y
