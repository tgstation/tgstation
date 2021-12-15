#define XENO_PINPOINTER_MINIMUM_RANGE 1
#define XENO_PINPOINTER_EXTRA_RANDOM_RANGE 0

/atom/movable/screen/alert/status_effect/agent_pinpointer/xeno
	name = "queen sense"
	desc = "Allows you to sense the general direction of your Queen."
	icon = 'icons/hud/screen_alien.dmi'
	icon_state = "queen_finder"


/datum/status_effect/agent_pinpointer/xeno_queen
	id = "xeno_pinpointer"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/xeno
	minimum_range = XENO_PINPOINTER_MINIMUM_RANGE
	range_fuzz_factor = XENO_PINPOINTER_EXTRA_RANDOM_RANGE
	range_mid = 8
	range_far = 21

/datum/status_effect/agent_pinpointer/xeno_queen/scan_for_target()
	if(!owner)
		return
	if(!owner.mind)
		return
	var/mob/queen = get_alien_type(/mob/living/carbon/human/species/alien/royal/queen)
	if(!queen || queen == owner)
		return
	scan_target = queen

