/datum/computer_file/program/maintenance/camera
	filename = "camera_app"
	filedesc = "Camera"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "This program allows the taking of pictures."
	size = 4
	usage_flags = PROGRAM_TABLET
	tgui_id = "NtosCamera"
	program_icon = "camera"
	/// Camera built-into the tablet.
	var/obj/item/camera/internal_camera
	/// Latest picture taken by the app.
	var/datum/picture/internal_picture
	/// How many pictures were taken already, used for the camera's TGUI photo display
	var/picture_number = 1

/datum/computer_file/program/maintenance/camera/New()
	. = ..()
	internal_camera = new()
	internal_camera.print_picture_on_snap = FALSE

/datum/computer_file/program/maintenance/camera/Destroy()
	if(internal_camera)
		QDEL_NULL(internal_camera)
	if(internal_picture)
		QDEL_NULL(internal_picture)
	return ..()

/datum/computer_file/program/maintenance/camera/tap(atom/tapped_atom, mob/living/user, params)
	. = ..()

	if(internal_picture)
		QDEL_NULL(internal_picture)
	var/turf/our_turf = get_turf(tapped_atom)
	internal_picture = internal_camera.captureimage(our_turf, user, internal_camera.picture_size_x + 1, internal_camera.picture_size_y + 1)
	picture_number++
	computer.save_photo(internal_picture.picture_image)

/datum/computer_file/program/maintenance/camera/ui_data(mob/user)
	var/list/data = get_header_data()

	if(!isnull(internal_picture))
		user << browse_rsc(internal_picture.picture_image, "tmp_photo[picture_number].png")
		data["photo"] = "tmp_photo[picture_number].png"

	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	if(printer)
		data["has_printer"] = !!printer
		data["paper_left"] = printer.stored_paper

	return data

/datum/computer_file/program/maintenance/camera/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("print_photo")
			var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
			if(!printer)
				to_chat(usr, span_notice("Hardware error: Printer not found."))
				return
			if(printer.stored_paper <= 0)
				to_chat(usr, span_notice("Hardware error: Printer out of paper."))
				return
			internal_camera.printpicture(usr, internal_picture)
			printer.stored_paper--
			computer.visible_message(span_notice("\The [computer] prints out a paper."))
