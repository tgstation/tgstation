GLOBAL_LIST_INIT(print_types, init_print_types())

/proc/init_print_types()
	var/list/print_types = list()
	for(var/obj/item/canvas/canvas_type in typesof(/obj/item/canvas))
		print_types["[canvas_type::width]x[canvas_type::height]"] = list(
			"typepath" = canvas_type,
			"check_proc" = GLOBAL_PROC_REF(check_can_print_canvas),
			"prepare_proc" = GLOBAL_PROC_REF(prepare_canvas_from_file),
		)
	for(var/size in 1 to CAMERA_PICTURE_SIZE_HARD_LIMIT)
		print_types["[ICON_SIZE_X*size]x[ICON_SIZE_Y*size]"] = list(
			"typepath" = /obj/item/photo,
			"check_proc" = GLOBAL_PROC_REF(check_can_print_photo),
			"prepare_proc" = GLOBAL_PROC_REF(prepare_photo_from_file),
		)
	return print_types

/proc/check_can_print_canvas(_typepath, _image_file, obj/item/modular_computer/computer, mob/user)
	if(!(computer.hardware_flag & PROGRAM_CONSOLE))
		to_chat(user, span_notice("Printing error: Canvas printing is only supported on stationary consoles."))
		return FALSE
	if(computer.stored_paper < CANVAS_PAPER_COST)
		to_chat(user, span_notice("Printing error: Your printer needs at least [CANVAS_PAPER_COST] paper to print a canvas."))
		return FALSE
	return TRUE

/proc/prepare_canvas_from_file(obj/item/canvas/canvas, datum/computer_file/image/image_file, obj/item/modular_computer/computer)
	computer.stored_paper -= CANVAS_PAPER_COST
	if(istype(image_file.source_photo_or_painting, /datum/painting))
		var/datum/painting/source_painting = image_file.source_photo_or_painting
		source_painting.fill_canvas(canvas)
		return
	var/datum/icon_transformer/transformer = new()
	transformer.scale(canvas.width, canvas.height)
	transformer.blend_color("#ffffff", BLEND_DEFAULT)
	transformer.blend_icon(uni_icon(image_file.stored_icon, ""), BLEND_DEFAULT)
	var/datum/universal_icon/blank = uni_icon('icons/blanks/32x32.dmi', "nothing", transform = transformer)
	canvas.fill_grid_from_icon(canvas.workspace.get_first_layer_pixel_data(), blank.to_icon())
	canvas.painting_metadata.medium = "Digital Art"
	canvas.used = TRUE

/proc/check_can_print_photo(_typepath, _image_file, obj/item/modular_computer/computer, mob/user)
	if(computer.stored_paper < PHOTO_PAPER_COST)
		to_chat(user, span_notice("Printing error: Your printer needs at least [PHOTO_PAPER_COST] paper to print a photo."))
		return FALSE
	return TRUE

/proc/prepare_photo_from_file(obj/item/photo/photo, datum/computer_file/image/image_file, obj/item/modular_computer/computer)
	computer.stored_paper -= PHOTO_PAPER_COST
	if(istype(image_file.source_photo_or_painting, /datum/picture))
		var/datum/picture/source_photo = image_file.source_photo_or_painting
		photo.set_picture(source_photo, TRUE, TRUE)
		return
	var/icon/photo_image = image_file.stored_icon
	var/width = photo_image.Width()
	var/height = photo_image.Height()
	var/datum/icon_transformer/transformer = new()
	transformer.scale(width, height)
	transformer.blend_color("#ffffff", BLEND_DEFAULT)
	transformer.blend_icon(uni_icon(photo_image, ""), BLEND_DEFAULT)
	var/datum/universal_icon/blank = uni_icon('icons/blanks/32x32.dmi', "nothing", transform = transformer)
	var/datum/picture/new_photo = new(image_file.filename, desc = "A printout of a digital image.", image = blank.to_icon(), size_x = width, size_y = height, autogenerate_icon = TRUE, author_ckey_ = image_file.author_ckey)
	image_file.source_photo_or_painting = new_photo
	photo.set_picture(new_photo, TRUE, TRUE)

/datum/computer_file/program/filemanager
	filename = "filemanager"
	filedesc = "File Manager"
	extended_desc = "This program allows management of files."
	program_open_overlay = "generic"
	size = 8
	program_flags = NONE
	undeletable = TRUE
	tgui_id = "NtosFileManager"
	program_icon = "folder"

	var/open_file
	var/error

