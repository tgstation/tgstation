/datum/computer_file/program/maintenance/camera
	filename = "camera_app"
	filedesc = "Camera"
	program_open_overlay = "camera"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	extended_desc = "This program allows the taking of pictures."
	size = 4
	can_run_on_flags = PROGRAM_PDA
	tgui_id = "NtosCamera"
	program_icon = "camera"
	circuit_comp_type = /obj/item/circuit_component/mod_program/camera

	/// Camera built-into the tablet.
	var/obj/item/camera/app/internal_camera
	/// Latest picture taken by the app.
	var/datum/picture/internal_picture
	/// A mutable_appearance of the latest picture, for getting an appeance reference for the UI.
	var/mutable_appearance/picture_appearance
	/// How many pictures were taken already, used for the camera's TGUI photo display
	var/picture_number = 1
	/// Can we edit the metadata of the latest picture?
	var/can_edit_metadata = TRUE
	/// The name we will give to the picture when we first save it
	var/current_picture_name
	/// The description we will give to the picture when we first save it
	var/current_picture_desc
	/// The caption we will give to the picture when we first save it
	var/current_picture_caption

/// Special type of camera for this exact usecase to prevent harddels
/obj/item/camera/app
	name = "internal camera"
	desc = "Specialized internal camera protected from the hellish depths of SSWardrobe. \
	Yell at coders if you somehow manage to see this"
	print_picture_on_snap = FALSE
	cooldown = 1 SECONDS
	light_system = NONE

/// Special type of component so it does not intefer with the modular computer default lighting system if any
/datum/component/overlay_lighting/camera
	dupe_mode = COMPONENT_DUPE_SOURCES

/obj/item/camera/app/Initialize(mapload)
	. = ..()
	var/obj/item/modular_computer/target = loc
	target.AddComponentFrom(REF(src), /datum/component/overlay_lighting/camera, 3, FLASH_LIGHT_POWER, COLOR_WHITE, FALSE, TRUE)

/obj/item/camera/app/Destroy(force)
	var/obj/item/modular_computer/target = loc
	target.RemoveComponentSource(REF(src), /datum/component/overlay_lighting/camera)
	return ..()

/obj/item/camera/app/set_light_on(new_value)
	var/obj/item/modular_computer/target = loc
	target.set_light_on(new_value)

/datum/computer_file/program/maintenance/camera/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing, mob/user)
	. = ..()
	internal_camera = new(computer)
	internal_camera.print_picture_on_snap = FALSE
	picture_appearance = new()
	RegisterSignal(internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/datum/computer_file/program/maintenance/camera/Destroy()
	QDEL_NULL(internal_camera)
	internal_picture = null
	QDEL_NULL(picture_appearance)
	return ..()

/datum/computer_file/program/maintenance/camera/tap(atom/tapped_atom, mob/living/user, list/modifiers)
	. = ..()
	take_picture(user, get_turf(tapped_atom))

/datum/computer_file/program/maintenance/camera/on_made_active_program(user)
	RegisterSignal(computer, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(on_computer_ranged_interact))

/datum/computer_file/program/maintenance/camera/kill_program(mob/user)
	. = ..()
	UnregisterSignal(computer, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY)
	internal_picture = null

/datum/computer_file/program/maintenance/camera/background_program(mob/user)
	. = ..()
	UnregisterSignal(computer, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY)

/datum/computer_file/program/maintenance/camera/proc/on_computer_ranged_interact(_source, mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	take_picture(user, get_turf(target))

/datum/computer_file/program/maintenance/camera/proc/take_picture(mob/user, turf/target)
	QDEL_NULL(internal_picture)
	internal_camera.see_ghosts = (locate(/datum/computer_file/program/maintenance/spectre_meter) in computer.stored_files) ?  CAMERA_SEE_GHOSTS_BASIC : CAMERA_NO_GHOSTS
	internal_camera.attempt_picture(target, user)

/datum/computer_file/program/maintenance/camera/proc/on_image_captured(cam, target, user, datum/picture/picture)
	SIGNAL_HANDLER

	internal_picture = picture
	picture_appearance.icon = internal_picture.picture_image
	current_picture_name = null
	current_picture_desc = null
	current_picture_caption = null
	can_edit_metadata = TRUE
	picture_number++

/datum/computer_file/program/maintenance/camera/proc/commit_metadata()
	if(can_edit_metadata)
		internal_picture.picture_name = current_picture_name
		internal_picture.picture_desc = "[current_picture_desc] - [internal_picture.picture_desc]"
		internal_picture.caption = current_picture_caption
		can_edit_metadata = FALSE

/datum/computer_file/program/maintenance/camera/ui_static_data(mob/user)
	return list(
		"maxNameLength" = 32,
		"maxDescLength" = 128,
		"maxCaptionLength" = 256,
		"printCost" = 1,
		"minSize" = 1,
		"maxSize" = CAMERA_PICTURE_SIZE_HARD_LIMIT
	)

/datum/computer_file/program/maintenance/camera/ui_data(mob/user)
	var/list/data = list()

	if(!isnull(internal_picture))
		data["photo"] = REF(picture_appearance.appearance)
		data["canEditMetadata"] = can_edit_metadata
		data["name"] = current_picture_name
		data["desc"] = current_picture_desc
		data["caption"] = current_picture_caption
		data["storedPaper"] = computer.stored_paper
	data["size"] = max(internal_camera.picture_size_x, internal_camera.picture_size_y)

	return data

/datum/computer_file/program/maintenance/camera/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("adjustSize")
			var/new_size = text2num(params["value"])
			if(!new_size)
				return
			new_size = clamp(new_size, 1, CAMERA_PICTURE_SIZE_HARD_LIMIT)
			internal_camera.picture_size_x = new_size
			internal_camera.picture_size_y = new_size
			return TRUE

		if("setName")
			if(!(internal_picture && can_edit_metadata))
				return FALSE
			current_picture_name = trim(params["value"], PREVENT_CHARACTER_TRIM_LOSS(32))
			return TRUE

		if("setDesc")
			if(!(internal_picture && can_edit_metadata))
				return
			current_picture_desc = trim(params["value"], PREVENT_CHARACTER_TRIM_LOSS(128))
			return TRUE

		if("setCaption")
			if(!(internal_picture && can_edit_metadata))
				return
			current_picture_caption = trim(params["value"], PREVENT_CHARACTER_TRIM_LOSS(256))
			return TRUE

		if("savePhoto")
			if(!internal_picture)
				return
			var/datum/computer_file/image/photo_file = new(
				internal_picture.picture_image,
				display_name = internal_picture.picture_name || "photo[picture_number]",
				source_photo_or_painting = internal_picture
			)
			if(computer.store_file(photo_file, ui.user))
				return FALSE
			commit_metadata()
			return TRUE
		if("printPhoto")
			if(!internal_picture)
				return FALSE
			if(computer.stored_paper < PHOTO_PAPER_COST)
				return FALSE
			commit_metadata()
			var/obj/item/photo/new_photo = new(computer.physical.drop_location())
			new_photo.set_picture(internal_picture, TRUE, TRUE)
			ui.user.put_in_hands(new_photo)
			playsound(computer.physical, 'sound/machines/printer.ogg', 100, TRUE)
			computer.stored_paper--
			computer.visible_message(span_notice("\The [computer] prints out a paper."))
			return TRUE
