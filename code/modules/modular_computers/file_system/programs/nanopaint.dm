#define PALETTE_SIZE 32
#define SANE_PHOTO_EDITING_SIZE_LIMIT 96 // I really don't think the server can handle someone editing large images, but a photo taken with the default camera dimensions shouldn't be too awful.

GLOBAL_LIST_INIT(nanopaint_supported_filetypes, zebra_typecacheof(list(\
	/datum/computer_file/data/paint_project = /datum/computer_file/data/paint_project,\
	/datum/computer_file/image = /datum/computer_file/image,\
)))

/datum/computer_file/program/nanopaint
	filename = "nanopaint"
	filedesc = "NanoPaint"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "generic"
	extended_desc = "Draw pictures on your device."
	tgui_id = "NtosNanopaint"
	program_icon = "paintbrush"
	size = 5
	can_run_on_flags = PROGRAM_ALL
	/// A weak reference to the data file containing the workspace currently being worked on.
	var/datum/weakref/backing_file
	/// The name of the file that was opened, in case we are trying to save a file that is no longer accessible.
	var/opened_file_name
	/// The typepath of the file that was opened, in case we are trying to save a file that is no longer accessible.
	var/datum/computer_file/opened_file_type
	var/datum/sprite_editor_workspace/current_workspace
	/// If the opened file is an unmodified photo or painting, this is a reference to it.
	var/source_photo_or_painting
	/// If we have modified this project, store whatever unmodified photo or painting we were made from here.
	var/source_on_undo_all
	var/current_color = "#ffffffff"
	var/list/palette = list()
	var/list/dialog

/datum/computer_file/program/nanopaint/ui_static_data(mob/user)
	. = ..()
	return list(
		"templateSizes" = GLOB.canvas_dimensions,
		"saveableTypes" = list(
			list(
				"displayName" = "NanoPaint Project (.[/datum/computer_file/data/paint_project::filetype])",
				"typepath" = /datum/computer_file/data/paint_project,
				"extension" = /datum/computer_file/data/paint_project::filetype,
			),
			list(
				"displayName" = "PNG Image (.[/datum/computer_file/image::filetype])",
				"typepath" = /datum/computer_file/image,
				"extension" = /datum/computer_file/image::filetype,
			),
		),
		"minSize" = 1,
		"maxSize" = SANE_PHOTO_EDITING_SIZE_LIMIT,
	)

/datum/computer_file/program/nanopaint/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["dialog"] = dialog
	var/list/editor_data = list()
	editor_data["serverSelectedColor"] = current_color
	editor_data["serverPalette"] = palette
	editor_data["maxServerColors"] = PALETTE_SIZE
	editor_data["onSelectServerColor"] = "onSelectColor"
	editor_data["onAddServerColor"] = "onAddPaletteColor"
	editor_data["onRemoveServerColor"] = "onRemovePaletteColor"
	if(current_workspace)
		editor_data += current_workspace.sprite_editor_ui_data()
	data["editorData"] = editor_data
	data["workspaceOpen"] = !!current_workspace
	data["diskInserted"] = !!computer.inserted_disk
	var/list/all_files = computer.get_files(TRUE)
	var/list/drive_files = list()
	var/list/disk_files = list()
	for(var/datum/computer_file/file as anything in all_files)
		var/base_supported_type = is_type_in_typecache(file, GLOB.nanopaint_supported_filetypes)
		if(!base_supported_type)
			continue
		var/list/file_data = list("name" = file.filename, "extension" = file.filetype, "uid" = file.uid, "baseType" = base_supported_type)
		if(file.computer)
			drive_files += list(file_data)
		else
			disk_files += list(file_data)
	data["driveFiles"] = drive_files
	data["diskFiles"] = disk_files
	return data

/datum/computer_file/program/nanopaint/proc/check_dialog(act, modal_type)
	return dialog && dialog["type"] == modal_type && (!act || dialog["action"] == act)