/datum/computer_file/program/filemanager/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PRG_deletefile")
			var/datum/computer_file/file = computer.find_file_by_name(params["name"])
			if(!file || file.undeletable)
				return
			computer.remove_file(file)
			return TRUE
		if("PRG_usbdeletefile")
			if(!computer.inserted_disk)
				return
			var/datum/computer_file/file = computer.find_file_by_name(params["name"], computer.inserted_disk)
			if(!file || file.undeletable)
				return
			computer.inserted_disk.remove_file(file)
			return TRUE
		if("PRG_renamefile")
			var/datum/computer_file/file = computer.find_file_by_name(params["name"])
			if(!file)
				return
			var/newname = reject_bad_name(params["new_name"])
			if(!newname || newname != params["new_name"])
				playsound(computer, 'sound/machines/terminal/terminal_error.ogg', 25, FALSE)
				return
			file.filename = newname
			return TRUE
		if("PRG_usbrenamefile")
			if(!computer.inserted_disk)
				return
			var/datum/computer_file/file = computer.find_file_by_name(params["name"], computer.inserted_disk)
			if(!file)
				return
			var/newname = reject_bad_name(params["new_name"])
			if(!newname || newname != params["new_name"])
				playsound(computer, 'sound/machines/terminal/terminal_error.ogg', 25, FALSE)
				return
			file.filename = newname
			return TRUE
		if("PRG_copytousb")
			if(!computer.inserted_disk)
				return
			var/datum/computer_file/F = computer.find_file_by_name(params["name"])
			if(!F)
				return
			if(computer.find_file_by_name(params["name"], computer.inserted_disk))
				return
			var/datum/computer_file/C = F.clone(FALSE)
			computer.inserted_disk.add_file(C)
			return TRUE
		if("PRG_copyfromusb")
			if(!computer.inserted_disk)
				return
			var/datum/computer_file/F = computer.find_file_by_name(params["name"], computer.inserted_disk)
			if(!F || !istype(F))
				return
			if(!computer.can_store_file(F))
				return FALSE
			var/datum/computer_file/C = F.clone(FALSE)
			computer.store_file(C, usr)
			return TRUE
		if("PRG_togglesilence")
			var/datum/computer_file/program/binary = computer.find_file_by_name(params["name"])
			if(!binary || !istype(binary))
				return
			binary.alert_silenced = !binary.alert_silenced
		if("PRG_print")
			var/datum/computer_file/image/picture = computer.find_file_by_name(params["name"])
			if(!istype(picture))
				return
			try_print(picture, usr)
		if("PRG_usbprint")
			if(!computer.inserted_disk)
				return
			var/datum/computer_file/image/picture = computer.find_file_by_name(params["name"], computer.inserted_disk)
			if(!istype(picture))
				return
			try_print(picture, usr)

/datum/computer_file/program/filemanager/proc/try_print(datum/computer_file/image/picture, mob/user)
	var/width = picture.stored_icon.Width()
	var/height = picture.stored_icon.Height()
	var/list/print_type = GLOB.print_types["[width]x[height]"]
	if(!print_type)
		return
	var/obj/item/print_typepath = print_type["typepath"]
	if(!call(print_type["check_proc"])(print_typepath, picture, computer, user))
		return
	var/obj/item/printed_item = new print_typepath(get_turf(computer.physical))
	call(print_type["prepare_proc"])(printed_item, picture, computer)
	playsound(computer.physical, 'sound/machines/printer.ogg', 100, TRUE)

/datum/computer_file/program/filemanager/ui_data(mob/user)
	var/list/data = list()
	if(error)
		data["error"] = error
	if(!computer)
		data["error"] = "I/O ERROR: Unable to access hard drive."
	else
		var/list/files = list()
		for(var/datum/computer_file/F as anything in computer.stored_files)
			var/noisy = FALSE
			var/silenced = FALSE
			var/printable = FALSE
			var/datum/computer_file/program/binary = F
			if(istype(binary))
				noisy = binary.alert_able
				silenced = binary.alert_silenced
			var/datum/computer_file/image/picture_file = F
			if(istype(picture_file))
				var/width = picture_file.stored_icon.Width()
				var/height = picture_file.stored_icon.Height()
				printable = !!GLOB.print_types["[width]x[height]"]
			files += list(list(
				"name" = F.filename,
				"type" = F.filetype,
				"size" = F.size,
				"undeletable" = F.undeletable,
				"alert_able" = noisy,
				"alert_silenced" = silenced,
				"printable" = printable,
			))
		data["files"] = files
		if(computer.inserted_disk)
			data["usbconnected"] = TRUE
			var/list/usbfiles = list()
			for(var/datum/computer_file/F as anything in computer.inserted_disk.stored_files)
				var/printable = FALSE
				var/datum/computer_file/image/picture_file = F
				if(istype(picture_file))
					var/width = picture_file.stored_icon.Width()
					var/height = picture_file.stored_icon.Height()
					printable = !!GLOB.print_types["[width]x[height]"]
				usbfiles += list(list(
					"name" = F.filename,
					"type" = F.filetype,
					"size" = F.size,
					"undeletable" = F.undeletable,
					"printable" = printable,
				))
			data["usbfiles"] = usbfiles

	return data
