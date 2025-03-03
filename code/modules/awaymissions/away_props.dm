/obj/effect/oneway
	name = "one way effect"
	desc = "Only lets things in from its dir."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE

/obj/effect/oneway/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return . && (REVERSE_DIR(border_dir) == dir || get_turf(mover) == get_turf(src))


/obj/effect/wind
	name = "wind effect"
	desc = "Creates pressure effect in its direction. Use sparingly."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"
	invisibility = INVISIBILITY_MAXIMUM
	var/strength = 30

/obj/effect/wind/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/effect/wind/process()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.consider_pressure_difference(get_step(T,dir),strength)

//Keep these rare due to cost of doing these checks
/obj/effect/path_blocker
	name = "magic barrier"
	desc = "You shall not pass."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "blocker" //todo make this actually look fine when visible
	anchored = TRUE
	var/list/blocked_types = list()
	var/reverse = FALSE //Block if path not present

/obj/effect/path_blocker/Initialize(mapload)
	. = ..()
	if(blocked_types.len)
		blocked_types = typecacheof(blocked_types)

/obj/effect/path_blocker/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(blocked_types.len)
		var/list/mover_contents = mover.get_all_contents()
		for(var/atom/movable/thing in mover_contents)
			if(blocked_types[thing.type])
				return reverse
	return !reverse

GLOBAL_LIST_EMPTY(identity_barriers)

/obj/effect/identity_barrier
	name = "identity barrier"
	desc = "Lets a person through, then only allows that person to come and go."
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo_no_anim"
	anchored = TRUE
	density = TRUE
	var/mob/living/allowed_entity
	var/key = "default"

/obj/effect/identity_barrier/Initialize(mapload)
	. = ..()
	update_description()
	GLOB.identity_barriers += src

/obj/effect/identity_barrier/Destroy(force)
	allowed_entity = null
	GLOB.identity_barriers -= src
	. = ..()

/obj/effect/identity_barrier/proc/update_description()
	desc = initial(desc)
	if(allowed_entity)
		desc += "It is currently bound to [allowed_entity]."
	else
		desc += "It is not currently bound to any entity."

/obj/effect/identity_barrier/Bumped(atom/movable/bumped_atom)
	. = ..()
	// No point if this is false
	if(!.)
		return
	// Any non-mob can pass. This does include teleport beacons, quantum inverters, etc etc, so be careful!
	if(!ismob(bumped_atom))
		return TRUE
	var/mob/living/living_mover = bumped_atom
	// No marked entity set...
	if(isnull(allowed_entity))
		// We're going to check all other barriers. If they're part of the same system (key) and they also have this entity set, they won't allow them through.
		for(var/obj/effect/identity_barrier/barrier in GLOB.identity_barriers)
			// The entity is being greedy, bar entry.
			if(barrier.key == src.key && barrier.allowed_entity == living_mover)
				visible_message("[src] detects another barried keyed to [allowed_entity] and refuses [living_mover.p_them()] passage!")
				flash_red()
				return FALSE
		// This is the first barrier in the system for them, let them through.
		allowed_entity = living_mover
		update_description()
		visible_message("[src] pulses as [living_mover] passes through, marking [living_mover.p_them()] as the only allowed creature!")
//		playsound(src, 'sound/magic/staff_chaos.ogg', 25, TRUE)
		ASYNC
			animate(src, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
			sleep(0.5 SECONDS)
			animate(src, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)
		return TRUE

	// Yes marked entity and the mover is said entity? Let them through.
	if(living_mover == allowed_entity)
		return TRUE

	// No success condition passed, blare out an error and return false.
	flash_red()

	return FALSE

/obj/effect/identity_barrier/proc/flash_red()
	var/oldcolor = color
	color = rgb(255, 0, 0)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 0.5 SECONDS)

/obj/effect/faction_barrier
	name = "faction barrier"
	desc = "Only lets a specific faction enter!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo_no_anim"
	anchored = TRUE
	density = TRUE
	/// If the passing mob has any faction listed here it will be able to pass.
	var/list/allowed_factions = list(FACTION_MONKEY)

