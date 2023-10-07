/datum/action/cooldown/slasher/blood_walk
	name = "Blood Trail"
	desc = "Begin trailing blood in your wake. Spooky! "
	button_icon_state = "trail_blood"

	cooldown_time = 30 SECONDS

/datum/action/cooldown/slasher/blood_walk/Activate(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/mob_target = target
		mob_target.set_timed_status_effect(15 SECONDS, /datum/status_effect/blood_trial)


/datum/status_effect/blood_trial
	id = "blood_trial"
	alert_type = null

/datum/status_effect/blood_trial/on_creation(mob/living/new_owner, duration = 15 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/blood_trial/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	return TRUE

/datum/status_effect/blood_trial/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)


/datum/status_effect/blood_trial/proc/find_pool_by_blood_state(turf/turfLoc, typeFilter = null)
	for(var/obj/effect/decal/cleanable/blood/pool in turfLoc)
		if(pool.blood_state == BLOOD_STATE_HUMAN && (!typeFilter || istype(pool, typeFilter)))
			return pool


/datum/status_effect/blood_trial/proc/on_move(atom/movable/mover, turf/old_loc)
	var/turf/oldLocTurf = get_turf(old_loc)
	if(prob(5))
		for(var/mob/living/carbon/human/human in view(7, oldLocTurf))
			if(human == owner)
				continue
			human.emote("scream")
			human.stamina.adjust(-5)
			human.Shake(duration = 3 SECONDS)
			human.emote("cries blood")
			var/turf/turf = get_turf(human)
			var/list/blood_drop = list(human.get_blood_id() = 3)
			turf.add_liquid_list(blood_drop, FALSE, 300)

	var/obj/effect/decal/cleanable/blood/footprints/oldLocFP = find_pool_by_blood_state(oldLocTurf, /obj/effect/decal/cleanable/blood/footprints)
	if(oldLocFP)
		// Footprints found in the tile we left, add us to it
		if (!(oldLocFP.exited_dirs & mover.dir))
			oldLocFP.exited_dirs |= mover.dir
			oldLocFP.update_appearance()

	else
		oldLocFP = new(oldLocTurf)
		if(!QDELETED(oldLocFP)) ///prints merged
			oldLocFP.blood_state = BLOOD_STATE_HUMAN
			oldLocFP.exited_dirs |= mover.dir
			oldLocFP.bloodiness = 100
			oldLocFP.update_appearance()

	var/obj/effect/decal/cleanable/blood/footprints/FP = new(get_turf(100))
	if(!QDELETED(FP)) ///prints merged
		FP.blood_state = BLOOD_STATE_HUMAN
		FP.entered_dirs |= mover.dir
		FP.bloodiness = 100
		FP.update_appearance()

