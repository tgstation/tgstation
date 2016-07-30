var/global/nttransfer_uid = 0

/datum/computer_file/program/nttransfer
	filename = "nttransfer"
	filedesc = "NTNet P2P Transfer Client"
	extended_desc = "This program allows for simple file transfer via direct peer to peer connection."
	program_icon_state = "comm_logs"
	size = 7
	requires_ntnet = 1
	requires_ntnet_feature = NTNET_PEERTOPEER
	network_destination = "other device via P2P tunnel"
	available_on_ntnet = 1
	nanomodule_path = /datum/nano_module/program/computer_nttransfer/

	var/error = ""										// Error screen
	var/server_password = ""							// Optional password to download the file.
	var/datum/computer_file/provided_file = null		// File which is provided to clients.
	var/datum/computer_file/downloaded_file = null		// File which is being downloaded
	var/list/connected_clients = list()					// List of connected clients.
	var/datum/computer_file/program/nttransfer/remote	// Client var, specifies who are we downloading from.
	var/download_completion = 0							// Download progress in GQ
	var/download_netspeed = 0							// Our connectivity speed in GQ/s
	var/actual_netspeed = 0								// Displayed in the UI, this is the actual transfer speed.
	var/unique_token 									// UID of this program
	var/upload_menu = 0									// Whether we show the program list and upload menu

/datum/computer_file/program/nttransfer/New()
	unique_token = nttransfer_uid
	nttransfer_uid++
	..()

/datum/computer_file/program/nttransfer/process_tick()
	// Server mode
	update_netspeed()
	if(provided_file)
		for(var/datum/computer_file/program/nttransfer/C in connected_clients)
			// Transfer speed is limited by device which uses slower connectivity.
			// We can have multiple clients downloading at same time, but let's assume we use some sort of multicast transfer
			// so they can all run on same speed.
			C.actual_netspeed = min(C.download_netspeed, download_netspeed)
			C.download_completion += C.actual_netspeed
			if(C.download_completion >= provided_file.size)
				C.finish_download()
	else if(downloaded_file) // Client mode
		if(!remote)
			crash_download("Connection to remote server lost")

/datum/computer_file/program/nttransfer/kill_program(var/forced = 0)
	if(downloaded_file) // Client mode, clean up variables for next use
		finalize_download()

	if(provided_file) // Server mode, disconnect all clients
		for(var/datum/computer_file/program/nttransfer/P in connected_clients)
			P.crash_download("Connection terminated by remote server")
		downloaded_file = null
	..(forced)



/datum/computer_file/program/nttransfer/proc/update_netspeed()
	download_netspeed = 0
	switch(ntnet_status)
		if(1)
			download_netspeed = NTNETSPEED_LOWSIGNAL
		if(2)
			download_netspeed = NTNETSPEED_HIGHSIGNAL
		if(3)
			download_netspeed = NTNETSPEED_ETHERNET

// Finishes download and attempts to store the file on HDD
/datum/computer_file/program/nttransfer/proc/finish_download()
	if(!computer || !computer.hard_drive || !computer.hard_drive.store_file(downloaded_file))
		error = "I/O Error:  Unable to save file. Check your hard drive and try again."
	finalize_download()

//  Crashes the download and displays specific error message
/datum/computer_file/program/nttransfer/proc/crash_download(var/message)
	error = message ? message : "An unknown error has occured during download"
	finalize_download()

// Cleans up variables for next use
/datum/computer_file/program/nttransfer/proc/finalize_download()
	if(remote)
		remote.connected_clients.Remove(src)
	downloaded_file = null
	remote = null
	download_completion = 0


/datum/nano_module/program/computer_nttransfer
	name = "NTNet P2P Transfer Client"

/datum/nano_module/program/computer_nttransfer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	if(!program)
		return
	var/datum/computer_file/program/nttransfer/PRG = program
	if(!istype(PRG))
		return

	var/list/data = program.get_header_data()

	if(PRG.error)
		data["error"] = PRG.error
	else if(PRG.downloaded_file)
		data["downloading"] = 1
		data["download_size"] = PRG.downloaded_file.size
		data["download_progress"] = PRG.download_completion
		data["download_netspeed"] = PRG.actual_netspeed
		data["download_name"] = "[PRG.downloaded_file.filename].[PRG.downloaded_file.filetype]"
	else if (PRG.provided_file)
		data["uploading"] = 1
		data["upload_uid"] = PRG.unique_token
		data["upload_clients"] = PRG.connected_clients.len
		data["upload_haspassword"] = PRG.server_password ? 1 : 0
		data["upload_filename"] = "[PRG.provided_file.filename].[PRG.provided_file.filetype]"
	else if (PRG.upload_menu)
		var/list/all_files[0]
		for(var/datum/computer_file/F in PRG.computer.hard_drive.stored_files)
			all_files.Add(list(list(
			"uid" = F.uid,
			"filename" = "[F.filename].[F.filetype]",
			"size" = F.size
			)))
		data["upload_filelist"] = all_files
	else
		var/list/all_servers[0]
		for(var/datum/computer_file/program/nttransfer/P in ntnet_global.fileservers)
			all_servers.Add(list(list(
			"uid" = P.unique_token,
			"filename" = "[P.provided_file.filename].[P.provided_file.filetype]",
			"size" = P.provided_file.size,
			"haspassword" = P.server_password ? 1 : 0
			)))
		data["servers"] = all_servers

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "ntnet_transfer.tmpl", "NTNet P2P Transfer Client", 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/computer_file/program/nttransfer/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["PRG_downloadfile"])
		for(var/datum/computer_file/program/nttransfer/P in ntnet_global.fileservers)
			if("[P.unique_token]" == href_list["PRG_downloadfile"])
				remote = P
				break
		if(!remote || !remote.provided_file)
			return
		if(remote.server_password)
			var/pass = sanitize(input(usr, "Code 401 Unauthorized. Please enter password:", "Password required"))
			if(pass != remote.server_password)
				error = "Incorrect Password"
				return
		downloaded_file = remote.provided_file.clone()
		remote.connected_clients.Add(src)
		return 1
	if(href_list["PRG_reset"])
		error = ""
		upload_menu = 0
		finalize_download()
		if(src in ntnet_global.fileservers)
			ntnet_global.fileservers.Remove(src)
		for(var/datum/computer_file/program/nttransfer/T in connected_clients)
			T.crash_download("Remote server has forcibly closed the connection")
		provided_file = null
		return 1
	if(href_list["PRG_setpassword"])
		var/pass = sanitize(input(usr, "Enter new server password. Leave blank to cancel, input 'none' to disable password.", "Server security", "none"))
		if(!pass)
			return
		if(pass == "none")
			server_password = ""
			return
		server_password = pass
		return 1
	if(href_list["PRG_uploadfile"])
		for(var/datum/computer_file/F in computer.hard_drive.stored_files)
			if("[F.uid]" == href_list["PRG_uploadfile"])
				if(F.unsendable)
					error = "I/O Error: File locked."
					return
				provided_file = F
				ntnet_global.fileservers.Add(src)
				return
		error = "I/O Error: Unable to locate file on hard drive."
		return 1
	if(href_list["PRG_uploadmenu"])
		upload_menu = 1
	return 0
