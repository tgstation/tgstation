/datum/computer_file/program/newsbrowser
	filename = "newsbrowser"
	filedesc = "NTNet/ExoNet News Browser"
	extended_desc = "This program may be used to view and download news articles from the network."
	program_icon_state = "generic"
	size = 8
	requires_ntnet = 1
	available_on_ntnet = 1

	nanomodule_path = /datum/nano_module/program/computer_newsbrowser/
	var/datum/computer_file/data/news_article/loaded_article
	var/download_progress = 0
	var/download_netspeed = 0
	var/downloading = 0
	var/message = ""

/datum/computer_file/program/newsbrowser/process_tick()
	if(!downloading)
		return
	download_netspeed = 0
	// Speed defines are found in misc.dm
	switch(ntnet_status)
		if(1)
			download_netspeed = NTNETSPEED_LOWSIGNAL
		if(2)
			download_netspeed = NTNETSPEED_HIGHSIGNAL
		if(3)
			download_netspeed = NTNETSPEED_ETHERNET
	download_progress += download_netspeed
	if(download_progress >= loaded_article.size)
		downloading = 0
		requires_ntnet = 0 // Turn off NTNet requirement as we already loaded the file into local memory.
	nanomanager.update_uis(NM)

/datum/computer_file/program/newsbrowser/kill_program()
	..()
	requires_ntnet = 1
	loaded_article = null
	download_progress = 0
	downloading = 0

/datum/computer_file/program/newsbrowser/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["PRG_openarticle"])
		. = 1
		if(downloading || loaded_article)
			return 1

		for(var/datum/computer_file/data/news_article/N in ntnet_global.available_news)
			if(N.uid == text2num(href_list["PRG_openarticle"]))
				loaded_article = N.clone()
				downloading = 1
				break
	if(href_list["PRG_reset"])
		. = 1
		downloading = 0
		download_progress = 0
		requires_ntnet = 1
		loaded_article = null
	if(href_list["PRG_clearmessage"])
		. = 1
		message = ""
	if(href_list["PRG_savearticle"])
		. = 1
		if(downloading || !loaded_article)
			return

		var/savename = sanitize(input(usr, "Enter file name or leave blank to cancel:", "Save article", loaded_article.filename))
		if(!savename)
			return 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/data/news_article/N = loaded_article.clone()
		N.filename = savename
		HDD.store_file(N)
	if(.)
		nanomanager.update_uis(NM)


/datum/nano_module/program/computer_newsbrowser
	name = "NTNet/ExoNet News Browser"

/datum/nano_module/program/computer_newsbrowser/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)

	var/datum/computer_file/program/newsbrowser/PRG
	var/list/data = list()
	if(program)
		data = program.get_header_data()
		PRG = program
	else
		return

	data["message"] = PRG.message
	if(PRG.loaded_article && !PRG.downloading) 	// Viewing an article.
		data["title"] = PRG.loaded_article.filename
		data["article"] = PRG.loaded_article.stored_data
	else if(PRG.downloading)					// Downloading an article.
		data["download_running"] = 1
		data["download_progress"] = PRG.download_progress
		data["download_maxprogress"] = PRG.loaded_article.size
		data["download_rate"] = PRG.download_netspeed
	else										// Viewing list of articles
		var/list/all_articles[0]
		for(var/datum/computer_file/data/news_article/F in ntnet_global.available_news)
			all_articles.Add(list(list(
				"name" = F.filename,
				"size" = F.size,
				"uid" = F.uid
			)))
		data["all_articles"] = all_articles

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "news_browser.tmpl", "NTNet/ExoNet News Browser", 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

