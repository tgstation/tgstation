/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "OOC"
	var/action
	log_tgui(src, "Started fixing.",
		context = "verb/fix_tgui_panel")

	// Catch all solution (kick the whole thing in the pants)
	winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
	winset(src, "browseroutput", "is-disabled=1;is-visible=0")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing",
			context = "verb/fix_tgui_panel")
		tgui_panel = new(src)
	tgui_panel.initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "output", "is-disabled=1&is-visible=0")
	winset(src, "browseroutput", "is-disabled=0;is-visible=1")
	action = alert(src, "Method: Reinitializing the panel.\nWait a bit and tell me if it's fixed", "", "Fixed", "Nope")
	if(action == "Fixed")
		log_tgui(src, "Fixed via nuke and reboot",
			context = "verb/fix_tgui_panel")
		return

	// Failed to fix
	action = alert(src, "Did that work?", "", "No, thanks anyways", "Switch to old UI")
	if (action == "Switch to old UI")
		winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
		winset(src, "browseroutput", "is-disabled=1;is-visible=0")
	log_tgui(src, "Failed to fix.",
		context = "verb/fix_tgui_panel")
