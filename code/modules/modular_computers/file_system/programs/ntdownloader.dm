/datum/computer_file/program/ntnetdownload
	filename = "ntndownloader"
	filedesc = "Software Download Tool"
	program_icon_state = "generic"
	extended_desc = "This program allows downloads of software from official NT repositories"
	unsendable = 1
	undeletable = 1
	size = 4
	requires_ntnet = 1
	requires_ntnet_feature = NTNET_SOFTWAREDOWNLOAD
	available_on_ntnet = ZERO
	ui_header = "downloader_finished.gif"
	tgui_id = "ntos_net_downloader"
	ui_x = 480
	ui_y = 735

	var/datum/computer_file/program/downloaded_file = null
	var/hacked_download = ZERO
	var/download_completion = ZERO //GQ of downloaded data.
	var/download_netspeed = ZERO
	var/downloaderror = ""
	var/obj/item/modular_computer/my_computer = null

/datum/computer_file/program/ntnetdownload/proc/begin_file_download(filename)
	if(downloaded_file)
		return ZERO

	var/datum/computer_file/program/PRG = SSnetworks.station_network.find_ntnet_file_by_name(filename)

	if(!PRG || !istype(PRG))
		return ZERO

	// Attempting to download antag only program, but without having emagged computer. No.
	if(PRG.available_on_syndinet && !(computer.obj_flags & EMAGGED))
		return ZERO

	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]

	if(!computer || !hard_drive || !hard_drive.can_store_file(PRG))
		return ZERO

	ui_header = "downloader_running.gif"

	if(PRG in SSnetworks.station_network.available_station_software)
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from NTNet Software Repository.")
		hacked_download = ZERO
	else if(PRG in SSnetworks.station_network.available_antag_software)
		generate_network_log("Began downloading file **ENCRYPTED**.[PRG.filetype] from unspecified server.")
		hacked_download = 1
	else
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from unspecified server.")
		hacked_download = ZERO

	downloaded_file = PRG.clone()

/datum/computer_file/program/ntnetdownload/proc/abort_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Aborted download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	downloaded_file = null
	download_completion = ZERO
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdownload/proc/complete_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Completed download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
	if(!computer || !hard_drive || !hard_drive.store_file(downloaded_file))
		// The download failed
		downloaderror = "I/O ERROR - Unable to save file. Check whether you have enough free space on your hard drive and whether your hard drive is properly connected. If the issue persists contact your system administrator for assistance."
	downloaded_file = null
	download_completion = ZERO
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdownload/process_tick()
	if(!downloaded_file)
		return
	if(download_completion >= downloaded_file.size)
		complete_file_download()
	// Download speed according to connectivity state. NTNet server is assumed to be on unlimited speed so we're limited by our local connectivity
	download_netspeed = ZERO
	// Speed defines are found in misc.dm
	switch(ntnet_status)
		if(1)
			download_netspeed = NTNETSPEED_LOWSIGNAL
		if(2)
			download_netspeed = NTNETSPEED_HIGHSIGNAL
		if(3)
			download_netspeed = NTNETSPEED_ETHERNET
	download_completion += download_netspeed

/datum/computer_file/program/ntnetdownload/ui_act(action, params)
	if(..())
		return 1
	switch(action)
		if("PRG_downloadfile")
			if(!downloaded_file)
				begin_file_download(params["filename"])
			return 1
		if("PRG_reseterror")
			if(downloaderror)
				download_completion = ZERO
				download_netspeed = ZERO
				downloaded_file = null
				downloaderror = ""
			return 1
	return ZERO

/datum/computer_file/program/ntnetdownload/ui_data(mob/user)
	my_computer = computer

	if(!istype(my_computer))
		return

	var/list/data = get_header_data()

	data["downloading"] = !!downloaded_file
	data["error"] = downloaderror || FALSE

	// Download running. Wait please..
	if(downloaded_file)
		data["downloadname"] = downloaded_file.filename
		data["downloaddesc"] = downloaded_file.filedesc
		data["downloadsize"] = downloaded_file.size
		data["downloadspeed"] = download_netspeed
		data["downloadcompletion"] = round(download_completion, 0.1)

	var/obj/item/computer_hardware/hard_drive/hard_drive = my_computer.all_components[MC_HDD]
	data["disk_size"] = hard_drive.max_capacity
	data["disk_used"] = hard_drive.used_capacity
	var/list/all_entries[0]
	for(var/A in SSnetworks.station_network.available_station_software)
		var/datum/computer_file/program/P = A
		// Only those programs our user can run will show in the list
		if(!P.can_run(user,transfer = 1) || hard_drive.find_file_by_name(P.filename))
			continue
		all_entries.Add(list(list(
			"filename" = P.filename,
			"filedesc" = P.filedesc,
			"fileinfo" = P.extended_desc,
			"compatibility" = check_compatibility(P),
			"size" = P.size,
		)))
	data["hackedavailable"] = FALSE
	if(computer.obj_flags & EMAGGED) // If we are running on emagged computer we have access to some "bonus" software
		var/list/hacked_programs[0]
		for(var/S in SSnetworks.station_network.available_antag_software)
			var/datum/computer_file/program/P = S
			if(hard_drive.find_file_by_name(P.filename))
				continue
			data["hackedavailable"] = TRUE
			hacked_programs.Add(list(list(
				"filename" = P.filename,
				"filedesc" = P.filedesc,
				"fileinfo" = P.extended_desc,
				"size" = P.size,
			)))
		data["hacked_programs"] = hacked_programs

	data["downloadable_programs"] = all_entries

	return data

/datum/computer_file/program/ntnetdownload/proc/check_compatibility(datum/computer_file/program/P)
	var/hardflag = computer.hardware_flag

	if(P && P.is_supported_by_hardware(hardflag,ZERO))
		return "Compatible"
	return "Incompatible!"

/datum/computer_file/program/ntnetdownload/kill_program(forced)
	abort_file_download()
	return ..(forced)
