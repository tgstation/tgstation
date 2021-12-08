/// Datumized FOV handler for a mob's client. Handles the visual part of the FOV mechanics.
/datum/field_of_view
	/// Reference to the mob owning this
	var/mob/living/owner
	/// Currently applied x size of the fov masks
	var/current_fov_x = BASE_FOV_MASK_X_DIMENSION
	/// Currently applied y size of the fov masks
	var/current_fov_y = BASE_FOV_MASK_Y_DIMENSION
	/// Whether we are applying the masks now
	var/applied_mask = FALSE
	/// The angle of the mask we are applying
	var/fov_angle = FOV_180_DEGREES
	/// The blocker mask applied to a client's screen
	var/atom/movable/screen/fov_blocker/blocker_mask
	/// The shadow mask applied to a client's screen
	var/atom/movable/screen/fov_shadow/visual_shadow
	/// Whether our user is alive
	var/user_living = TRUE
	/// Whether our user extends his eye view
	var/user_extends_eye = FALSE

/datum/field_of_view/New(mob/living/our_owner, fov_type = FOV_180_DEGREES)
	owner = our_owner
	owner.fov_handler = src
	var/client/parent_client = owner.client
	if(!parent_client) //Love client volatility!!
		qdel(src)
		return

	fov_angle = fov_type
	blocker_mask = new
	visual_shadow = new
	dir_change(owner.dir)
	visual_shadow.alpha = parent_client.prefs.read_preference(/datum/preference/numeric/fov_darkness)
	set_fov_angle(fov_type)
	update_fov_size()
	update_living()
	update_eye()

/datum/field_of_view/Destroy()
	owner.fov_handler = null
	if(applied_mask)
		remove_mask()
	if(blocker_mask) // In a case of early deletion due to volatile client
		QDEL_NULL(blocker_mask)
	if(visual_shadow) // In a case of early deletion due to volatile client
		QDEL_NULL(visual_shadow)
	return ..()

/// Updates the state of the owner living and updates masking
/datum/field_of_view/proc/update_living()
	if(owner.stat == DEAD)
		user_living = FALSE
	else
		user_living = TRUE
	update_masking()

/// Updates the state of the owner eye and updates masking
/datum/field_of_view/proc/update_eye()
	var/client/parent_client = owner.client
	if(parent_client.eye == owner)
		user_extends_eye = FALSE
	else
		user_extends_eye = TRUE
	update_masking()

/// Properly applies or removes the mask, on conditions of living and not extending an eye
/datum/field_of_view/proc/update_masking()
	var/should_apply_mask = FALSE
	if(user_living && !user_extends_eye)
		should_apply_mask = TRUE
	if(should_apply_mask == applied_mask)
		return
	if(should_apply_mask)
		add_mask()
	else
		remove_mask()

/// Updates the size of the FOV masks by comparing them to client view size.
/datum/field_of_view/proc/update_fov_size()
	var/client/parent_client = owner.client
	if(!parent_client) //Love client volatility!!
		return
	var/list/view_size = getviewsize(parent_client.view)
	if(view_size[1] == current_fov_x && view_size[2] == current_fov_y)
		return
	current_fov_x = BASE_FOV_MASK_X_DIMENSION
	current_fov_y = BASE_FOV_MASK_Y_DIMENSION
	var/matrix/new_matrix = new
	var/x_shift = view_size[1] - current_fov_x
	var/y_shift = view_size[2] - current_fov_y
	var/x_scale = view_size[1] / current_fov_x
	var/y_scale = view_size[2] / current_fov_y
	current_fov_x = view_size[1]
	current_fov_y = view_size[2]
	visual_shadow.transform = blocker_mask.transform = new_matrix.Scale(x_scale, y_scale)
	visual_shadow.transform = blocker_mask.transform = new_matrix.Translate(x_shift * 16, y_shift * 16)

/// Adds the masks to the user
/datum/field_of_view/proc/add_mask()
	var/client/parent_client = owner.client
	if(!parent_client) //Love client volatility!!
		return
	parent_client.screen += blocker_mask
	parent_client.screen += visual_shadow
	applied_mask = TRUE

/// Removes the masks from the user
/datum/field_of_view/proc/remove_mask()
	var/client/parent_client = owner.client
	if(!parent_client) //Love client volatility!!
		return
	parent_client.screen -= blocker_mask
	parent_client.screen -= visual_shadow
	applied_mask = FALSE

/// When a direction of the user changes, so do the masks
/datum/field_of_view/proc/dir_change(new_dir)
	blocker_mask.dir = new_dir
	visual_shadow.dir = new_dir

/datum/field_of_view/proc/set_fov_angle(new_angle)
	fov_angle = new_angle
	blocker_mask.icon_state = "[fov_angle]"
	visual_shadow.icon_state = "[fov_angle]_v"

