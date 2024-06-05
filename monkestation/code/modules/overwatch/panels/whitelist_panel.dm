/datum/overwatch_wl_panel
	var/client/holder // client of who is holding this

/datum/overwatch_wl_panel/New(user)
	if(user)
		setup(user)
	else
		qdel(src)
		return

/datum/overwatch_wl_panel/proc/setup(user) // client or mob
	if(!SSdbcore.Connect())
		to_chat(holder, span_warning("Failed to establish database connection"))
		qdel(src)
		return

	if(istype(user, /client))
		var/client/user_client = user
		holder = user_client
	else
		var/mob/user_mob = user
		holder = user_mob.client

	if(!check_rights(R_BAN, TRUE, holder))
		qdel(src)
		return

	ui_interact(holder.mob)

/datum/overwatch_wl_panel/ui_state(mob/user)
	return GLOB.admin_state // admin only

/datum/overwatch_wl_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OverwatchWhitelistPanel")
		ui.open()

/datum/overwatch_wl_panel/ui_data(mob/user)
	. = SSoverwatch.tgui_panel_wl_data

/datum/overwatch_wl_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("wl_remove_entry")
			if(!params["ckey"])
				return TRUE
			if(SSoverwatch.RemoveFromWhitelist(params["ckey"], holder))
				SStgui.update_uis(src)
			else
				return TRUE
		if("wl_add_ckey")
			if(!params["ckey"])
				return TRUE
			if(SSoverwatch.AddToWhitelist(params["ckey"], holder))
				SStgui.update_uis(src)
			else
				return TRUE

	if(!length(SSoverwatch.tgui_panel_wl_data))
		qdel(src) //Same as ASN. ~Tsuru
		return

	SStgui.update_user_uis(holder.mob)
	return TRUE

/datum/overwatch_wl_panel/ui_close(mob/user)
	qdel(src)
