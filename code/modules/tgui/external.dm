/**
 * tgui external
 *
 * Contains all external tgui declarations.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * public
 *
 * Used to open and update UIs.
 * If this proc is not implemented properly, the UI will not update correctly.
 *
 * required user mob The mob who opened/is using the UI.
 * optional ui datum/tgui The UI to be updated, if it exists.
 */
/datum/proc/ui_interact(mob/user, datum/tgui/ui)
	return FALSE // Not implemented.

/**
 * public
 *
 * Data to be sent to the UI.
 * This must be implemented for a UI to work.
 *
 * required user mob The mob interacting with the UI.
 *
 * return list Data to be sent to the UI.
 */
/datum/proc/ui_data(mob/user)
	return list() // Not implemented.

/**
 * public
 *
 * Static Data to be sent to the UI.
 *
 * Static data differs from normal data in that it's large data that should be
 * sent infrequently. This is implemented optionally for heavy uis that would
 * be sending a lot of redundant data frequently. Gets squished into one
 * object on the frontend side, but the static part is cached.
 *
 * required user mob The mob interacting with the UI.
 *
 * return list Statuic Data to be sent to the UI.
 */
/datum/proc/ui_static_data(mob/user)
	return list()

/**
 * public
 *
 * Forces an update on static data. Should be done manually whenever something
 * happens to change static data.
 *
 * required user the mob currently interacting with the ui
 * optional ui ui to be updated
 */
/datum/proc/update_static_data(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	// If there was no ui to update, there's no static data to update either.
	if(!ui)
		return
	ui.push_data(null, ui_static_data(), TRUE)

/**
 * public
 *
 * Called on a UI when the UI receieves a href.
 * Think of this as Topic().
 *
 * required action string The action/button that has been invoked by the user.
 * required params list A list of parameters attached to the button.
 *
 * return bool If the UI should be updated or not.
 */
/datum/proc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// If UI is not interactive or usr calling Topic is not the UI user, bail.
	if(!ui || ui.status != UI_INTERACTIVE)
		return 1

/**
 * public
 *
 * Called on an object when a tgui object is being created, allowing you to
 * push various assets to tgui, for examples spritesheets.
 *
 * return list List of asset datums or file paths.
 */
/datum/proc/ui_assets(mob/user)
	return list()

/**
 * private
 *
 * The UI's host object (usually src_object).
 * This allows modules/datums to have the UI attached to them,
 * and be a part of another object.
 */
/datum/proc/ui_host(mob/user)
	return src // Default src.

/**
 * private
 *
 * The UI's state controller to be used for created uis
 * This is a proc over a var for memory reasons
 */
/datum/proc/ui_state()
	return GLOB.default_state

/**
 * global
 *
 * Associative list of JSON-encoded shared states that were set by
 * tgui clients.
 */
/datum/var/list/tgui_shared_states

/**
 * global
 *
 * Used to track UIs for a mob.
 */
/mob/var/list/open_uis = list()

/**
 * public
 *
 * Called on a UI's object when the UI is closed, not to be confused with
 * client/verb/uiclose(), which closes the ui window
 */
/datum/proc/ui_close(mob/user)

/**
 * Stack of window ids that are free to be recycled into
 */
/client/var/list/tgui_free_windows = list()

/**
 * verb
 *
 * Called by UIs when they are closed.
 * Must be a verb so winset() can call it.
 *
 * required uiref ref The UI that was closed.
 */
/client/verb/uiclose(ref as text)
	// Name the verb, and hide it from the user panel.
	set name = "uiclose"
	set hidden = 1
	// Get the UI based on the ref.
	var/datum/tgui/ui = locate(ref)
	// If we found the UI, close it.
	if(istype(ui))
		ui.close(FALSE)
		// Unset machine just to be sure.
		if(src && src.mob)
			src.mob.unset_machine()

/**
 * Middleware for /client/Topic. This proc allows processing topic calls
 * before they reach /datum/tgui.
 *
 * return bool Whether the topic is passed (TRUE), or cancelled (FALSE).
 */
/proc/tgui_Topic(href, href_list, hsrc)
	// Process tgui logs
	if(href_list["action"] == "tgui:log")
		var/message = href_list["message"]
		log_tgui("[usr] ([usr.ckey]):\n[message]")
	// Destroy windows that cannot be suspended due to disconnects
	if(href_list["action"] == "tgui:close")
		var/src_object = locate(href_list["src"])
		if(!istype(src_object, /datum/tgui))
			var/window_id = href_list["window_id"]
			log_tgui("[usr] ([usr.ckey]):\nForce closing '[window_id].'")
			usr << browse(null, "window=[window_id]")
			return FALSE
	// Pass
	return TRUE
