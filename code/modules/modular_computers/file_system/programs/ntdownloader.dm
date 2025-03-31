/datum/computer_file/program/ntnetdownload
	filename = "ntsoftwarehub"
	filedesc = "NT Software Hub"
	program_open_overlay = "generic"
	extended_desc = "This program allows downloads of software from official NT repositories"
	undeletable = TRUE
	size = 4
	program_flags = PROGRAM_REQUIRES_NTNET
	tgui_id = "NtosNetDownloader"
	program_icon = "download"

	///The program currently being downloaded.
	var/datum/computer_file/program/downloaded_file
	///Boolean on whether the `downloaded_file` is being downloaded from the Syndicate store,
	///in which case it will appear as 'ENCRYPTED' in logs, rather than display file name.
	var/hacked_download = FALSE
	///How much of the data has been downloaded.
	var/download_completion
	///The error message being displayed to the user, if necessary. Null if there isn't one.
	var/downloaderror

	///The list of categories to display in the UI, in order of which they appear.
	var/static/list/show_categories = list(
		PROGRAM_CATEGORY_DEVICE,
		PROGRAM_CATEGORY_EQUIPMENT,
		PROGRAM_CATEGORY_GAMES,
		PROGRAM_CATEGORY_SECURITY,
		PROGRAM_CATEGORY_ENGINEERING,
		PROGRAM_CATEGORY_SUPPLY,
		PROGRAM_CATEGORY_SCIENCE,
	)

/datum/computer_file/program/ntnetdownload/kill_program(mob/user)
	abort_file_download()
	ui_header = null
	. = ..()

/datum/computer_file/program/ntnetdownload/proc/begin_file_download(filename)
	if(downloaded_file)
		return FALSE

	var/datum/computer_file/program/PRG = SSmodular_computers.find_ntnet_file_by_name(filename)

	if(!PRG || !istype(PRG))
		return FALSE

	// Attempting to download antag only program, but without having emagged/syndicate computer. No.
	if((PRG.program_flags & PROGRAM_ON_SYNDINET_STORE) && !(computer.obj_flags & EMAGGED))
		return FALSE

	if(!computer || !computer.can_store_file(PRG))
		return FALSE

	ui_header = "downloader_running.gif"

	if(PRG in SSmodular_computers.available_station_software)
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from NTNet Software Repository.")
		hacked_download = FALSE
	else if(PRG in SSmodular_computers.available_antag_software)
		generate_network_log("Began downloading file **ENCRYPTED**.[PRG.filetype] from unspecified server.")
		hacked_download = TRUE
	else
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from unspecified server.")
		hacked_download = FALSE

	downloaded_file = PRG.clone()

	// If the filesize is 0 (or somehow lower), we instantly download to avoid invalid number issues with stepwise download.
	if(downloaded_file.size <= 0)
		complete_file_download()

/datum/computer_file/program/ntnetdownload/proc/abort_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Aborted download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	downloaded_file = null
	download_completion = FALSE
	ui_header = null

/datum/computer_file/program/ntnetdownload/proc/complete_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Completed download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	if(!computer || !computer.store_file(downloaded_file))
		// The download failed
		downloaderror = "I/O ERROR - Unable to save file. Check whether you have enough free space on your hard drive and whether your hard drive is properly connected. If the issue persists contact your system administrator for assistance."
	downloaded_file = null
	download_completion = FALSE
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdownload/process_tick(seconds_per_tick)
	if(!downloaded_file)
		return
	if(download_completion >= downloaded_file.size)
		complete_file_download()
		return
	// Download speed according to connectivity state. NTNet server is assumed to be on unlimited speed so we're limited by our local connectivity
	var/download_netspeed = 0
	// Speed defines are found in misc.dm
	switch(ntnet_status)
		if(NTNET_LOW_SIGNAL)
			download_netspeed = NTNETSPEED_LOWSIGNAL
		if(NTNET_GOOD_SIGNAL)
			download_netspeed = NTNETSPEED_HIGHSIGNAL
		if(NTNET_ETHERNET_SIGNAL)
			download_netspeed = NTNETSPEED_ETHERNET
	if(download_netspeed <= 0)
		return
	if(HAS_TRAIT(computer, TRAIT_MODPC_HALVED_DOWNLOAD_SPEED))
		download_netspeed *= 0.5
	// We don't complete it here so we stay on 100% for a cycle
	// We do cap out our completion to avoid UI issues
	download_completion = min(download_completion  + download_netspeed, downloaded_file.size)

/datum/computer_file/program/ntnetdownload/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PRG_downloadfile")
			if(!downloaded_file)
				begin_file_download(params["filename"])
			return TRUE
		if("PRG_reseterror")
			if(downloaderror)
				download_completion = FALSE
				downloaded_file = null
				downloaderror = ""
			return TRUE
	return FALSE

/datum/computer_file/program/ntnetdownload/ui_data(mob/user)
	var/list/data = list()
	var/list/access = computer.GetAccess()

	data["downloading"] = !!downloaded_file
	data["error"] = downloaderror || FALSE

	// Download running. Wait please..
	if(downloaded_file)
		data["downloadname"] = downloaded_file.filename
		data["downloaddesc"] = downloaded_file.filedesc
		data["downloadsize"] = downloaded_file.size
		data["downloadcompletion"] = round(download_completion, 0.1)

	data["disk_size"] = computer.max_capacity
	data["disk_used"] = computer.used_capacity
	data["emagged"] = (computer.obj_flags & EMAGGED)

	var/list/repo = SSmodular_computers.available_antag_software | SSmodular_computers.available_station_software

	for(var/datum/computer_file/program/programs as anything in repo)
		data["programs"] += list(list(
			"icon" = programs.program_icon,
			"filename" = programs.filename,
			"filedesc" = programs.filedesc,
			"fileinfo" = programs.extended_desc,
			"category" = programs.downloader_category,
			"installed" = !!computer.find_file_by_name(programs.filename),
			"compatible" = check_compatibility(programs),
			"size" = programs.size,
			"access" = programs.can_run(user, downloading = TRUE, access = access),
			"verifiedsource" = !!(programs.program_flags & PROGRAM_ON_NTNET_STORE),
		))

	data["categories"] = show_categories

	return data

///Checks if a provided `program_to_check` is compatible to be downloaded on our computer.
/datum/computer_file/program/ntnetdownload/proc/check_compatibility(datum/computer_file/program/program_to_check)
	if(!program_to_check || !program_to_check.is_supported_by_hardware(hardware_flag = computer.hardware_flag, loud = FALSE))
		return FALSE
	return TRUE