/obj/effect/faction_barrier/Initialize(mapload)
	. = ..()
	RegisterSignal(get_turf(src), COMSIG_TURF_PREPARE_STEP_SOUND)

/obj/effect/faction_barrier/Bumped(atom/movable/bumped_atom)
	. = ..()
	// No point if this is false
	if(!.)
		return
	// Any non-mob can pass. This does include teleport beacons, quantum inverters, etc etc, so be careful!
	if(!ismob(bumped_atom))
		return TRUE
	var/mob/living/living_mover = bumped_atom
	// Checks factions. If at least one is shared let them through.
	if(faction_check(living_mover.faction, allowed_factions, exact_match = FALSE))
		ASYNC
			animate(src, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
			sleep(0.5 SECONDS)
			animate(src, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)
		return TRUE

	// No success condition passed, blare out an error and return false.
	ASYNC
		var/oldcolor = color
		color = rgb(255, 0, 0)
		animate(src, color = oldcolor, time = 5)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 0.5 SECONDS)

	return FALSE

/obj/effect/faction_barrier/syndicate
	allowed_factions = list(ROLE_SYNDICATE, FACTION_RUSSIAN)

/obj/structure/pitgrate
	name = "pit grate"
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-255"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	var/id
	var/open = FALSE
	var/hidden = FALSE

/obj/structure/pitgrate/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs,COMSIG_GLOB_BUTTON_PRESSED, PROC_REF(OnButtonPressed))
	if(hidden)
		update_openspace()

/obj/structure/pitgrate/proc/OnButtonPressed(datum/source,obj/machinery/button/button)
	SIGNAL_HANDLER

	if(button.id == id) //No range checks because this is admin abuse mostly.
		toggle()

/obj/structure/pitgrate/proc/update_openspace()
	var/turf/open/openspace/T = get_turf(src)
	if(!istype(T))
		return
	//Simple way to keep plane conflicts away, could probably be upgraded to something less nuclear with 513
	if(!open)
		T.SetInvisibility(INVISIBILITY_MAXIMUM, id=type)
	else
		T.RemoveInvisibility(type)

/obj/structure/pitgrate/proc/toggle()
	open = !open
	var/talpha
	if(open)
		talpha = 0
		obj_flags &= ~(BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP)
	else
		talpha = 255
		obj_flags |= BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	SET_PLANE_IMPLICIT(src, ABOVE_LIGHTING_PLANE) //What matters it's one above openspace, so our animation is not dependant on what's there. Up to revision with 513
	layer = ABOVE_NORMAL_TURF_LAYER
	animate(src,alpha = talpha,time = 10)
	addtimer(CALLBACK(src, PROC_REF(reset_plane)), 1 SECONDS)
	if(hidden)
		update_openspace()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in T)
		if(!AM.currently_z_moving)
			T.zFall(AM)

/obj/structure/pitgrate/proc/reset_plane()
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/pitgrate/Destroy()
	if(hidden)
		open = TRUE
		update_openspace()
	. = ..()

/obj/structure/pitgrate/hidden
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	hidden = TRUE

/// only player mobs (has ckey) may pass, reverse for the opposite
/obj/effect/playeronly_barrier
	name = "player-only barrier"
	desc = "You shall pass."
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "blocker"
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	var/reverse = FALSE //Block if has ckey

/obj/effect/playeronly_barrier/CanAllowThrough(mob/living/mover, border_dir)
	. = ..()
	if(!istype(mover))
		return
	return isnull(mover.ckey) == reverse

/obj/effect/invisible_wall // why didnt we have this already
	name = "invisible wall"
	desc = "You shall not pass"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "blocker"
	color = COLOR_BLUE_LIGHT
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE

/obj/effect/invisible_wall/CanAllowThrough(mob/living/mover, border_dir)
	..()
	return FALSE // NO
