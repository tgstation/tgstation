/datum/action/cooldown/spell/conjure
	sound = 'sound/items/tools/welder.ogg'
	school = SCHOOL_CONJURATION

	/// The radius around the caster the items will appear. 0 = spawns on top of the caster.
	var/summon_radius = 7
	/// A list of types that will be created on summon.
	/// The type is picked from this list, not all provided are guaranteed.
	var/list/summon_type = list()
	/// How long before the summons will be despawned. Set to 0 for permanent.
	var/summon_lifespan = 0
	/// Amount of summons to create.
	var/summon_amount = 1
	/// If TRUE, summoned objects will not be spawned in dense turfs.
	var/summon_respects_density = FALSE
	/// If TRUE, no two summons can be spawned in the same turf.
	var/summon_respects_prev_spawn_points = TRUE
	/// for how long must we stay still when summoning
	var/create_summon_timer

/datum/action/cooldown/spell/conjure/is_valid_target(atom/cast_on)
	return isturf(cast_on.loc)

/datum/action/cooldown/spell/conjure/cast(atom/cast_on)
	. = ..()
	if(create_summon_timer && !do_after(owner, create_summon_timer, target = cast_on.loc))
		owner?.balloon_alert(owner, "need to stay still!")
		return
	var/list/to_summon_in = list()
	for(var/turf/summon_turf in range(summon_radius, cast_on))
		if(summon_respects_density && summon_turf.density)
			continue
		to_summon_in += summon_turf

	for(var/i in 1 to summon_amount)
		if(!length(to_summon_in))
			break

		var/atom/summoned_object_type = pick(summon_type)
		var/turf/spawn_place = pick(to_summon_in)
		if(summon_respects_prev_spawn_points)
			to_summon_in -= spawn_place

		if(ispath(summoned_object_type, /turf))
			if(isclosedturf(spawn_place))
				spawn_place.ChangeTurf(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
				return
			if(ispath(summoned_object_type, /turf/closed))
				if (spawn_place.overfloor_placed)
					spawn_place.ChangeTurf(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
				else
					spawn_place.place_on_top(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
				return
			var/turf/open/open_turf = spawn_place
			open_turf.replace_floor(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
			return

		var/atom/summoned_object = new summoned_object_type(spawn_place)

		summoned_object.flags_1 |= ADMIN_SPAWNED_1
		if(summon_lifespan > 0)
			QDEL_IN(summoned_object, summon_lifespan)

		post_summon(summoned_object, cast_on)

/// Called on atoms summoned after they are created, allows extra variable editing and such of created objects
/datum/action/cooldown/spell/conjure/proc/post_summon(atom/summoned_object, atom/cast_on)
	return

///limits the amount of summons
/datum/action/cooldown/spell/conjure/limit_summons
	///max number of after images
	var/max_summons
	///How many clones do we have summoned
	var/number_of_summons = 0

/datum/action/cooldown/spell/conjure/limit_summons/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(number_of_summons >= max_summons)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/conjure/limit_summons/post_summon(atom/summoned_object, atom/cast_on)
	RegisterSignals(summoned_object, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(delete_copy))
	number_of_summons++

/datum/action/cooldown/spell/conjure/limit_summons/proc/delete_copy(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	number_of_summons--
