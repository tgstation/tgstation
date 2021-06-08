/**
 * # objective returner element!
 *
 * "The issue with steal objectives being off-station or destroyed could be solved by having
 * a new one delivered/existing one retrieved by droppod to its owner after a random delay
 * (to reduce gaming it like with the nuke disk). You'd have to do this with any object
 * that could be an objective anytime (or any object that is an objective)." - caco
 */
/datum/element/objective_returner
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///the job datum of whatever job "owns" this steal objective. if none is given, it will be returned on the cargo shuttle
	var/datum/job/job_datum_owner

/datum/element/objective_returner/Attach(datum/target, job_datum_owner)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.job_datum_owner = job_datum_owner
	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/on_z_level_changed)
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/on_dropped)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/element/objective_returner/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_EXAMINE))

///signal called by examining the target
/datum/element/objective_returner/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += "<span class='notice'>[source] has some kind of automatic return tech installed. \
					If it is lost in deep space, it will return to its owner.</span>"

///signal called by dropping the target
/datum/element/objective_returner/proc/on_dropped(atom/movable/target, mob/dropper)
	SIGNAL_HANDLER

	if(!is_station_level(target.z) || !is_centcom_level(target.z))
		relocate(target)

///signal called by the stat of the target changing
/datum/element/objective_returner/proc/on_z_level_changed(atom/movable/target, old_z, new_z)
	SIGNAL_HANDLER

	///check to see if we're held by someone
	var/holding
	var/atom/loc_checking = target
	while(!holding)
		loc_checking = loc_checking.loc
		if(isturf(loc_checking))
			break
		if(isliving(loc_checking))
			holding = loc_checking
	if(holding)
		return
	if(is_station_level(new_z) || is_centcom_level(new_z))
		return
	relocate(target)

/datum/element/objective_returner/proc/relocate(atom/movable/target)
	var/turf/landing_target

	if(job_datum_owner)
		for(var/mob/living/carbon/human/crewmember as anything in GLOB.human_list)
			if(!crewmember.mind)
				continue
			if(!is_station_level(crewmember.z) || !is_centcom_level(crewmember.z))
				continue
			if(crewmember.mind.assigned_role != job_datum_owner.title)
				continue
			landing_target = get_turf(crewmember)
			break
	else
		var/list/empty_turfs = list()
		for(var/place in SSshuttle.supply.shuttle_areas)
			var/area/shuttle/shuttle_area = place
			for(var/turf/open/floor/T in shuttle_area)
				if(T.is_blocked_turf())
					continue
				empty_turfs += T
		if(!empty_turfs)
			empty_turfs += get_safe_random_station_turf()
		landing_target = pick(empty_turfs)

	var/obj/structure/closet/supplypod/pod = podspawn(list(
		"target" = landing_target,
		"path" = /obj/structure/closet/supplypod/objective_returner
	))
	target.forceMove(pod)

/obj/structure/closet/supplypod/objective_returner
	bluespace = TRUE
	style = STYLE_CENTCOM
	explosionSize = list(0,0,0,0)

/obj/structure/closet/supplypod/objective_returner/setOpened()
	playsound(src, 'sound/machines/triple_beep.ogg')
	say("Your sensitive job equipment has been returned to you. Try not to lose it again!")
	. = ..()
