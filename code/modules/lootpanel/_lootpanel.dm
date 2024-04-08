/**
 * ## Loot panel
 * A datum that stores info containing the contents of a turf.
 * Handles opening the lootpanel UI and searching the turf for items.
 */
/datum/lootpanel
	/// The owner of the panel
	var/client/user_client
	/// The turf being searched
	var/datum/weakref/search_turf_ref
	/// Associative list of contents
	var/list/contents = list()
	/// The mob of the owner
	var/mob/user
	/// The speed at which we search, represented as items per tick
	var/search_speed = 20
	/// If we're currently running slow_search_contents
	var/searching = FALSE


/datum/lootpanel/New(client/owner)
	. = ..()

	src.user_client = owner


/datum/lootpanel/Destroy(force)
	stop_search()
	user = null
	user_client = null

	return ..()


/datum/lootpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LootPanel")
		ui.set_autoupdate(FALSE)
		ui.open()


/datum/lootpanel/ui_close(mob/user)
	. = ..()

	stop_search()
		

/datum/lootpanel/ui_data(mob/user)
	var/list/data = list()

	data["contents"] = get_contents()
	data["searching"] = searching
	data["total"] = length(contents)

	return data


/datum/lootpanel/ui_status(mob/user, datum/ui_state/state)
	// var/turf/tile = search_turf_ref?.resolve()
	// if(isnull(tile)) // let's try one more time
	// 	return UI_CLOSE
	
	// if(!user.TurfAdjacent(tile))
	// 	return UI_CLOSE

	if(user.incapacitated())
		return UI_DISABLED

	return UI_INTERACTIVE


/datum/lootpanel/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("grab")
			if(!grab(user, params))
				return FALSE
			return TRUE

		if("refresh")
			if(!searching)
				return FALSE
			if(!start_search())
				return FALSE
			return TRUE

	return FALSE
