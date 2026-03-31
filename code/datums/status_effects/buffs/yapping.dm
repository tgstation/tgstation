#define TALK_FILTER "talking_filter"

// Applies talking animations until you are done talking
/datum/status_effect/yapping
	id = "absorb_stun"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	duration = 4

/datum/status_effect/yapping/on_creation(mob/living/new_owner, yaps, mask_icon, mask_icon_state)
	. = ..()
	duration = 0 // haha we lied to you so that you'd start processing
	new_owner.add_filter(TALK_FILTER, 1, displacement_map_filter(icon = icon(mask_icon, mask_icon_state), size = 0))
	add_yaps(yaps)

/datum/status_effect/yapping/refresh(effect, yaps)
	. = ..()
	add_yaps(yaps)

/datum/status_effect/yapping/on_remove()
	. = ..()
	owner.remove_filter(TALK_FILTER)

/datum/status_effect/yapping/proc/add_yaps(yaps)
	var/filter = owner.get_filter(TALK_FILTER)
	for (var/i in 1 to yaps)
		var/yap_time = rand(3, 5)
		duration += yap_time DECISECONDS
		var/anim_time = (yap_time / 2) DECISECONDS
		animate(filter, size = rand(1, 2), time = anim_time, flags = ANIMATION_CONTINUE)
		animate(size = 0, time = anim_time, flags = ANIMATION_CONTINUE)

#undef TALK_FILTER
