
/obj/item/camera/siliconcam
	name = "silicon photo camera"
	resistance_flags = INDESTRUCTIBLE
	/// List of all pictures taken by this camera.
	var/list/datum/picture/stored = list()

/// Checks if we can take a picture at this moment. Returns TRUE if we can, FALSE if we can't.
/obj/item/camera/siliconcam/proc/can_take_picture(mob/living/silicon/clicker)
	if(clicker.stat != CONSCIOUS || clicker.incapacitated())
		return FALSE
	return TRUE

/obj/item/camera/siliconcam/proc/InterceptClickOn(mob/living/silicon/clicker, params, atom/clicked_on)
	if(!can_take_picture(clicker))
		return
	clicker.face_atom(clicked_on)
	captureimage(clicked_on, clicker)
	toggle_camera_mode(clicker, sound = FALSE)

/// Toggles the camera mode on or off.
/// If sound is TRUE, plays a sound effect and displays a message on successful toggle
/obj/item/camera/siliconcam/proc/toggle_camera_mode(mob/user, sound = TRUE)
	if(user.click_intercept == src)
		user.click_intercept = null

	else if(isnull(user.click_intercept))
		user.click_intercept = src

	else
		// Trying to turn on camera mode while you have another click intercept active, such as malf abilities
		if(sound)
			balloon_alert(user, "can't enable camera mode!")
			playsound(user, 'sound/machines/buzz-sigh.ogg', 25, TRUE)
		return

	if(sound)
		playsound(user, 'sound/items/wirecutter.ogg', 50, TRUE)
		balloon_alert(user, "camera mode [user.click_intercept == src ? "activated" : "deactivated"]")

/obj/item/camera/siliconcam/proc/selectpicture(mob/user)
	RETURN_TYPE(/datum/picture)
	if(!length(stored))
		user.balloon_alert(user, "no stored photos!")
		return
	var/list/nametemp = list()
	var/list/temp = list()
	for(var/datum/picture/stored_photo as anything in stored)
		nametemp += stored_photo.picture_name
		temp[stored_photo.picture_name] = stored_photo
	var/find = tgui_input_list(user, "Select image", "Storage", nametemp)
	if(isnull(find) || isnull(temp[find]))
		return
	return temp[find]

/obj/item/camera/siliconcam/proc/viewpictures(mob/user)
	var/datum/picture/selection = selectpicture(user)
	if(istype(selection))
		show_picture(user, selection)

/obj/item/camera/siliconcam/ai_camera
	name = "AI photo camera"
	flash_enabled = FALSE

/obj/item/camera/siliconcam/ai_camera/can_take_picture(mob/living/silicon/ai/clicker)
	if(clicker.control_disabled)
		return FALSE
	return ..()

/obj/item/camera/siliconcam/ai_camera/balloon_alert(mob/viewer, text)
	if(isAI(loc))
		// redirects balloon alerts on us to balloon alerts on our ai eye
		var/mob/living/silicon/ai/ai = loc
		return ai.eyeobj.balloon_alert(viewer, text)

	return ..()

/obj/item/camera/siliconcam/ai_camera/after_picture(mob/user, datum/picture/picture)
	var/number = length(stored)
	picture.picture_name = "Image [number] (taken by [loc.name])"
	stored[picture] = TRUE
	balloon_alert(user, "image recorded")
	user.playsound_local(get_turf(user), pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, TRUE, -3)

/obj/item/camera/siliconcam/robot_camera
	name = "Cyborg photo camera"
	var/printcost = 2

/obj/item/camera/siliconcam/robot_camera/can_take_picture(mob/living/silicon/robot/clicker)
	if(clicker.lockcharge)
		return FALSE
	return ..()

/obj/item/camera/siliconcam/robot_camera/after_picture(mob/living/silicon/robot/user, datum/picture/picture)
	if(istype(user) && istype(user.connected_ai))
		var/number = user.connected_ai.aicamera.stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		user.connected_ai.aicamera.stored[picture] = TRUE
		balloon_alert(user, "image recorded and uploaded")
	else
		var/number = stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		stored[picture] = TRUE
		balloon_alert(user, "image recorded and saved locally")
	playsound(src, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)

/obj/item/camera/siliconcam/robot_camera/selectpicture(mob/living/silicon/robot/user)
	if(istype(user) && user.connected_ai)
		user.picturesync()
		return user.connected_ai.aicamera.selectpicture(user)
	return ..()

/obj/item/camera/siliconcam/robot_camera/proc/borgprint(mob/living/silicon/robot/user)
	if(!istype(user) || user.toner < printcost)
		balloon_alert(user, "not enough toner!")
		return
	var/datum/picture/selection = selectpicture(user)
	if(!istype(selection))
		balloon_alert(user, "invalid image!")
		return
	var/obj/item/photo/printed = new(user.drop_location(), selection)
	printed.pixel_x = printed.base_pixel_x + rand(-10, 10)
	printed.pixel_y = printed.base_pixel_y + rand(-10, 10)
	user.toner -= printcost  //All fun allowed.
	user.visible_message(span_notice("[user.name] spits out a photograph from a narrow slot on its chassis."), span_notice("You print a photograph."))
	balloon_alert(user, "photograph printed")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 50, TRUE, -3)
