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

// Special type of camera for this exact usecase to prevent harddels
/obj/item/camera/app
	name = "internal camera"
	desc = "Specialized internal camera protected from the hellish depths of SSWardrobe. \
	Yell at coders if you somehow manage to see this"

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
	if(internal_camera.blending)
		user.balloon_alert(user, "still blending!")
		return

	var/spooky_camera = locate(/datum/computer_file/program/maintenance/spectre_meter) in computer.stored_files
	internal_camera.see_ghosts = spooky_camera ?  CAMERA_SEE_GHOSTS_BASIC : CAMERA_NO_GHOSTS
	INVOKE_ASYNC(internal_camera, TYPE_PROC_REF(/obj/item/camera, captureimage), target, user, internal_camera.picture_size_x - 1, internal_camera.picture_size_y - 1)

/datum/computer_file/program/maintenance/camera/proc/on_image_captured(cam, target, user, datum/picture/picture)
	SIGNAL_HANDLER

	internal_picture = picture
	picture_appearance.icon = internal_picture.picture_image
	current_picture_name = null
	current_picture_desc = null
	current_picture_caption = null
	can_edit_metadata = TRUE
	picture_number++

/datum/computer_file/program/maintenance/camera/proc/save_picture(mob/user)
	var/datum/computer_file/image/photo_file = new(
		internal_picture.picture_image,
		display_name = internal_picture.picture_name || "photo[picture_number]",
		source_photo_or_painting = internal_picture
	)
	if(computer.store_file(photo_file, user))
		if(can_edit_metadata)
			internal_picture.picture_name = current_picture_name
			internal_picture.picture_desc = "[current_picture_desc] - [internal_picture.picture_desc]"
			internal_picture.caption = current_picture_caption
			can_edit_metadata = FALSE
		return TRUE
	return FALSE

/datum/computer_file/program/maintenance/camera/ui_static_data(mob/user)
	return list("maxNameLength" = 32, "maxDescLength" = 128, "maxCaptionLength" = 256)

/datum/computer_file/program/maintenance/camera/ui_data(mob/user)
	var/list/data = list()

	if(!isnull(internal_picture))
		data["photo"] = REF(picture_appearance.appearance)
		data["canEditMetadata"] = can_edit_metadata
		data["name"] = current_picture_name
		data["desc"] = current_picture_desc
		data["caption"] = current_picture_caption
	data["size"] = internal_camera.picture_size_x
	data["minSize"] = internal_camera.picture_size_x_min
	data["maxSize"] = min(internal_camera.picture_size_x_max, CAMERA_PICTURE_SIZE_HARD_LIMIT)

	return data

/datum/computer_file/program/maintenance/camera/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("adjustSize")
			var/new_size = round(params["value"], 1)
			if(!ISINRANGE(new_size, internal_camera.picture_size_x_min, min(CAMERA_PICTURE_SIZE_HARD_LIMIT, internal_camera.picture_size_x_max)))
				return
			internal_camera.picture_size_x = new_size
			internal_camera.picture_size_y = new_size
		if("setName")
			if(!(internal_picture && can_edit_metadata))
				return
			current_picture_name = trim(params["value"], PREVENT_CHARACTER_TRIM_LOSS(32))
		if("setDesc")
			if(!(internal_picture && can_edit_metadata))
				return
			current_picture_desc = trim(params["value"], PREVENT_CHARACTER_TRIM_LOSS(128))
		if("setCaption")
			if(!(internal_picture && can_edit_metadata))
				return
			current_picture_caption = trim(params["value"], PREVENT_CHARACTER_TRIM_LOSS(256))
		if("savePhoto")
			if(!internal_picture)
				return
			save_picture(ui.user)
	return TRUE

/obj/item/circuit_component/mod_program/camera
	associated_program = /datum/computer_file/program/maintenance/camera
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///A target to take a picture of.
	var/datum/port/input/picture_target
	///The size of the photo to take.
	var/datum/port/input/picture_size
	///The photographed target
	var/datum/port/output/photographed
	/**
	 * Pinged when the image has been captured.
	 * I'm not using the default trigger output here because the process is asynced,
	 * even though I'm mostly sure it only sleeps if there's a set user.
	 */
	var/datum/port/output/photo_taken

/obj/item/circuit_component/mod_program/camera/populate_ports()
	. = ..()
	picture_target = add_input_port("Picture Target", PORT_TYPE_ATOM)
	picture_size = add_input_port("Picture Size", PORT_TYPE_NUMBER)
	photographed = add_output_port("Photographed Entity", PORT_TYPE_ATOM)
	photo_taken = add_output_port("Photo Taken", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_program/camera/register_shell(atom/movable/shell)
	. = ..()
	var/datum/computer_file/program/maintenance/camera/cam = associated_program
	RegisterSignal(cam.internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/obj/item/circuit_component/mod_program/camera/unregister_shell()
	var/datum/computer_file/program/maintenance/camera/cam = associated_program
	UnregisterSignal(cam.internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED)
	return ..()

/obj/item/circuit_component/mod_program/camera/input_received(datum/port/input/port)
	if(!COMPONENT_TRIGGERED_BY(port, trigger_input))
		return
	var/atom/target = picture_target.value
	if(!target)
		var/turf/our_turf = get_location()
		target = locate(our_turf.x, our_turf.y, our_turf.z)
		if(!target)
			return
	var/datum/computer_file/program/maintenance/camera/cam = associated_program
	if(!cam.internal_camera.can_target(target))
		return
	var/pic_size = clamp(round(picture_size.value), 1, cam.internal_camera.picture_size_x_max)-1
	INVOKE_ASYNC(cam.internal_camera, TYPE_PROC_REF(/obj/item/camera, captureimage), target, null, pic_size, pic_size)

/obj/item/circuit_component/mod_program/camera/proc/on_image_captured(obj/item/camera/source, atom/target, mob/user)
	SIGNAL_HANDLER
	photographed.set_output(target)
	photo_taken.set_output(COMPONENT_SIGNAL)
