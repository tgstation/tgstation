/obj/machinery/computer/podtracker
	name = "spacepod tracking console"
	desc = "Used to remotely locate spacepods"
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/circuitboard/computer/pod_tracking

/obj/machinery/computer/podtracker/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "podtracker", name, 600, 900, master_ui, state)
    ui.open()

/obj/machinery/computer/podtracker/ui_data(mob/user)
	var/list/data = list()
	var/list/pods_list = list()

	for(var/obj/vehicle/sealed/spacepod/SP in GLOB.spacepods_list)
		var/obj/item/device/spacepod_equipment/misc/tracker/TE = locate(/obj/item/device/spacepod_equipment/misc/tracker) in SP.equipment
		if(TE && TE.enabled)
			var/list/pod = list()
			pod["name"] = SP.name
			pod["max_integrity"] = SP.max_integrity
			pod["obj_integrity"] = SP.obj_integrity
			var/mob/pilot = SP.get_driver()
			pod["pilot"] = pilot ? pilot.name : "None"
			pod["maxcharge"] = SP.cell.maxcharge
			pod["cellcharge"] = SP.cell.charge
			pods_list += list(pod)
	data["pods"] = pods_list
	return data