/// Is `observed_atom` in a mob's field of view? This takes blindness, nearsightness and FOV into consideration
/mob/living/proc/in_fov(atom/observed_atom, ignore_self = FALSE)
	if(ignore_self && observed_atom == src)
		return TRUE
	if(is_blind())
		return FALSE
	. = FALSE
	var/turf/my_turf = get_turf(src) //Because being inside contents of something will cause our x,y to not be updated
	// If turf doesn't exist, then we wouldn't get a fov check called by `play_fov_effect` or presumably other new stuff that might check this.
	//  ^ If that case has changed and you need that check, add it.
	var/rel_x = observed_atom.x - my_turf.x
	var/rel_y = observed_atom.y - my_turf.y
	if(fov_view)
		if(rel_x >= -1 && rel_x <= 1 && rel_y >= -1 && rel_y <= 1) //Cheap way to check inside that 3x3 box around you
			return TRUE //Also checks if both are 0 to stop division by zero
	
		// Get the vector length so we can create a good directional vector
		var/vector_len = sqrt(abs(rel_x) ** 2 + abs(rel_y) ** 2)
	
		/// Getting a direction vector
		var/dir_x
		var/dir_y
		switch(dir)
			if(SOUTH)
				dir_x = 0
				dir_y = -vector_len
			if(NORTH)
				dir_x = 0
				dir_y = vector_len
			if(EAST)
				dir_x = vector_len
				dir_y = 0
			if(WEST)
				dir_x = -vector_len
				dir_y = 0
	
		///Calculate angle
		var/angle = arccos((dir_x * rel_x + dir_y * rel_y) / (sqrt(dir_x**2 + dir_y**2) * sqrt(rel_x**2 + rel_y**2)))
	
		/// Calculate vision angle and compare
		var/vision_angle = (360 - fov_view) / 2
		if(angle < vision_angle)
			. = TRUE
	else
		. = TRUE

	// Handling nearsightnedness
	if(. && HAS_TRAIT(src, TRAIT_NEARSIGHT))
		//Checking if our dude really is suffering from nearsightness! (very nice nearsightness code)
		if(iscarbon(src))
			var/mob/living/carbon/carbon_me = src
			if(carbon_me.glasses)
				var/obj/item/clothing/glasses/glass = carbon_me.glasses
				if(glass.vision_correction)
					return
		if((rel_x >= NEARSIGHTNESS_FOV_BLINDNESS || rel_x <= -NEARSIGHTNESS_FOV_BLINDNESS) || (rel_y >= NEARSIGHTNESS_FOV_BLINDNESS || rel_y <= -NEARSIGHTNESS_FOV_BLINDNESS))
			return FALSE

/// Updates the applied FOV value and applies the handler to client if able
/mob/living/proc/update_fov()
	var/highest_fov
	if(CONFIG_GET(flag/native_fov))
		highest_fov = native_fov
	for(var/trait_type in fov_traits)
		var/fov_type = fov_traits[trait_type]
		if(fov_type > highest_fov)
			highest_fov = fov_type
	fov_view = highest_fov
	update_fov_client()

/// Updates the FOV for the client.
/mob/living/proc/update_fov_client()
	if(!client)
		return
	if(fov_view)
		if(!fov_handler)
			fov_handler = new(src, fov_view)
		else
			fov_handler.set_fov_angle(fov_view)
	else if(fov_handler)
		qdel(fov_handler)

/// Adds a trait which limits a user's FOV
/mob/living/proc/add_fov_trait(source, type)
	LAZYINITLIST(fov_traits)
	fov_traits[source] = type
	update_fov()

/// Removes a trait which limits a user's FOV
/mob/living/proc/remove_fov_trait(source, type)
	if(!fov_traits) //Clothing equip/unequip is bad code and invokes this several times
		return
	fov_traits -= source
	UNSETEMPTY(fov_traits)
	update_fov()

/// Plays a visual effect representing a sound cue for people with vision obstructed by FOV or blindness
/proc/play_fov_effect(atom/center, range, icon_state, dir = SOUTH, ignore_self = FALSE, angle = 0)
	var/turf/anchor_point = get_turf(center)
	var/image/fov_image
	for(var/mob/living/living_mob in get_hearers_in_view(range, center))
		var/client/mob_client = living_mob.client
		if(!mob_client?.prefs?.read_preference(/datum/preference/toggle/play_fov_effects))
			continue
		if(HAS_TRAIT(living_mob, TRAIT_DEAF)) //Deaf people can't hear sounds so no sound indicators
			continue
		if(living_mob.in_fov(center, ignore_self))
			continue
		if(!fov_image) //Make the image once we found one recipient to receive it
			fov_image = image(icon = 'icons/effects/fov/fov_effects.dmi', icon_state = icon_state, loc = anchor_point)
			fov_image.plane = FULLSCREEN_PLANE
			fov_image.layer = FOV_EFFECTS_LAYER
			fov_image.dir = dir
			fov_image.appearance_flags = RESET_COLOR | RESET_TRANSFORM
			if(angle)
				var/matrix/matrix = new
				matrix.Turn(angle)
				fov_image.transform = matrix
			fov_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		mob_client.images += fov_image
		addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_image_from_client, fov_image, mob_client), 30)

/atom/movable/screen/fov_blocker
	icon = 'icons/effects/fov/field_of_view.dmi'
	icon_state = "90"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	screen_loc = "BOTTOM,LEFT"

/atom/movable/screen/fov_shadow
	icon = 'icons/effects/fov/field_of_view.dmi'
	icon_state = "90_v"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_LIGHTING_PLANE
	screen_loc = "BOTTOM,LEFT"
