/mob/living/silicon/pai/ClickOn(atom/target, params)
	..()
	if(!camera?.in_camera_mode)
		return FALSE
	//pAI picture taking
	camera.toggle_camera_mode(sound = FALSE)
	camera.captureimage(target, usr, camera.picture_size_x - 1, camera.picture_size_y - 1)
	return TRUE

/obj/item/camera/siliconcam/pai_camera
	name = "pAI photo camera"
	light_color = COLOR_PAI_GREEN

/obj/item/camera/siliconcam/pai_camera/after_picture(mob/user, datum/picture/picture)
	var/number = length(stored)
	picture.picture_name = "Image [number] (taken by [loc.name])"
	stored[picture] = TRUE
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)
	balloon_alert(user, "image recorded")

/**
 * Handles selecting and printing stored images.
 *
 * @param {mob} user - The pAI.
 *
 * @returns {boolean} - TRUE if the pAI prints an image,
 * 	FALSE otherwise.
*/
/obj/item/camera/siliconcam/pai_camera/proc/pai_print(mob/user)
	var/mob/living/silicon/pai/pai = loc
	var/datum/picture/selection = selectpicture(user)
	if(!istype(selection))
		balloon_alert(user, "invalid image")
		return FALSE
	printpicture(user, selection)
	user.visible_message(span_notice("A picture appears on top of the chassis of [pai.name]!"), span_notice("You print a photograph."))
	return TRUE

/**
 * All inclusive camera proc. Zooms, snaps, prints.
 *
 * @param {mob} user - The pAI requesting the camera.
 *
 * @param {string} mode - The camera option to toggle.
 *
 * @returns {boolean} - TRUE if the camera worked.
 */
/mob/living/silicon/pai/proc/use_camera(mob/user, mode)
	if(!camera || isnull(mode))
		return FALSE
	switch(mode)
		if(PAI_PHOTO_MODE_CAMERA)
			camera.toggle_camera_mode(user)
		if(PAI_PHOTO_MODE_PRINTER)
			camera.pai_print(user)
		if(PAI_PHOTO_MODE_ZOOM)
			camera.adjust_zoom(user)
	return TRUE