/datum/computer_file/program/nanopaint/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr
	switch(action)
		if("spriteEditorCommand")
			if(!current_workspace)
				return
			var/command = params["command"]
			switch(command)
				if("transaction")
					current_workspace.new_transaction(params["transaction"])
					if(!source_on_undo_all && source_photo_or_painting)
						source_on_undo_all = source_photo_or_painting
						source_photo_or_painting = null
				if("toggleVisible")
					current_workspace.toggle_layer_visible(params["layer"])
				if("undo")
					current_workspace.undo()
					if(!length(current_workspace.undo_stack))
						source_photo_or_painting = source_on_undo_all
						source_on_undo_all = null
				if("redo")
					current_workspace.redo()
					if(!source_on_undo_all && source_photo_or_painting)
						source_on_undo_all = source_photo_or_painting
						source_photo_or_painting = null
			return TRUE
		if("onSelectColor")
			current_color = params["color"]
			return TRUE
		if("onAddPaletteColor")
			if(length(palette) >= PALETTE_SIZE)
				return
			palette += params["color"]
		if("onRemovePaletteColor")
			var/index = params["index"]
			palette.Cut(index, index+1)
			return TRUE
		if("closeDialog")
			dialog = null
			return TRUE
		if("newDialog")
			dialog = list("type" = "new")
			return TRUE
		if("new")
			if(!check_dialog(null, "new"))
				return
			var/width = params["width"]
			if(!ISINRANGE(width, 1, SANE_PHOTO_EDITING_SIZE_LIMIT))
				return
			var/height = params["height"]
			if(!ISINRANGE(height, 1, SANE_PHOTO_EDITING_SIZE_LIMIT))
				return
			dialog = null
			close_workspace()
			INVOKE_ASYNC(src, PROC_REF(new_workspace), width, height)
			return TRUE
		if("openDialog")
			dialog = list("type" = "select", "title" = "Open File", "confirmText" = "Open", "action" = "open")
			return TRUE
		if("open")
			if(!check_dialog("open", "select"))
				return
			dialog = null
			INVOKE_ASYNC(src, PROC_REF(open_file), user, params["uid"], params["onDisk"], params["name"], text2path(params["type"]))
			return TRUE
		if("save")
			var/datum/computer_file/actual_file = backing_file?.resolve()
			if(!actual_file)
				if(!opened_file_name)
					dialog = list("type" = "select", "title" = "Save As", "confirmText" = "Save", "action" = "saveAs")
					return TRUE
				actual_file = computer.find_file_by_full_name("[opened_file_name].[opened_file_type::filetype]")
			if(actual_file && actual_file.computer != computer && actual_file.disk_host != computer.inserted_disk)
				actual_file = null
			if(actual_file)
				INVOKE_ASYNC(src, PROC_REF(write_to_file), user, actual_file, actual_file.disk_host)
			else
				INVOKE_ASYNC(src, PROC_REF(save_file), user, opened_file_name, opened_file_type)
			return TRUE
		if("saveAsDialog")
			dialog = list("type" = "select", "title" = "Save As", "confirmText" = "Save", "action" = "saveAs")
			return TRUE
		if("saveAs", "overwrite")
			if(!check_dialog(action, action == "saveAs" ? "select" : "confirm"))
				return
			dialog = null
			var/uid = params["uid"]
			var/new_file_name = params["name"]
			var/saving_to_disk = params["onDisk"]
			var/datum/computer_file/new_file_type = text2path(params["type"])
			var/extension = new_file_type::filetype
			var/datum/computer_file/existing_file
			if(saving_to_disk)
				if(!computer.inserted_disk)
					dialog = list("type" = "error", "message" = "[new_file_name] - The disk has been removed.")
					return TRUE
				if(uid)
					existing_file = computer.find_file_by_uid(uid, computer.inserted_disk)
				else
					existing_file = computer.find_file_by_full_name("[new_file_name].[extension]", computer.inserted_disk)
			else
				if(uid)
					existing_file = computer.find_file_by_uid(uid)
				else
					existing_file = computer.find_file_by_full_name("[new_file_name].[extension]")
			if(existing_file)
				if(action == "saveAs")
					dialog = list(
						"type" = "confirm",
						"title" = "Confirm Save As",
						"message" = "[new_file_name] already exists. Do you want to overwrite this file?",
						"action" = "overwrite",
						"params" = list("name" = new_file_name,
							"onDisk" = params["onDisk"],
							"type" = new_file_type),
						)
				else
					INVOKE_ASYNC(src, PROC_REF(write_to_file), user, existing_file)
				return TRUE
			INVOKE_ASYNC(src, PROC_REF(save_file), user, new_file_name, new_file_type, saving_to_disk && computer.inserted_disk)
			return TRUE

