/datum/action/cooldown/spell/conjure
	sound = 'sound/items/welder.ogg'
	school = SCHOOL_CONJURATION

	/// The radius around the caster the items will appear. 0 = spawns beneath the caster
	var/summon_radius = 7
	/// A list of types that will be created on summon.
	/// The type is picked from this list, not all provided are guaranteed.
	var/list/summon_type = list()
	/// How long before the summons will be despawned. Set to 0 for permanent.
	var/summon_lifespan = 0
	/// Amount of summons to create.
	var/summon_amount = 1
	/// Whether summons will avoid being spawned in dense tiles
	var/summon_ignore_density = FALSE
	/// Whether summons will not be spawned in places already chosen
	var/summon_ignore_prev_spawn_points = TRUE

/datum/action/cooldown/spell/conjure/cast(atom/cast_on)
	. = ..()
	var/list/turf/to_summon_in = range(summon_radius, cast_on)

	if(!summon_ignore_density)
		for(var/turf/summon_turf in to_summon_in)
			if(summon_turf.density)
				to_summon_in -= summon_turf

	for(var/i in 1 to summon_amount)
		if(!length(to_summon_in))
			break

		var/atom/summoned_object_type = pick(summon_type)
		var/turf/spawn_place = pick(to_summon_in)
		if(summon_ignore_prev_spawn_points)
			to_summon_in -= spawn_place

		if(ispath(summoned_object_type, /turf))
			spawn_place.ChangeTurf(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)

		else
			var/atom/summoned_object = new summoned_object_type(spawn_place)

			summoned_object.flags_1 |= ADMIN_SPAWNED_1
			if(summon_lifespan > 0)
				QDEL_IN(summoned_object, summon_lifespan)

			post_summon(summoned_object, cast_on)

/// Called on atoms summoned after they are created, allows extra variable editing and such of created objects
/datum/action/cooldown/spell/conjure/proc/post_summon(atom/summoned_object, atom/cast_on)
	return
