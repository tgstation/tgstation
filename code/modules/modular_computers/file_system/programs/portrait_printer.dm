/**
 * ## the art gallery viewer/printer!
 *
 * Program that lets the curator (or anyone really) browse all of the portraits in the database
 * Stationary consoles can also print them out as they please as long as they've enough paper
 */
/datum/computer_file/program/portrait_printer
	filename = "PortraitPrinter"
	filedesc = "Marlowe Treeby's Art Galaxy"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	program_open_overlay = "dummy"
	extended_desc = "This program connects to a Spinward Sector community art site for viewing and printing art, the latter only available on stationary consoles."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	size = 9
	tgui_id = "NtosPortraitPrinter"
	program_icon = "paint-brush"
	/**
	* The last input in the search tab, stored here and reused in the UI to show successive users if
	* the current list of paintings is limited to the results of a search or not.
	*/
	var/search_string
	/// Whether the search function will check the title of the painting or the author's name.
	var/search_mode = PAINTINGS_FILTER_SEARCH_TITLE
	/// Stores the result of the search, for later access.
	var/list/matching_paintings

/datum/computer_file/program/portrait_printer/ui_static_data(mob/user)
	. = ..()
	.["is_console"] = computer.hardware_flag & PROGRAM_CONSOLE

/datum/computer_file/program/portrait_printer/ui_data(mob/user)
	var/list/data = list()
	data["paintings"] = matching_paintings || SSpersistent_paintings.painting_ui_data()
	data["search_string"] = search_string
	data["search_mode"] = search_mode == PAINTINGS_FILTER_SEARCH_TITLE ? "Title" : "Author"
	return data

/datum/computer_file/program/portrait_printer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/portraits)
	)

/datum/computer_file/program/portrait_printer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("search")
			if(search_string != params["to_search"])
				search_string = params["to_search"]
				generate_matching_paintings_list()
			. = TRUE
		if("change_search_mode")
			search_mode = search_mode == PAINTINGS_FILTER_SEARCH_TITLE ? PAINTINGS_FILTER_SEARCH_CREATOR : PAINTINGS_FILTER_SEARCH_TITLE
			generate_matching_paintings_list()
			. = TRUE
		if("print")
			print_painting(params["selected"])
		if("download")
			download_painting(params["selected"])

/datum/computer_file/program/portrait_printer/proc/generate_matching_paintings_list()
	matching_paintings = null
	if(!search_string)
		return
	matching_paintings = SSpersistent_paintings.painting_ui_data(filter = search_mode, search_text = search_string)

/datum/computer_file/program/portrait_printer/proc/print_painting(selected_painting)
	if(!(computer.hardware_flag & PROGRAM_CONSOLE))
		return
	if(computer.stored_paper < CANVAS_PAPER_COST)
		to_chat(usr, span_notice("Printing error: Your printer needs at least [CANVAS_PAPER_COST] paper to print a canvas."))
		return
	computer.stored_paper -= CANVAS_PAPER_COST

	//canvas printing!
	var/datum/painting/chosen_portrait = locate(selected_painting) in SSpersistent_paintings.paintings

	chosen_portrait.spawn_canvas(get_turf(computer.physical))
	to_chat(usr, span_notice("You have printed [chosen_portrait.title] onto a new canvas."))
	playsound(computer.physical, 'sound/machines/printer.ogg', 100, TRUE)

/datum/computer_file/program/portrait_printer/proc/download_painting(selected_painting)
	var/datum/painting/chosen_portrait = locate(selected_painting) in SSpersistent_paintings.paintings
	var/icon/portrait_icon = chosen_portrait.get_icon()
	var/datum/computer_file/image/image_file = new(portrait_icon, display_name = chosen_portrait.title, source_photo_or_painting = chosen_portrait)
	if(!computer.store_file(image_file, usr))
		to_chat(usr, span_notice("Unable to download [chosen_portrait.title].[/datum/computer_file/image::filetype]."))
		return
	to_chat(usr, span_notice("Downloaded [chosen_portrait.title].[/datum/computer_file/image::filetype]."))
