///check if an atom is on the reebe z level, will also return FALSE if the atom has no z level
/proc/on_reebe(atom/checked_atom)
	if(!checked_atom.z || !is_reebe_level(checked_atom.z))
		return FALSE
	return TRUE

/proc/gods_battle()
	if(GLOB.cult_narsie && GLOB.cult_ratvar)
		var/datum/component/singularity/narsie_singularity_component = GLOB.cult_narsie.singularity?.resolve()
		var/datum/component/singularity/ratvar_singularity_component = GLOB.cult_ratvar.singularity?.resolve()
		if(!narsie_singularity_component || !ratvar_singularity_component)
			message_admins("gods_battle() called without a singularity component on of of the 2 main gods.")
			return FALSE

		narsie_singularity_component.target = GLOB.cult_ratvar
		ratvar_singularity_component.target = GLOB.cult_narsie
		return TRUE
	return FALSE

/proc/try_servant_warp(mob/living/servant, turf/target_turf)
	var/mob/living/pulled = servant.pulling
	playsound(servant, 'sound/magic/magic_missile.ogg', 50, TRUE) //doing this manually for sound volume reasons
	playsound(target_turf, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(3, TRUE, servant)
	do_sparks(3, TRUE, target_turf)
	do_teleport(servant, target_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	if(ishuman(servant)) //looks weird on non-humanoids
		new /obj/effect/temp_visual/ratvar/warp(target_turf)
	to_chat(servant, "You warp to [get_area(target_turf)].")
	if(istype(pulled))
		do_teleport(pulled, target_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
		if(!IS_CLOCK(pulled))
			pulled.Paralyze(3 SECONDS)
			to_chat(pulled, span_warning("You feel sick and confused."))
