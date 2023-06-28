
/**
 * ## Portrait picker!!
 *
 * It's a tgui window that lets you look through all the portraits, and choose one as your AI.
 * very similar to centcom_podlauncher in terms of how this is coded, so i kept a lot of comments from it
 */
/datum/portrait_picker
	/// Client of whoever is using this datum
	var/client/holder
	/// The last input in the search tab.
	var/search_string
	/// Whether the search function will check the title of the painting or the author's name.
	var/search_mode = PAINTINGS_FILTER_SEARCH_TITLE
	/// Stores the result of the search.
	var/list/matching_paintings

/datum/portrait_picker/New(user)//user can either be a client or a mob due to byondcode(tm)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder

/datum/portrait_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortraitPicker")
		ui.open()

/datum/portrait_picker/ui_close()
	qdel(src)

/datum/portrait_picker/ui_state(mob/user)
	return GLOB.conscious_state

/datum/portrait_picker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/portraits)
	)

/datum/portrait_picker/ui_data(mob/user)
	var/list/data = list()
	data["paintings"] = matching_paintings || SSpersistent_paintings.painting_ui_data(filter = PAINTINGS_FILTER_AI_PORTRAIT)
	data["search_string"] = search_string
	data["search_mode"] = search_mode == PAINTINGS_FILTER_SEARCH_TITLE ? "Title" : "Author"
	return data

/datum/portrait_picker/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isAI(holder.mob))
		qdel(src)
		return
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
		if("select")
			//var/list/tab2key = list(TAB_LIBRARY = "library", TAB_SECURE = "library_secure", TAB_PRIVATE = "library_private")
			//var/folder = tab2key[params["tab"]]
			//var/list/current_list = SSpersistent_paintings.paintings[folder]
			var/datum/painting/chosen_portrait = locate(params["selected"]) in SSpersistent_paintings.paintings
			if(!chosen_portrait)
				return
			var/png = "data/paintings/images/[chosen_portrait.md5].png"
			var/icon/portrait_icon = new(png)
			var/mob/living/ai = holder.mob
			var/w = portrait_icon.Width()
			var/h = portrait_icon.Height()
			var/mutable_appearance/MA = mutable_appearance(portrait_icon)
			if(w == 23 || h == 23)
				to_chat(ai, span_notice("Small note: 23x23 Portraits are accepted, but they do not fit perfectly inside the display frame."))
				MA.pixel_x = 5
				MA.pixel_z = 5
			else if(w == 24 || h == 24)
				to_chat(ai, span_notice("Portrait Accepted. Enjoy!"))
				MA.pixel_x = 4
				MA.pixel_z = 4
			else
				to_chat(ai, span_warning("Sorry, only 23x23 and 24x24 Portraits are accepted."))
				return
			ai.cut_overlays() //so people can't keep repeatedly select portraits to add stacking overlays
			ai.icon_state = "ai-portrait-active"//background
			ai.add_overlay(MA)

/datum/portrait_picker/proc/generate_matching_paintings_list()
	matching_paintings = null
	if(!search_string)
		return
	matching_paintings = SSpersistent_paintings.painting_ui_data(filter = PAINTINGS_FILTER_AI_PORTRAIT|search_mode, search_text = search_string)
