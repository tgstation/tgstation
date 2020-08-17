/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_chat()
	set name = "Fix chat"
	set category = "OOC"
	var/action
	log_tgui(src, "tgui_panel: Started fixing.")
	// Not initialized
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel: datum is missing")
		action = alert(src, "tgui panel was not initialized!\nSet it up again?", "", "OK", "Cancel")
		if(action != "OK")
			return
		tgui_panel = new(src)
		tgui_panel.initialize()
		action = alert(src, "Wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if(action == "Fixed")
			log_tgui(src, "tgui_panel: Fixed by calling 'new' + 'initialize'")
			return
	// Not ready
	if(!tgui_panel?.is_ready())
		log_tgui(src, "tgui_panel: not ready")
		action = alert(src, "tgui panel looks like it's waiting for something.\nSend it a ping?", "", "OK", "Cancel")
		if(action != "OK")
			return
		tgui_panel.window.send_message("ping", force = TRUE)
		action = alert(src, "Wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if(action == "Fixed")
			log_tgui(src, "tgui_panel: Fixed by sending a ping")
			return
	// Catch all solution
	action = alert(src, "Looks like tgui panel was already setup, but we can always try again.\nSet it up again?", "", "OK", "Cancel")
	if(action != "OK")
		return
	tgui_panel.initialize(force = TRUE)
	action = alert(src, "Wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
	if(action == "Fixed")
		log_tgui(src, "tgui_panel: Fixed by calling 'initialize'")
		return
	// Failed to fix
	action = alert(src, "Welp, I'm all out of ideas. Try closing BYOND and reconnecting.\nWe could also disable tgui_panel and re-enable the old UI", "", "Thanks anyways", "Switch to old UI")
	if (action == "Switch to old UI")
		winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
		winset(src, "browseroutput", "is-disabled=1;is-visible=0")
	log_tgui(src, "tgui_panel: Failed to fix.")
