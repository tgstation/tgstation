/datum/computer_file/program/filemanager
	filename = "filemanager"
	filedesc = "File Manager"
	extended_desc = "This program allows management of files."
	program_icon_state = "generic"
	size = 8
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	undeletable = TRUE
	tgui_id = "ntos_file_manager"

	var/open_file
	var/error

/datum/computer_file/program/filemanager/ui_act(action, params)
	if(..())
		return

	var/obj/item/computer_hardware/hard_drive/HDD = computer.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/RHDD = computer.all_components[MC_SDD]

	switch(action)
		if("PRG_deletefile")
			if(!HDD)
				return
			var/datum/computer_file/file = HDD.find_file_by_name(params["name"])
			if(!file || file.undeletable)
				return
			HDD.remove_file(file)
			return TRUE
		if("PRG_usbdeletefile")
			if(!RHDD)
				return
			var/datum/computer_file/file = RHDD.find_file_by_name(params["name"])
			if(!file || file.undeletable)
				return
			RHDD.remove_file(file)
			return TRUE
		if("PRG_rename")
			if(!HDD)
				return
			var/datum/computer_file/file = HDD.find_file_by_name(params["name"])
			if(!file)
				return
			var/newname = params["new_name"]
			if(!newname)
				return
			file.filename = newname
			return TRUE
		if("PRG_copytousb")
			if(!HDD || !RHDD)
				return
			var/datum/computer_file/F = HDD.find_file_by_name(params["name"])
			if(!F)
				return
			var/datum/computer_file/C = F.clone(FALSE)
			RHDD.store_file(C)
			return TRUE
		if("PRG_copyfromusb")
			if(!HDD || !RHDD)
				return
			var/datum/computer_file/F = RHDD.find_file_by_name(params["name"])
			if(!F || !istype(F))
				return
			var/datum/computer_file/C = F.clone(FALSE)
			HDD.store_file(C)
			return TRUE

/datum/computer_file/program/filemanager/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/hard_drive/HDD = computer.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/portable/RHDD = computer.all_components[MC_SDD]
	if(error)
		data["error"] = error
	if(!computer || !HDD)
		data["error"] = "I/O ERROR: Unable to access hard drive."
	else
		var/list/files = list()
		for(var/datum/computer_file/F in HDD.stored_files)
			files += list(list(
				"name" = F.filename,
				"type" = F.filetype,
				"size" = F.size,
				"undeletable" = F.undeletable
			))
		data["files"] = files
		if(RHDD)
			data["usbconnected"] = TRUE
			var/list/usbfiles = list()
			for(var/datum/computer_file/F in RHDD.stored_files)
				usbfiles += list(list(
					"name" = F.filename,
					"type" = F.filetype,
					"size" = F.size,
					"undeletable" = F.undeletable
				))
			data["usbfiles"] = usbfiles

	return data
