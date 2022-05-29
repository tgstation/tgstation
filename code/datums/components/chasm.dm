// Used by /turf/open/chasm and subtypes to implement the "dropping" mechanic
/datum/component/chasm
	var/turf/target_turf
	var/fall_message = "GAH! Ah... where are you?"
	var/oblivion_message = "You stumble and stare into the abyss before you. It stares back, and you fall into the enveloping dark."

	/// List of refs to falling objects -> how many levels deep we've fallen
	var/static/list/falling_atoms = list()
	var/static/list/forbidden_types = typecacheof(list(
		/obj/singularity,
		/obj/energy_ball,
		/obj/narsie,
		/obj/docking_port,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/projectile,
		/obj/effect/projectile,
		/obj/effect/portal,
		/obj/effect/abstract,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/temp_visual,
		/obj/effect/light_emitter/tendril,
		/obj/effect/collapse,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/dummy/phased_mob,
		/obj/effect/mapping_helpers,
		/obj/effect/wisp,
	))

/datum/component/chasm/Initialize(turf/target)
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/Entered)
	target_turf = target
	START_PROCESSING(SSobj, src) // process on create, in case stuff is still there

/datum/component/chasm/proc/Entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	START_PROCESSING(SSobj, src)
	drop_stuff(arrived)

/datum/component/chasm/process()
	if (!drop_stuff())
		STOP_PROCESSING(SSobj, src)

/datum/component/chasm/proc/is_safe()
	//if anything matching this typecache is found in the chasm, we don't drop things
	var/static/list/chasm_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))

	var/atom/parent = src.parent
	var/list/found_safeties = typecache_filter_list(parent.contents, chasm_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/datum/component/chasm/proc/drop_stuff(AM)
	if (is_safe())
		return FALSE

	var/atom/parent = src.parent
	var/to_check = AM ? list(AM) : parent.contents
	for (var/thing in to_check)
		if (droppable(thing))
			. = TRUE
			INVOKE_ASYNC(src, .proc/drop, thing)

/datum/component/chasm/proc/droppable(atom/movable/AM)
	var/datum/weakref/falling_ref = WEAKREF(AM)
	// avoid an infinite loop, but allow falling a large distance
	if(falling_atoms[falling_ref] && falling_atoms[falling_ref] > 30)
		return FALSE
	if(!isliving(AM) && !isobj(AM))
		return FALSE
	if(is_type_in_typecache(AM, forbidden_types) || AM.throwing || (AM.movement_type & (FLOATING|FLYING)))
		return FALSE
	//Flies right over the chasm
	if(ismob(AM))
		var/mob/M = AM
		if(M.buckled) //middle statement to prevent infinite loops just in case!
			var/mob/buckled_to = M.buckled
			if((!ismob(M.buckled) || (buckled_to.buckled != M)) && !droppable(M.buckled))
				return FALSE
		if(ishuman(AM))
			var/mob/living/carbon/human/victim = AM
			if(istype(victim.belt, /obj/item/wormhole_jaunter))
				var/obj/item/wormhole_jaunter/jaunter = victim.belt
				var/turf/chasm = get_turf(victim)
				var/fall_into_chasm = jaunter.chasm_react(victim)
				if(!fall_into_chasm)
					chasm.visible_message(span_boldwarning("[victim] falls into the [chasm]!")) //To freak out any bystanders
				return fall_into_chasm
	return TRUE

/datum/component/chasm/proc/drop(atom/movable/AM)
	var/datum/weakref/falling_ref = WEAKREF(AM)
	//Make sure the item is still there after our sleep
	if(!AM || !falling_ref?.resolve())
		falling_atoms -= falling_ref
		return
	falling_atoms[falling_ref] = (falling_atoms[falling_ref] || 0) + 1
	var/turf/T = target_turf

	if(T)
		// send to the turf below
		AM.visible_message(span_boldwarning("[AM] falls into [parent]!"), span_userdanger("[fall_message]"))
		T.visible_message(span_boldwarning("[AM] falls from above!"))
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Paralyze(100)
			L.adjustBruteLoss(30)
		falling_atoms -= falling_ref

	else
		// send to oblivion
		AM.visible_message(span_boldwarning("[AM] falls into [parent]!"), span_userdanger("[oblivion_message]"))
		if (isliving(AM))
			var/mob/living/L = AM
			L.notransform = TRUE
			L.Paralyze(20 SECONDS)

		var/oldtransform = AM.transform
		var/oldcolor = AM.color
		var/oldalpha = AM.alpha
		animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
		for(var/i in 1 to 5)
			//Make sure the item is still there after our sleep
			if(!AM || QDELETED(AM))
				return
			AM.pixel_y--
			sleep(2)

		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return

		if(iscyborg(AM))
			var/mob/living/silicon/robot/S = AM
			qdel(S.mmi)
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.stat != DEAD)
				L.death(TRUE)

		falling_atoms -= falling_ref
		qdel(AM)
		if(AM && !QDELETED(AM)) //It's indestructible
			var/atom/parent = src.parent
			parent.visible_message(span_boldwarning("[parent] spits out [AM]!"))
			AM.alpha = oldalpha
			AM.color = oldcolor
			AM.transform = oldtransform
			AM.throw_at(get_edge_target_turf(parent,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))
