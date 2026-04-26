/mob/living/basic/bot/mulebot/execute_resist()
	. = ..()
	if(load)
		unload()

/mob/living/basic/bot/mulebot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == load)
		unload()
	if(gone == cell)
		turn_off()
		cell = null
		diag_hud_set_mulebotcell()

// mousedrop a crate to load the bot
// can load anything if hacked
/mob/living/basic/bot/mulebot/mouse_drop_receive(atom/movable/atom_to_load, mob/user, params)
	if(!isliving(user))
		return

	if(!istype(atom_to_load) || isdead(atom_to_load) || iseyemob(atom_to_load) || istype(atom_to_load, /obj/effect/dummy/phased_mob))
		return

	load(atom_to_load)

/mob/living/basic/bot/mulebot/post_unbuckle_mob(mob/living/M)
	load = null
	return ..()

/mob/living/basic/bot/mulebot/relaymove(mob/living/user, direction)
	if(user.incapacitated)
		return
	if(load == user)
		unload()

/mob/living/basic/bot/mulebot/remove_air(amount) //To prevent riders suffocating
	return loc ? loc.remove_air(amount) : null

/// Called to load an atom on the mulebot, which is usually a crate, unless if hacked
/mob/living/basic/bot/mulebot/proc/load(atom/movable/atom_to_load)
	if(load || atom_to_load.anchored)
		return

	if(!isturf(atom_to_load.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/crate = atom_to_load
	if(!istype(crate))
		if(!wires.is_cut(WIRE_LOADCHECK))
			buzz(MULEBOT_MOOD_SIGH)
			return // if not hacked, only allow crates to be loaded
		crate = null

	if(crate || isobj(atom_to_load))
		var/obj/object_to_load = atom_to_load
		if(object_to_load.has_buckled_mobs() || (locate(/mob) in atom_to_load)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(MULEBOT_MOOD_SIGH)
			return

		if(crate)
			crate.close()  //make sure the crate is closed

		object_to_load.forceMove(src)

	else if(isliving(atom_to_load))
		if(!load_mob(atom_to_load)) //forceMove() is handled in buckling
			return

	load = atom_to_load
	update_appearance()

///resolves the name to display for the loaded mob. primarily needed for the paranormal subtype since we don't want to show the name of ghosts riding it.
/mob/living/basic/bot/mulebot/proc/get_load_name()
	return load ? load.name : null

///Loads a mob onto the mulebot
/mob/living/basic/bot/mulebot/proc/load_mob(mob/living/mob_to_load)
	can_buckle = TRUE
	if(buckle_mob(mob_to_load))
		passenger = mob_to_load
		load = mob_to_load
		can_buckle = FALSE
		return TRUE

// called to unload the bot
// argument is optional direction to unload
// if zero or null, unload at bot's location
/mob/living/basic/bot/mulebot/proc/unload(dirn)
	if(QDELETED(load))
		if(load) //if our thing was qdel'd, there's likely a leftover reference. just clear it and remove the overlay. we'll let the bot keep moving around to prevent it abruptly stopping somewhere.
			load = null
			update_appearance()
		return

	update_bot_mode(new_mode = BOT_IDLE)

	var/atom/movable/cached_load = load //cache the load since unbuckling mobs clears the var.

	unbuckle_all_mobs()

	if(load) //don't have to do any of this for mobs.
		cached_load.forceMove(loc)
		cached_load.pixel_y = initial(cached_load.pixel_y)
		cached_load.layer = initial(cached_load.layer)
		SET_PLANE_EXPLICIT(cached_load, initial(cached_load.plane), src)
		load = null

	if(dirn) //move the thing to the delivery point.
		cached_load.Move(get_step(loc,dirn), dirn)

	update_appearance()
