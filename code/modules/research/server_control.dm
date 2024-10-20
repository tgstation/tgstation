/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Manages access to research databases and consoles."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdservercontrol
	req_access = list(ACCESS_RD)

	///Connected techweb node the server is connected to.
	var/datum/techweb/stored_research

/obj/machinery/computer/rdservercontrol/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)

/obj/machinery/computer/rdservercontrol/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		stored_research = tool.buffer
		balloon_alert(user, "techweb connected")
	return TRUE

/obj/machinery/computer/rdservercontrol/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	create_sound(src, SFX_SPARKS).volume(75).vary(TRUE).extra_range(SHORT_RANGE_SOUND_EXTRARANGE).play()
	balloon_alert(user, "console emagged")
	return TRUE

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ServerControl", name)
		ui.open()

/obj/machinery/computer/rdservercontrol/ui_data(mob/user)
	var/list/data = list()

	data["server_connected"] = !!stored_research

	if(stored_research)
		data["logs"] += stored_research.research_logs

		for(var/obj/machinery/rnd/server/server as anything in stored_research.techweb_servers)
			data["servers"] += list(list(
				"server_name" = server,
				"server_details" = server.get_status_text(),
				"server_disabled" = server.research_disabled,
				"server_ref" = REF(server),
			))

		for(var/obj/machinery/computer/rdconsole/console as anything in stored_research.consoles_accessing)
			data["consoles"] += list(list(
				"console_name" = console,
				"console_location" = get_area(console),
				"console_locked" = console.locked,
				"console_ref" = REF(console),
			))

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE
	if(!allowed(usr) && !(obj_flags & EMAGGED))
		balloon_alert(usr, "access denied!")
		create_sound(src, 'sound/machines/click.ogg').volume(20).vary(TRUE).play()
		return TRUE

	switch(action)
		if("lockdown_server")
			var/obj/machinery/rnd/server/server_selected = locate(params["selected_server"]) in stored_research.techweb_servers
			if(!server_selected)
				return FALSE
			server_selected.toggle_disable(usr)
			return TRUE
		if("lock_console")
			var/obj/machinery/computer/rdconsole/console_selected = locate(params["selected_console"]) in stored_research.consoles_accessing
			if(!console_selected)
				return FALSE
			console_selected.locked = !console_selected.locked
			return TRUE
