/datum/action/cooldown/spell/cone/staggered/cone_of_cold
	name = "Cone of Cold"
	desc = "Shoots out a freezing cone in front of you."

	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 4 SECONDS

	invocation = "ISAGE!" // What killed the dinosaurs? THE ICE AGE
	invocation_type = INVOCATION_SHOUT

	cone_levels = 4
	respect_density = TRUE
	delay_between_level = 0.05 SECONDS

	/// What flags do we pass to MakeSlippery when affecting turfs?
	/// null / NONE / TURF_DRY means the turf is unaffected
	var/turf_freeze_type = TURF_WET_PERMAFROST
	/// How long do turfs remain slippery / frozen for?
	/// 0 seconds means the turf is unaffected, INFINITY means it's made perma-wet
	var/unfreeze_turf_duration = 45 SECONDS

	/// What status effect do we apply when affecting mobs?
	/// null means no status effect is applied
	var/datum/status_effect/frozen_status_effect_path = /datum/status_effect/freon/lasting
	/// How long do mobs remain frozen for?
	/// 0 seconds means no status effect is applied, INFINITY means infinite duration (or default duration of the status effect)
	var/unfreeze_mob_duration = 20 SECONDS
	/// How much brute do we apply on freeze?
	var/on_freeze_brute_damage = 10
	/// How much burn do we apply on freeze?
	var/on_freeze_burn_damage = 20

	/// How long do objects remain frozen for?
	/// 0 seconds mean no objects are frozen, INFINITY means infinite duration freeze
	var/unfreeze_object_duration = 20 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	if(!turf_freeze_type || unfreeze_turf_duration <= 0 SECONDS) // 0 duration = don't apply the slip
		return
	if(!isopenturf(target_turf))
		return
	var/turf/open/frozen_floor = target_turf
	frozen_floor.MakeSlippery(turf_freeze_type, unfreeze_turf_duration, permanent = (unfreeze_turf_duration == INFINITY))

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(target_mob.can_block_magic(antimagic_flags) || target_mob == caster)
		return

	if(ispath(frozen_status_effect_path) && unfreeze_mob_duration > 0 SECONDS) // 0 duration = don't apply the status effect
		var/datum/status_effect/freeze = target_mob.apply_status_effect(frozen_status_effect_path)
		if(unfreeze_mob_duration != INFINITY)
			freeze.duration = world.time + unfreeze_mob_duration

	if(on_freeze_brute_damage || on_freeze_burn_damage)
		target_mob.take_overall_damage(on_freeze_brute_damage, on_freeze_burn_damage)

	to_chat(target_mob, span_userdanger("You feel a bitter cold!"))

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	if(unfreeze_object_duration <= 0 SECONDS) // 0 duration = don't apply a freeze
		return
	if(!target_obj.freeze())
		return
	if(unfreeze_object_duration == INFINITY) // Infinity duration = don't set an unfreeze timer
		return
	addtimer(CALLBACK(target_obj, TYPE_PROC_REF(/obj/, unfreeze)), unfreeze_object_duration)
