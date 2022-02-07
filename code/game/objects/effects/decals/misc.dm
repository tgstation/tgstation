/obj/effect/temp_visual/point
	name = "pointer"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "arrow"
	plane = POINT_PLANE
	duration = 25

/obj/effect/temp_visual/point/Initialize(mapload, set_invis = 0)
	. = ..()
	var/atom/old_loc = loc
	abstract_move(get_turf(src))
	pixel_x = old_loc.pixel_x
	pixel_y = old_loc.pixel_y
	invisibility = set_invis

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = FLY_LAYER
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

/obj/effect/decal/chempuff/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/obj/effect/decal/chempuff/proc/check_move(datum/move_loop/source, succeeded)
	if(QDELETED(src)) //Reasons PLEASE WORK I SWEAR TO GOD
		return
	if(!succeeded) //If we hit something
		qdel(src)
		return

	var/puff_reagents_string = reagents.log_list()
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
		qdel(src)

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	density = TRUE
