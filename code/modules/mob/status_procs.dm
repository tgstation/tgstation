//Here are the procs used to modify status effects of a mob.

/**
* Set drowsyness of a mob to passed value
*/
/mob/proc/set_drowsyness(amount)
	drowsyness = max(amount, 0)

/**
 * Adds passed value to the drowsyness of a mob
 */
/mob/proc/adjust_drowsyness(amount)
	drowsyness = max(drowsyness + amount, 0)

/**
 * Adjust a mobs blindness by an amount
 *
 * Will apply the blind alerts if needed
 */
/mob/proc/adjust_blindness(amount)
	var/old_eye_blind = eye_blind
	eye_blind = max(0, eye_blind + amount)
	if(!old_eye_blind || !eye_blind && !HAS_TRAIT(src, TRAIT_BLIND))
		update_blindness()
/**
 * Force set the blindness of a mob to some level
 */
/mob/proc/set_blindness(amount)
	var/old_eye_blind = eye_blind
	eye_blind = max(amount, 0)
	if(!old_eye_blind || !eye_blind && !HAS_TRAIT(src, TRAIT_BLIND))
		update_blindness()


/// proc that adds and removes blindness overlays when necessary
/mob/proc/update_blindness()
	switch(stat)
		if(CONSCIOUS, SOFT_CRIT)
			if(HAS_TRAIT(src, TRAIT_BLIND) || eye_blind)
				throw_alert(ALERT_BLIND, /atom/movable/screen/alert/blind)
				do_set_blindness(TRUE)
			else
				do_set_blindness(FALSE)
		if(UNCONSCIOUS, HARD_CRIT)
			do_set_blindness(TRUE)
		if(DEAD)
			do_set_blindness(FALSE)


///Proc that handles adding and removing the blindness overlays.
/mob/proc/do_set_blindness(now_blind)
	if(now_blind)
		overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
		// You are blind why should you be able to make out details like color, only shapes near you
		add_client_colour(/datum/client_colour/monochrome/blind)
	else
		clear_alert(ALERT_BLIND)
		clear_fullscreen("blind")
		remove_client_colour(/datum/client_colour/monochrome/blind)


/**
 * Make the mobs vision blurry
 */
/mob/proc/blur_eyes(amount)
	if(amount>0)
		eye_blurry = max(amount, eye_blurry)
	update_eye_blur()

/**
 * Adjust the current blurriness of the mobs vision by amount
 */
/mob/proc/adjust_blurriness(amount)
	eye_blurry = max(eye_blurry+amount, 0)
	update_eye_blur()

///Set the mobs blurriness of vision to an amount
/mob/proc/set_blurriness(amount)
	eye_blurry = max(amount, 0)
	update_eye_blur()

///Apply the blurry overlays to a mobs clients screen
/mob/proc/update_eye_blur()
	if(!hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	if(eye_blurry)
		game_plane_master_controller.add_filter("eye_blur", 1, gauss_blur_filter(clamp(eye_blurry * 0.1, 0.6, 3)))
	else
		game_plane_master_controller.remove_filter("eye_blur")

///Adjust the disgust level of a mob
/mob/proc/adjust_disgust(amount)
	return

///Set the disgust level of a mob
/mob/proc/set_disgust(amount)
	return

///Adjust the body temperature of a mob, with min/max settings
/mob/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount,min_temp,max_temp)

/// Sight here is the mob.sight var, which tells byond what to actually show to our client
/// See [code\__DEFINES\sight.dm] for more details
/mob/proc/set_sight(new_value)
	SHOULD_CALL_PARENT(TRUE)
	// Can't turn this off, because we need it to make a plane master we need exist
	// Sorry brother
	new_value |= SEE_BLACKNESS
	if(sight == new_value)
		return
	var/old_sight = sight
	sight = new_value

	SEND_SIGNAL(src, COMSIG_MOB_SIGHT_CHANGE, new_value, old_sight)

/mob/proc/add_sight(new_value)
	set_sight(sight | new_value)

/mob/proc/clear_sight(new_value)
	set_sight(sight & ~new_value)

/// see invisibility is the mob's capability to see things that ought to be hidden from it
/// Can think of it as a primitive version of changing the alpha of planes
/// We mostly use it to hide ghosts, no real reason why
/mob/proc/set_invis_see(new_sight)
	SHOULD_CALL_PARENT(TRUE)
	if(new_sight == see_invisible)
		return
	var/old_invis = see_invisible
	see_invisible = new_sight
	SEND_SIGNAL(src, COMSIG_MOB_SEE_INVIS_CHANGE, see_invisible, old_invis)

/// see_in_dark is essentially just a range value
/// Basically, if a tile has 0 luminosity affecting it, it will be counted as "dark"
/// Then, if said tile is farther then see_in_dark from your mob, it will, rather then being rendered
/// As a normal tile with contents, instead be covered by "darkness", the same sort exposed by SEE_BLACKNESS
/// You can see this effect by going somewhere dark, and cranking the alpha on the lighting plane to 0
/mob/proc/set_see_in_dark(new_dark)
	SHOULD_CALL_PARENT(TRUE)
	if(new_dark == see_in_dark)
		return
	var/old_dark = see_in_dark
	see_in_dark = new_dark
	SEND_SIGNAL(src, COMSIG_MOB_SEE_IN_DARK_CHANGE, see_in_dark, old_dark)

