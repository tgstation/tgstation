#define PINPOINTER_MINIMUM_RANGE 15
#define PINPOINTER_EXTRA_RANDOM_RANGE 10
#define PINPOINTER_PING_TIME (4 SECONDS)

/atom/movable/screen/alert/status_effect/agent_pinpointer
	name = "Target Integrated Pinpointer"
	desc = "Even stealthier than a normal implant, it points to any assassination target you have."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer
	id = "agent_pinpointer"
	duration = -1
	tick_interval = PINPOINTER_PING_TIME
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer
	///The minimum range to start pointing towards your target.
	var/minimum_range = PINPOINTER_MINIMUM_RANGE
	///How fuzzy will the pinpointer be, messing with it pointing to your target.
	var/range_fuzz_factor = PINPOINTER_EXTRA_RANDOM_RANGE
	///The range until you're considered 'close'
	var/range_mid = 8
	///The range until you're considered 'too far away'
	var/range_far = 16
	///The target we are pointing towards, refreshes every tick.
	var/mob/scan_target

/datum/status_effect/agent_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	scan_for_target()
	point_to_target()

///Show the distance and direction of a scanned target
/datum/status_effect/agent_pinpointer/proc/point_to_target()
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return

	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)

	if(here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there) <= minimum_range + rand(0, range_fuzz_factor))
		linked_alert.icon_state = "pinondirect"
		return
	linked_alert.setDir(get_dir(here, there))

	var/dist = (get_dist(here, there))
	if(dist >= 1 && dist <= range_mid)
		linked_alert.icon_state = "pinonclose"
	else if(dist > range_mid && dist <= range_far)
		linked_alert.icon_state = "pinonmedium"
	else if(dist > range_far)
		linked_alert.icon_state = "pinonfar"

///Attempting to locate a nearby target to scan and point towards.
/datum/status_effect/agent_pinpointer/proc/scan_for_target()
	scan_target = null
	if(!owner && !owner.mind)
		return
	for(var/datum/objective/assassinate/objective_datums as anything in owner.mind.get_all_objectives())
		if(!objective_datums.target || !objective_datums.target.current || objective_datums.target.current.stat == DEAD)
			continue
		var/mob/tracked_target = objective_datums.target.current
		//JUUUST in case.
		if(!tracked_target)
			continue

		//Catch the first one we find, then stop. We want to point to the most recent one we've got.
		scan_target = tracked_target
		break

#undef PINPOINTER_EXTRA_RANDOM_RANGE
#undef PINPOINTER_MINIMUM_RANGE
#undef PINPOINTER_PING_TIME
