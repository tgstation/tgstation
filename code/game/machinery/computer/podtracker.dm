/obj/machinery/computer/podtracker
	name = "spacepod tracking console"
	desc = "Used to remotely locate spacepods"
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/circuitboard/computer/mecha_control
	var/list/located = list()
	var/screen = 0
	var/stored_data

/*
/obj/machinery/computer/podtracker/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<html><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
	if(screen == 0)
		dat += "<h3>Tracking beacons data</h3>"
		for(var/obj/spacepod/SP in GLOB.spacepods_list)
			if(istype(SP.equipment_system.misc_system, /obj/item/device/spacepod_equipment/misc/tracker))
				var/obj/item/device/spacepod_equipment/misc/tracker/TR = SP.equipment_system.misc_system
				var/answer = TR.get_pod_info()
				if (answer)
					dat += "{<hr>[answer]<br/>}"

	if(screen==1)
		dat += "<h3>Log contents</h3>"
		dat += "<a href='?src=\ref[src];return=1'>Return</a><hr>"
		dat += "[stored_data]"

	dat += "<A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR>"
	dat += "</body></html>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/podtracker/Topic(href, href_list)
	if(..())
		return
	if(href_list["return"])
		screen = 0
	updateUsrDialog()
	return
*/

/obj/machinery/computer/podtracker/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "podtracker", name, 600, 900, master_ui, state)
    ui.open()

/obj/machinery/computer/podtracker/ui_data(mob/user)
	var/list/data = list()
	data["pods"] = list()
	for(var/obj/spacepod/SP in GLOB.spacepods_list)
		if(istype(SP.equipment_system.misc_system, /obj/item/device/spacepod_equipment/misc/tracker))
			world << "START DEBUG"
			world << "max_integrity: [SP.max_integrity]"
			world << "obj_integrity: [SP.obj_integrity]"
			world << "name: [SP.name]"
			world << "pilot: [SP.pilot.name]"
			world << "maxcharge: [SP.cell.maxcharge]"
			world << "cellcharge: [SP.cell.charge]"
			world << "END DEBUG"
			data["pods"] += list(list("max_integrity" = SP.max_integrity, "obj_integrity" = SP.obj_integrity, "name" = SP.name, "pilot" = SP.pilot ? SP.pilot.name : "None", "maxcharge" = SP.cell.maxcharge, "cellcharge" = SP.cell.charge))
 	return data