/**
 * tgui subsystem
 *
 * Contains all tgui state and subsystem code.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

SUBSYSTEM_DEF(tgui)
	name = "tgui"
	wait = 9
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_TGUI
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/currentrun = list()
	/// A list of open UIs, grouped by src_object.
	var/list/open_uis = list()
	/// A list of processing UIs, ungrouped.
	var/list/processing_uis = list()
	/// The HTML base used for all UIs.
	var/basehtml
	/// Window counter, which is used for creating sequential window ids.
	var/_window_id_counter = 1

/datum/controller/subsystem/tgui/PreInit()
	basehtml = file2text('tgui/packages/tgui/public/tgui.html')

/datum/controller/subsystem/tgui/Shutdown()
	close_all_uis()

/datum/controller/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]")

/datum/controller/subsystem/tgui/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing_uis.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/tgui/ui = currentrun[currentrun.len]
		currentrun.len--
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis.Remove(ui)
		if (MC_TICK_CHECK)
			return

/**
 * Creates a new, unique window id.
 *
 * return string
 */
/datum/controller/subsystem/tgui/proc/create_window_id()
	return "tgui-window-[_window_id_counter++]"

/**
 * public
 *
 * Try to find an instance of a UI, and push an update to it.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object/datum which owns the UI.
 * optional ui datum/tgui The UI to be updated, if it exists.
 * optional force_open bool If the UI should be re-opened instead of updated.
 *
 * return datum/tgui The found UI.
 */
/datum/controller/subsystem/tgui/proc/try_update_ui(
		mob/user,
		datum/src_object,
		datum/tgui/ui,
		force_open = FALSE)
	// Loop up a UI if it wasn't passed
	if(isnull(ui))
		ui = get_open_ui(user, src_object)
	// Couldn't find a UI.
	if(isnull(ui))
		return null
	var/data = src_object.ui_data(user)
	if(!force_open)
		ui.push_data(data)
	else
		ui.reinitialize(null, data)
	return ui

/**
 * private
 *
 * Get a open UI given a user and src_object.
 *
 * required user mob The mob who opened/is using the UI.
 * required src_object datum The object/datum which owns the UI.
 *
 * return datum/tgui The found UI.
 */
/datum/controller/subsystem/tgui/proc/get_open_ui(mob/user, datum/src_object)
	var/key = "[REF(src_object)]"
	// No UIs opened for this src_object
	if(isnull(open_uis[key]) || !istype(open_uis[key], /list))
		return null
	for(var/datum/tgui/ui in open_uis[key])
		// Make sure we have the right user
		if(ui.user == user)
			return ui
	return null

/**
 * private
 *
 * Update all UIs attached to src_object.
 *
 * required src_object datum The object/datum which owns the UIs.
 *
 * return int The number of UIs updated.
 */
/datum/controller/subsystem/tgui/proc/update_uis(datum/src_object)
	var/count = 0
	var/key = "[REF(src_object)]"
	// No UIs opened for this src_object
	if(isnull(open_uis[key]) || !istype(open_uis[key], /list))
		return count
	for(var/datum/tgui/ui in open_uis[key])
		// Check if UI is valid.
		if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.process(force = 1)
			count++
	return count

/**
 * private
 *
 * Close all UIs attached to src_object.
 *
 * required src_object datum The object/datum which owns the UIs.
 *
 * return int The number of UIs closed.
 */
/datum/controller/subsystem/tgui/proc/close_uis(datum/src_object)
	var/count = 0
	var/key = "[REF(src_object)]"
	// No UIs opened for this src_object
	if(isnull(open_uis[key]) || !istype(open_uis[key], /list))
		return count
	for(var/datum/tgui/ui in open_uis[key])
		// Check if UI is valid.
		if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.close()
			count++
	return count

/**
 * private
 *
 * Close all UIs regardless of their attachment to src_object.
 *
 * return int The number of UIs closed.
 */
/datum/controller/subsystem/tgui/proc/close_all_uis()
	var/count = 0
	for(var/key in open_uis)
		for(var/datum/tgui/ui in open_uis[key])
			// Check if UI is valid.
			if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user))
				ui.close()
				count++
	return count

/**
 * private
 *
 * Update all UIs belonging to a user.
 *
 * required user mob The mob who opened/is using the UI.
 * optional src_object datum If provided, only update UIs belonging this src_object.
 * optional ui_key string If provided, only update UIs with this UI key.
 *
 * return int The number of UIs updated.
 */
/datum/controller/subsystem/tgui/proc/update_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.open_uis) == 0)
		return count
	for(var/datum/tgui/ui in user.open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.process(force = 1)
			count++
	return count

/**
 * private
 *
 * Close all UIs belonging to a user.
 *
 * required user mob The mob who opened/is using the UI.
 * optional src_object datum If provided, only close UIs belonging this src_object.
 * optional ui_key string If provided, only close UIs with this UI key.
 *
 * return int The number of UIs closed.
 */
/datum/controller/subsystem/tgui/proc/close_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.open_uis) == 0)
		return count
	for(var/datum/tgui/ui in user.open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.close()
			count++
	return count

/**
 * private
 *
 * Add a UI to the list of open UIs.
 *
 * required ui datum/tgui The UI to be added.
 */
/datum/controller/subsystem/tgui/proc/on_open(datum/tgui/ui)
	var/key = "[REF(ui.src_object)]"
	// Make a list for the ui_key and src_object.
	if(isnull(open_uis[key]) || !istype(open_uis[key], /list))
		open_uis[key] = list()
	// Append the UI to all the lists.
	ui.user.open_uis |= ui
	var/list/uis = open_uis[key]
	uis |= ui
	processing_uis |= ui

/**
 * private
 *
 * Remove a UI from the list of open UIs.
 *
 * required ui datum/tgui The UI to be removed.
 *
 * return bool If the UI was removed or not.
 */
/datum/controller/subsystem/tgui/proc/on_close(datum/tgui/ui)
	var/key = "[REF(ui.src_object)]"
	if(isnull(open_uis[key]) || !istype(open_uis[key], /list))
		return FALSE
	// Remove it from the list of processing UIs.
	processing_uis.Remove(ui)
	// If the user exists, remove it from them too.
	if(ui.user)
		ui.user.open_uis.Remove(ui)
	var/list/uis = open_uis[key]
	uis.Remove(ui)
	if(length(uis) == 0)
		open_uis.Remove(key)
	return TRUE

/**
 * private
 *
 * Handle client logout, by closing all their UIs.
 *
 * required user mob The mob which logged out.
 *
 * return int The number of UIs closed.
 */
/datum/controller/subsystem/tgui/proc/on_logout(mob/user)
	return close_user_uis(user)

/**
 * private
 *
 * Handle clients switching mobs, by transferring their UIs.
 *
 * required user source The client's original mob.
 * required user target The client's new mob.
 *
 * return bool If the UIs were transferred.
 */
/datum/controller/subsystem/tgui/proc/on_transfer(mob/source, mob/target)
	// The old mob had no open UIs.
	if(length(source?.open_uis) == 0)
		return FALSE
	if(isnull(target.open_uis) || !istype(target.open_uis, /list))
		target.open_uis = list()
	// Transfer all the UIs.
	for(var/datum/tgui/ui in source.open_uis)
		// Inform the UIs of their new owner.
		ui.user = target
		target.open_uis.Add(ui)
	// Clear the old list.
	source.open_uis.Cut()
	return TRUE
