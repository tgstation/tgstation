/datum/action/cooldown/spell/cone/staggered/cone_of_cold
	name = "Cone of Cold"
	desc = "Shoots out a freezing cone in front of you."

	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 4 SECONDS

	invocation = "ISAGE!" // What killed the dinosaurs? THE ICE AGE
	invocation_type = INVOCATION_SHOUT

	cone_levels = 4
	delay_between_level = 0.05 SECONDS

	/// What flags do we pass to MakeSlippery when affecting turfs?
	var/turf_freeze_type = TURF_WET_PERMAFROST
	/// How long do turfs remain slippery / frozen for?
	var/unfreeze_turf_duration = 45 SECONDS

	/// What status effect do we apply when affecting mobs?
	var/frozen_status_effect_path = /datum/status_effect/freon/lasting
	/// How long do mobs remain frozen for?
	var/unfreeze_mob_duration = 20 SECONDS

	/// How long do objects remain frozen for?
	var/unfreeze_object_duration = 20 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/calculate_cone_shape(current_level)
	// Level 2 will always be three wide.
	if(current_level == 2)
		return 3

	// But, after level 2, we will only grow once every two levels.
	// Even levels will return the normal formula - 1
	if(ISEVEN(current_level))
		return ..(current_level - 1)

	// Odd levels will return the normal formula
	return ..()

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	if(!isopenturf(target_turf))
		return
	var/turf/open/frozen_floor = target_turf
	frozen_floor.MakeSlippery(turf_freeze_type, unfreeze_turf_duration)

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(target_mob.can_block_magic(antimagic_flags) || target_mob == caster)
		return

	target_mob.apply_status_effect(frozen_status_effect_path)
	addtimer(CALLBACK(target_mob, /mob/living.proc/remove_status_effect, frozen_status_effect_path), unfreeze_mob_duration)

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	if(!target_obj.freeze())
		return
	addtimer(CALLBACK(target_obj, /obj.proc/unfreeze), unfreeze_object_duration)
