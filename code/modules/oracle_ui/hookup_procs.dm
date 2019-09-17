/// Returns whether the specified user can view the UI at this time.
/datum/proc/oui_canview(mob/user)
	return TRUE

/// Returns the raw HTML to be sent to the specified user. 
/// This proc is not used in the themed subclass of oracle_ui.
/datum/proc/oui_getcontent(mob/user)
	return "Default Implementation"

/// Returns whether the specified user can interact with the UI at this time.
/datum/proc/oui_canuse(mob/user)
	if(isobserver(user) && !user.has_unlimited_silicon_privilege)
		return FALSE
	return oui_canview(user)

/// Returns templating data for the specified user.
/// This proc is only used in the themed subclass of oracle_ui.
/datum/proc/oui_data(mob/user)
	return list()

/// Returns the above, but JSON-encoded and escaped, for copy pasting into the web IDE.
/// This proc is only used for debugging purposes.
/datum/proc/oui_data_debug(mob/user)
	return html_encode(json_encode(oui_data(user)))

/// Called when a hyperlink is clicked in the UI.
/datum/proc/oui_act(mob/user, action, list/params)
	// No Implementation

/atom/oui_canview(mob/user)
	if(isobserver(user))
		return TRUE
	if(user.incapacitated())
		return FALSE
	if(isturf(src.loc) && Adjacent(user))
		return TRUE
	return FALSE

/obj/item/oui_canview(mob/user)
	if(src.loc == user)
		return src in user.held_items
	return ..()

/obj/machinery/oui_canview(mob/user)
	if(user.has_unlimited_silicon_privilege)
		return TRUE
	if(!can_interact())
		return FALSE
	if(iscyborg(user))
		return can_see(user, src, 7)
	if(isAI(user))
		return GLOB.cameranet.checkTurfVis(get_turf_pixel(src))
	return ..()