/datum/computer_file/program/nanopaint/proc/new_workspace(width, height)
	current_workspace = new(width, height)

/datum/computer_file/program/nanopaint/proc/open_file(mob/user, uid, on_disk, file_name, datum/computer_file/file_type)
	var/datum/computer_file/file_being_opened
	var/full_file_name = file_name + file_type::filetype
	if(on_disk)
		if(!computer.inserted_disk)
			dialog = list("type" = "error", "message" = "[full_file_name] - The disk has been removed.")
			return
		if(uid)
			file_being_opened = computer.find_file_by_uid(uid, computer.inserted_disk)
		else
			file_being_opened = computer.find_file_by_full_name(full_file_name, computer.inserted_disk)
	else
		if(uid)
			file_being_opened = computer.find_file_by_uid(uid)
		else
			file_being_opened = computer.find_file_by_full_name(full_file_name)
	if(!file_being_opened)
		dialog = list("type" = "error", "message" = "[full_file_name] - The selected file could not be found")
		return
	var/base_supported_type = is_type_in_typecache(file_being_opened, GLOB.nanopaint_supported_filetypes)
	if(!base_supported_type)
		dialog = list("type" = "error", "message" = "[full_file_name] - Unsupported format")
		return
	close_workspace()
	switch(base_supported_type)
		if(/datum/computer_file/data/paint_project)
			var/datum/computer_file/data/paint_project/project_file = file_being_opened
			current_workspace = project_file.workspace.copy()
			backing_file = WEAKREF(file_being_opened)
			opened_file_name = project_file.filename
			source_photo_or_painting = project_file.source_photo_or_painting
		if(/datum/computer_file/image)
			var/datum/computer_file/image/image_file = file_being_opened
			var/icon/image = image_file.stored_icon
			var/image_width = image.Width()
			var/image_height = image.Height()
			if(image_width <= 0 || image_height <= 0)
				dialog = list("type" = "error", "message" = "[file_name] - Invalid dimensions")
				return
			if(image_width > SANE_PHOTO_EDITING_SIZE_LIMIT || image_height > SANE_PHOTO_EDITING_SIZE_LIMIT)
				dialog = list("type" = "error", "message" = "[file_name] - Too large")
				return
			current_workspace = new(image_width, image_height)
			fill_grid_from_icon(current_workspace.get_first_layer_pixel_data(), image)
			source_photo_or_painting = image_file.source_photo_or_painting
	opened_file_type = base_supported_type

/datum/computer_file/program/nanopaint/proc/write_to_file(mob/user, datum/computer_file/file)
	switch(file.type)
		if(/datum/computer_file/data/paint_project)
			var/datum/computer_file/data/paint_project/project_file = file
			project_file.workspace = current_workspace.copy()
			project_file.set_source(source_photo_or_painting)
			backing_file = WEAKREF(project_file)
		if(/datum/computer_file/image)
			var/datum/computer_file/image/image_file = file
			image_file.stored_icon = current_workspace.to_icon()
			image_file.assign_path()
			image_file.set_source(source_photo_or_painting)
			if(!source_photo_or_painting)
				image_file.author_ckey = user.ckey
				message_admins("[ADMIN_LOOKUP(user)] has saved a custom image to [computer] as [file.filename].[file.filetype].")
				log_player_image_creation("[key_name(user)] has saved a custom image to [computer] as [file.filename].[file.filetype]", user, image_file.stored_icon)

/datum/computer_file/program/nanopaint/proc/save_file(mob/user, name, file_type, obj/item/disk/computer/target_disk)
	var/datum/computer_file/file = new file_type()
	var/file_stored
	if(target_disk)
		file_stored = target_disk.add_file(file)
	else
		file_stored = computer.store_file(file)
	if(file_stored)
		write_to_file(user, file)
	else
		dialog = list("type" = "error", "message" = "[name] - Unable to save file")
		SStgui.update_uis(computer)

/datum/computer_file/program/nanopaint/proc/close_workspace()
	backing_file = null
	opened_file_name = null
	opened_file_type = null
	current_workspace = null
	source_photo_or_painting = null
	source_on_undo_all = null
	palette = list()
	current_color = "#ffffffff"

/datum/computer_file/program/nanopaint/kill_program(mob/user)
	close_workspace()
	return ..()

#undef SANE_PHOTO_EDITING_SIZE_LIMIT
#undef PALETTE_SIZE
