/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdservercontrol
	req_access = list(ACCESS_RD)

	///Connected techweb node the server is connected to.
	var/datum/techweb/stored_research

/obj/machinery/computer/rdservercontrol/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link))
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
		data["servers"] = stored_research.techweb_servers
		data["logs"] += stored_research.research_logs
		for(var/obj/machinery/computer/rdconsole/console as anything in stored_research.consoles_accessing)
			data["consoles"] += list(list(
				"console_name" = console,
				"console_location" = get_area(console),
				"console_locked" = console.locked,
			))

	return data

/obj/machinery/computer/rdservercontrol/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE

	switch(action)
		if("changeMode")
			if(!allowed(usr) && !(obj_flags & EMAGGED))
				to_chat(usr, span_danger("Access Denied."))
				return TRUE
			var/obj/machinery/rnd/server/server_selected = locate(params["selected_server"]) in stored_research.techweb_servers
			server_selected.toggle_disable(usr)
			return TRUE

/*
/obj/machinery/computer/rdservercontrol/ui_interact(mob/user)
	. = ..()
	var/list/dat = list()

	dat += "<b>Connected Servers:</b>"
	dat += "<table><tr><td style='width:25%'><b>Server</b></td><td style='width:25%'><b>Status</b></td><td style='width:25%'><b>Control</b></td>"
	for(var/obj/machinery/rnd/server/server as anything in stored_research.techweb_servers)
		var/server_info = ""

		var/status_text = server.get_status_text()
		var/disable_text = server.research_disabled ? "<font color=red>Disabled</font>" : "<font color=lightgreen>Online</font>"

		server_info += "<tr><td style='width:25%'>[server.name]</td>"
		server_info += "<td style='width:25%'>[status_text]</td>"
		server_info += "<td style='width:25%'><a href='?src=[REF(src)];toggle=[REF(server)]'>([disable_text])</a></td><br>"

		dat += server_info

	dat += "</table></br>"

	dat += "<b>Research Log</b></br>"
	if(stored_research && length(stored_research.research_logs))
		dat += "<table BORDER=\"1\">"
		dat += "<tr><td><b>Entry</b></td><td><b>Research Name</b></td><td><b>Cost</b></td><td><b>Researcher Name</b></td><td><b>Console Location</b></td></tr>"
		for(var/i = stored_research.research_logs.len, i>0, i--)
			dat += "<tr><td>[i]</td>"
			for(var/j in stored_research.research_logs[i])
				dat += "<td>[j]</td>"
			dat +="</tr>"
		dat += "</table>"

	else
		dat += "</br>No history found."

	var/datum/browser/popup = new(user, "server_com", src.name, 900, 620)
	popup.set_content(dat.Join())
	popup.open()
*/
