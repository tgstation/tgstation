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

/datum/status_effect/agent_pinpointer/xeno/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there)<=minimum_range + rand(0, range_fuzz_factor))
		linked_alert.icon_state = "pinondirect"
	else
		linked_alert.setDir(get_dir(here, there))
		var/dist = (get_dist(here, there))
		if(dist >= 1 && dist <= range_mid)
			linked_alert.icon_state = "pinonclose"
		else if(dist > range_mid && dist <= range_far)
			linked_alert.icon_state = "pinonmedium"
		else if(dist > range_far)
			linked_alert.icon_state = "pinonfar"

/datum/status_effect/agent_pinpointer/xeno/scan_for_target()
	scan_target = null
	if(!owner)
		return
	if(!owner.mind)
		return
	var/mob/queen = get_alien_type(/mob/living/carbon/human/species/alien/humanoid/royal/queen)
	if(!queen || queen = owner)
		return
	scan_target = queen

