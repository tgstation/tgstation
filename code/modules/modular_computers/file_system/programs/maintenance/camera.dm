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

/datum/computer_file/program/maintenance/camera/New()
	. = ..()
	internal_camera = new()

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
	var/atom/target = locate(our_turf.x + 3, our_turf.y + 3, our_turf.z)
	if(!target)
		return
	internal_picture = internal_camera.captureimage(target, user, internal_camera.picture_size_x + 1, internal_camera.picture_size_y + 1)

	computer.save_photo(internal_picture.picture_image)

/datum/computer_file/program/maintenance/camera/ui_data(mob/user)
	var/list/data = get_header_data()

	if(!isnull(internal_picture))
		user << browse_rsc(internal_picture.picture_image, "tmp_photo[internal_picture.picture_image].png")
		data["photo"] = "tmp_photo[internal_picture.picture_image].png"

	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	if(printer)
		data["paper_left"] = printer.stored_paper

	return data


/*
/datum/computer_file/program/crew_manifest/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/crew_manifest/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("PRG_print")
			if(computer && printer) //This option should never be called if there is no printer
				var/contents = {"<h4>Crew Manifest</h4>
								<br>
								[GLOB.data_core ? GLOB.data_core.get_manifest_html(0) : ""]
								"}
				if(!printer.print_text(contents,text("crew manifest ([])", station_time_timestamp())))
					to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
					return
				else
					computer.visible_message(span_notice("\The [computer] prints out a paper."))
*/

