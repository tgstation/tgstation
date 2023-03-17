/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Manages access to research databases and consoles."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdservercontrol
	req_access = list(ACCESS_RD)

	///Connected techweb node the server is connected to.
	var/datum/techweb/stored_research

/obj/machinery/computer/rdservercontrol/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		stored_research = SSresearch.science_tech

/obj/machinery/computer/rdservercontrol/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		stored_research = tool.buffer
		balloon_alert(user, "techweb connected")
	return TRUE

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "console emagged")

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

/obj/machinery/computer/rdservercontrol/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	if(!allowed(usr) && !(obj_flags & EMAGGED))
		balloon_alert(usr, "access denied!")
		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
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
