
/obj/item/camera/siliconcam
	name = "silicon photo camera"
	var/in_camera_mode = FALSE
	var/list/datum/picture/stored = list()

/obj/item/camera/siliconcam/ai_camera
	name = "AI photo camera"
	flash_enabled = FALSE

/obj/item/camera/siliconcam/proc/toggle_camera_mode(mob/user, sound = TRUE)
	in_camera_mode = !in_camera_mode
	if(sound)
		playsound(src, 'sound/items/wirecutter.ogg', 50, TRUE)
	to_chat(user, span_notice("Camera mode: [in_camera_mode ? "Activated" : "Deactivated"]."))

/obj/item/camera/siliconcam/proc/selectpicture(mob/user)
	RETURN_TYPE(/datum/picture)
	if(!length(stored))
		to_chat(user, span_notice("ERROR: No stored photos located."))
		return
	var/list/nametemp = list()
	var/list/temp = list()
	for(var/datum/picture/stored_photo as anything in stored)
		nametemp += stored_photo.picture_name
		temp[stored_photo.picture_name] = stored_photo
	var/find = tgui_input_list(user, "Select image", "Storage", nametemp)
	if(isnull(find))
		return
	if(isnull(temp[find]))
		return
	return temp[find]

/obj/item/camera/siliconcam/proc/viewpictures(mob/user)
	var/datum/picture/selection = selectpicture(user)
	if(istype(selection))
		show_picture(user, selection)

/obj/item/camera/siliconcam/ai_camera/after_picture(mob/user, datum/picture/picture)
	var/number = length(stored)
	picture.picture_name = "Image [number] (taken by [loc.name])"
	stored[picture] = TRUE
	to_chat(user, span_notice("Image recorded."))

/obj/item/camera/siliconcam/robot_camera
	name = "Cyborg photo camera"
	var/printcost = 2

/obj/item/camera/siliconcam/robot_camera/after_picture(mob/user, datum/picture/picture)
	var/mob/living/silicon/robot/C = loc
	if(istype(C) && istype(C.connected_ai))
		var/number = C.connected_ai.aicamera.stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		C.connected_ai.aicamera.stored[picture] = TRUE
		to_chat(usr, span_notice("Image recorded and saved to remote database."))
	else
		var/number = stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		stored[picture] = TRUE
		to_chat(usr, span_notice("Image recorded and saved to local storage. Upload will happen automatically if unit is lawsynced."))

/obj/item/camera/siliconcam/robot_camera/selectpicture(mob/user)
	var/mob/living/silicon/robot/R = loc
	if(istype(R) && R.connected_ai)
		R.picturesync()
		return R.connected_ai.aicamera.selectpicture(user)
	else
		return ..()

/obj/item/camera/siliconcam/robot_camera/proc/borgprint(mob/user)
	var/mob/living/silicon/robot/C = loc
	if(!istype(C) || C.toner < 20)
		to_chat(user, span_warning("Insufficent toner to print image."))
		return
	var/datum/picture/selection = selectpicture(user)
	if(!istype(selection))
		to_chat(user, span_warning("Invalid Image."))
		return
	var/obj/item/photo/p = new /obj/item/photo(C.loc, selection)
	p.pixel_x = p.base_pixel_x + rand(-10, 10)
	p.pixel_y = p.base_pixel_y + rand(-10, 10)
	C.toner -= printcost  //All fun allowed.
	user.visible_message(span_notice("[C.name] spits out a photograph from a narrow slot on its chassis."), span_notice("You print a photograph."))
