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
		assign_cell()
		cell = null
		set_cell_hud()

/mob/living/basic/bot/mulebot/Entered(obj/item/stock_parts/power_store/cell/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived) && isnull(cell))
		assign_cell(arrived)

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

	var/prev_loc = atom_to_load.loc
	if(!isturf(prev_loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
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
		playsound(src, SFX_HEAVY_DROP, 60, TRUE)

	else if(isliving(atom_to_load))
		if(!load_mob(atom_to_load)) //forceMove() is handled in buckling
			return

	load = atom_to_load
	var/stored_alpha = load.alpha
	do_loading_animation(load, prev_loc)
	load.alpha = stored_alpha // Restoring previous alpha following the animation's completion.
	load.transform = load.transform.Scale(10/7)
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

/**
 * called to unload the bot
 * argument is optional direction to unload
 * if zero or null, unload at bot's location
 */
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
	playsound(src, SFX_HEAVY_DROP, 50, TRUE)
	update_appearance()

/mob/living/basic/bot/mulebot/proc/do_loading_animation(atom/movable/animated_load, turf/old_loc)
	if(!animated_load || !old_loc)
		return
	animate(src, time = 0.1 SECONDS, pixel_y = -2)

	var/image/pickup_animation = image(icon = animated_load)
	SET_PLANE(pickup_animation, GAME_PLANE, old_loc)
	pickup_animation.transform.Scale(0.75)
	pickup_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	var/direction = get_dir(old_loc, src)
	var/to_x = base_pixel_x + base_pixel_w
	var/to_y = base_pixel_y + base_pixel_z

	if(direction & NORTH)
		to_y += 32
	else if(direction & SOUTH)
		to_y -= 32
	if(direction & EAST)
		to_x += 32
	else if(direction & WEST)
		to_x -= 32
	if(!direction)
		to_y += 10
		pickup_animation.pixel_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	var/atom/movable/flick_visual/pickup = old_loc.flick_overlay_view(pickup_animation, 0.4 SECONDS)
	var/matrix/animation_matrix = new(pickup.transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(1.1)

	animate(pickup, alpha = 175, pixel_x = to_x, pixel_y = to_y, time = 0.3 SECONDS, transform = animation_matrix, easing = CUBIC_EASING)
	animate(animated_load, alpha = 0, transform = matrix().Scale(0.7), time = 0.1 SECONDS)
	animate(src, time = 0.1 SECONDS, pixel_y = 0, delay = 0.1 SECONDS, easing = QUAD_EASING)
