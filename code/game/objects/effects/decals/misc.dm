//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/medical/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	///The mob who sourced this puff, if one exists
	var/mob/user
	///The sprayer who fired this puff
	var/obj/item/reagent_containers/spray/sprayer
	///How many interactions we have left before we disappear early
	var/lifetime = INFINITY
	///Are we a part of a stream?
	var/stream

/obj/effect/decal/chempuff/Destroy(force)
	user = null
	sprayer = null
	return ..()

/obj/effect/decal/chempuff/blob_act(obj/structure/blob/B)
	return

/obj/effect/decal/chempuff/proc/end_life(datum/move_loop/engine)
	QDEL_IN(src, engine.delay) //Gotta let it stop drifting
	animate(src, alpha = 0, time = engine.delay)

/obj/effect/decal/chempuff/proc/loop_ended(datum/move_loop/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	end_life(source)

/obj/effect/decal/chempuff/proc/check_move(datum/move_loop/source, succeeded)
	if(QDELETED(src)) //Reasons PLEASE WORK I SWEAR TO GOD
		return
	if(!succeeded) //If we hit something
		end_life(source)
		return

	var/puff_reagents_string = reagents.get_reagent_log_string()
	var/travelled_max_distance = (source.lifetime - source.delay <= 0)
	var/turf/our_turf = get_turf(src)

	for(var/atom/movable/turf_atom in our_turf)
		if(turf_atom == src || turf_atom.invisibility) //we ignore the puff itself and stuff below the floor
			continue

		if(lifetime < 0)
			break

		if(!stream)
			reagents.expose(turf_atom, VAPOR)
			log_combat(user, turf_atom, "sprayed", sprayer, addition="which had [puff_reagents_string]")
			if(ismob(turf_atom))
				lifetime -= 1
			continue

		if(isliving(turf_atom))
			var/mob/living/turf_mob = turf_atom

			if(!turf_mob.can_inject())
				continue
			if(turf_mob.body_position != STANDING_UP && !travelled_max_distance)
				continue

			reagents.expose(turf_mob, VAPOR)
			log_combat(user, turf_mob, "sprayed", sprayer, addition="which had [puff_reagents_string]")
			lifetime -= 1

		else if(travelled_max_distance)
			reagents.expose(turf_atom, VAPOR)
			log_combat(user, turf_atom, "sprayed", sprayer, addition="which had [puff_reagents_string]")
			lifetime -= 1

	if(lifetime >= 0 && (!stream || travelled_max_distance))
		reagents.expose(our_turf, VAPOR)
		log_combat(user, our_turf, "sprayed", sprayer, addition="which had [puff_reagents_string]")
		lifetime -= 1

	// Did we use up all the puff early?
	if(lifetime < 0)
		end_life(source)

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	density = TRUE
