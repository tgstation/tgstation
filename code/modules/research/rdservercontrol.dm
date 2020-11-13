/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/screen = 0
	var/obj/machinery/rnd/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	req_access = list(ACCESS_RD)
	var/badmin = 0
	circuit = /obj/item/circuitboard/computer/rdservercontrol

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RdServerControl", name)
		ui.open()

/obj/machinery/computer/rdservercontrol/ui_data(mob/user)
	var/list/data = list()

	data["rnd_servers"] = list()
	for(var/obj/machinery/rnd/server/S in SSresearch.servers)
		data["rnd_servers"] += list(S.ui_data())

	data["research_logs"] = SSresearch.science_tech.research_logs

	return data

/obj/machinery/rdservercontrol/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	var/obj/machinery/rnd/server/S = locate(params["rnd_server_ref"]) in GLOB.machines
	switch(action)
		// Toggle power.
		if("rnd_server_power")
			if (!S)
				to_chat(usr, "<span class='warning'>RND Server Control: Unable to find RND Server.</span>")
				return FALSE
			S.set_research_disabled(params["research_disabled"] ? TRUE : FALSE)
			return TRUE

// /obj/machinery/computer/rdservercontrol/ui_interact(mob/user)
// 	. = ..()
// 	var/list/dat = list()

// 	dat += "<b>Connected Servers:</b>"
// 	dat += "<table><tr><td style='width:25%'><b>Server</b></td><td style='width:25%'><b>Operating Temp</b></td><td style='width:25%'><b>Status</b></td>"
// 	for(var/obj/machinery/rnd/server/S in GLOB.machines)
// 		dat += "<tr><td style='width:25%'>[S.name]</td><td style='width:25%'>[S.current_temp]</td><td style='width:25%'>[S.machine_stat & EMPED || machine_stat & NOPOWER?"Offline":"<A href='?src=[REF(src)];toggle=[REF(S)]'>([S.research_disabled? "<font color=red>Disabled" : "<font color=lightgreen>Online"]</font>)</A>"]</td><BR>"
// 	dat += "</table></br>"

// 	dat += "<b>Research Log</b></br>"
// 	var/datum/techweb/stored_research
// 	stored_research = SSresearch.science_tech
// 	if(stored_research.research_logs.len)
// 		dat += "<table BORDER=\"1\">"
// 		dat += "<tr><td><b>Entry</b></td><td><b>Research Name</b></td><td><b>Cost</b></td><td><b>Researcher Name</b></td><td><b>Console Location</b></td></tr>"
// 		for(var/i=stored_research.research_logs.len, i>0, i--)
// 			dat += "<tr><td>[i]</td>"
// 			for(var/j in stored_research.research_logs[i])
// 				dat += "<td>[j]</td>"
// 			dat +="</tr>"
// 		dat += "</table>"

// 	else
// 		dat += "</br>No history found."

// 	var/datum/browser/popup = new(user, "server_com", src.name, 900, 620)
// 	popup.set_content(dat.Join())
// 	popup.open()
