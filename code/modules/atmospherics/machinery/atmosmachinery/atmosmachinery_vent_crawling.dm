#define VENT_SOUND_DELAY 3 SECONDS

/obj/machinery/atmospherics/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /mob/living))
		var/mob/living/L = arrived
		L.ventcrawl_layer = piping_layer
	return ..()

// Handles mob movement inside a pipenet
/obj/machinery/atmospherics/relaymove(mob/living/user, direction)

	if(!direction || !(direction in GLOB.cardinals_multiz)) //cant go this way.
		return
	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return
	var/obj/machinery/atmospherics/target_move = findConnecting(direction, user.ventcrawl_layer)

	if(!target_move)
		return
	if(target_move.vent_movement & VENTCRAWL_ALLOWED)
		user.forceMove(target_move)
		user.client.eye = target_move  //Byond only updates the eye every tick, This smooths out the movement
		var/list/pipenetdiff = returnPipenets() ^ target_move.returnPipenets()
		if(pipenetdiff.len)
			user.update_pipe_vision()
		if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
			user.last_played_vent = world.time
			playsound(src, 'sound/machines/ventcrawl.ogg', 50, TRUE, -3)

	//Would be great if this could be implemented when someone alt-clicks the image.
	if (target_move.vent_movement & VENTCRAWL_ENTRANCE_ALLOWED)
		user.handle_ventcrawl(target_move)
		//PLACEHOLDER COMMENT FOR ME TO READD THE 1 (?) DS DELAY THAT WAS IMPLEMENTED WITH A... TIMER?

/**
 * Getter of a list of pipenets
 *
 * called in relaymove() to create the image for vent crawling
 */
/obj/machinery/atmospherics/proc/returnPipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)

/**
 * Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
 */
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE

#undef VENT_SOUND_DELAY
