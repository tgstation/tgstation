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
	/// How many pictures were taken already, used for the camera's TGUI photo display
	var/picture_number = 1

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
	RegisterSignal(internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(save_picture))

/datum/computer_file/program/maintenance/camera/Destroy()
	QDEL_NULL(internal_camera)
	QDEL_NULL(internal_picture)
	return ..()

/datum/computer_file/program/maintenance/camera/tap(atom/tapped_atom, mob/living/user, list/modifiers)
	. = ..()

	QDEL_NULL(internal_picture)
	internal_camera.see_ghosts = (locate(/datum/computer_file/program/maintenance/spectre_meter) in computer.stored_files) ?  CAMERA_SEE_GHOSTS_BASIC : CAMERA_NO_GHOSTS
	internal_camera.attempt_picture(get_turf(tapped_atom), user)

/datum/computer_file/program/maintenance/camera/proc/save_picture(cam, target, user, datum/picture/picture)
	SIGNAL_HANDLER

	internal_picture = picture
	picture_number++
	computer.save_photo(internal_picture.picture_image)

/datum/computer_file/program/maintenance/camera/ui_data(mob/user)
	var/list/data = list()

	if(!isnull(internal_picture))
		user << browse_rsc(internal_picture.picture_image, "tmp_photo[picture_number].png")
		data["photo"] = "tmp_photo[picture_number].png"

	data["paper_left"] = computer.stored_paper

	return data

/datum/computer_file/program/maintenance/camera/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("print_photo")
			if(computer.stored_paper <= 0)
				to_chat(ui.user, span_notice("Hardware error: Printer out of paper."))
				return
			internal_camera.printpicture(usr, internal_picture)
			computer.stored_paper--
			computer.visible_message(span_notice("\The [computer] prints out a paper."))
