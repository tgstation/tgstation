/**
 * ## Loot panel
 * A datum that stores info containing the contents of a turf.
 * Handles opening the lootpanel UI and searching the turf for items.
 */
/datum/lootpanel
	/// The owner of the panel
	var/client/owner
	/// The list of all search objects indexed.
	var/list/datum/search_object/contents = list()
	/// The list of search_objects needing processed
	var/list/datum/search_object/to_image = list()
	/// We've been notified about client version
	var/notified = FALSE
	/// The turf being searched
	var/turf/source_turf


/datum/lootpanel/New(client/owner)
	. = ..()

	src.owner = owner


/datum/lootpanel/Destroy(force)
	SSlooting.backlog -= src
	SSlooting.processing -= src
	reset_contents()
	owner = null
	source_turf = null

	return ..()


/datum/lootpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LootPanel")
		ui.set_autoupdate(FALSE)
		ui.open()


/datum/lootpanel/ui_host(mob/user)
	return source_turf


/datum/lootpanel/ui_close(mob/user)
	. = ..()

	UnregisterSignal(source_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	source_turf = null
	reset_contents()


/datum/lootpanel/ui_data(mob/user)
	var/list/data = list()

	data["contents"] = get_contents()
	data["searching"] = length(to_image)

	return data


/datum/lootpanel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("grab")
			return grab(usr, params)

	return FALSE

/datum/lootpanel/ui_state(mob/user)
	return GLOB.always_state

/datum/lootpanel/ui_status(mob/user, datum/ui_state/state)
	if(!(user in viewers(source_turf)) || HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING))
		return UI_CLOSE

	if(!(astype(user, /mob/living)?.mobility_flags & (MOBILITY_USE|MOBILITY_PICKUP)))
		return UI_UPDATE

	if(astype(user, /mob/living/carbon/human)?.dna?.check_mutation(/datum/mutation/telekinesis))
		return tkMaxRangeCheck(user, source_turf) ? UI_INTERACTIVE : UI_UPDATE // Range check here is just a formality with the viewers check above.

	if(!source_turf.IsReachableBy(user, user.get_active_held_item()?.reach))
		return (get_dist(user, source_turf) >= 3 && user.is_blind()) ? UI_CLOSE : UI_UPDATE

	return UI_INTERACTIVE
