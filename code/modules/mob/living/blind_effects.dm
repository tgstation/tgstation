/// Is `observed_atom` in a mob's view? This takes blindness and nearsightness into consideration
/mob/living/proc/in_sight(atom/observed_atom, ignore_self = FALSE)
	if(ignore_self && observed_atom == src)
		return TRUE
	if(is_blind())
		return FALSE
	. = FALSE
	var/turf/my_turf = get_turf(src) //Because being inside contents of something will cause our x,y to not be updated
	if(!my_turf)
		return FALSE

	var/rel_x = observed_atom.x - my_turf.x
	var/rel_y = observed_atom.y - my_turf.y

	// Handling nearsightnedness
	if(is_nearsighted())
		if(abs(rel_x) >= NEARSIGHTNESS_BLINDNESS || abs(rel_y) >= NEARSIGHTNESS_BLINDNESS)
			return FALSE
	return TRUE

//did you know you can subtype /image and /mutable_appearance? // Stop telling them that they might actually do it
/image/blind_image
	icon = 'icons/effects/blind_effects.dmi'
	layer = FOV_EFFECTS_LAYER
	appearance_flags = RESET_COLOR | RESET_TRANSFORM
	plane = HIGH_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// Plays a visual effect representing a sound cue for people with vision obstructed by blindness
/proc/play_blind_effect(atom/center, range, icon_state, dir = SOUTH, ignore_self = FALSE, angle = 0, list/override_list)
	var/turf/anchor_point = get_turf(center)
	var/image/blind_image/blind_image
	var/list/clients_shown

	for(var/mob/living/living_mob in override_list || get_hearers_in_view(range, center))
		var/client/mob_client = living_mob.client
		if(!mob_client)
			continue
		if(HAS_TRAIT(living_mob, TRAIT_DEAF)) //Deaf people can't hear sounds so no sound indicators
			continue
		if(living_mob.in_sight(center, ignore_self))
			continue
		if(!blind_image) //Make the image once we found one recipient to receive it
			blind_image = new()
			blind_image.loc = anchor_point
			SET_PLANE(blind_image, FULLSCREEN_PLANE, anchor_point)
			blind_image.icon_state = icon_state
			blind_image.dir = dir
			if(angle)
				var/matrix/matrix = new
				matrix.Turn(angle)
				blind_image.transform = matrix
		LAZYADD(clients_shown, mob_client)

		mob_client.images += blind_image

	if(clients_shown)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_images_from_clients, blind_image, clients_shown), 3 SECONDS)

