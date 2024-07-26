// credits to interception for UI
/datum/action/vehicle/sealed/pod_status
	name = "Control Panel"
	desc = "See an overview of the pod."
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/pod_status/Trigger(trigger_flags)
	. = ..()
	vehicle_entered_target.ui_interact(owner)

/obj/vehicle/sealed/space_pod/ui_data(mob/user)
	. = list()
	.["name"] = name
	.["power"] = isnull(cell) ? 0 : cell.charge
	.["maxPower"] = isnull(cell) ? 0 : cell.maxcharge
	.["health"] = get_integrity_percentage()
	.["acceleration"] = !isnull(drift_handler) ? drift_handler.drift_force : 0
	.["maxAcceleration"] = max_speed
	.["headlightsEnabled"] = light_on
	.["cabinPressure"] = !isnull(cabin_air_tank) ? "[cabin_air.return_pressure()]kPa" : "No air tank"
	.["partUIData"] = list()
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		if(!equipment.interface_id)
			continue
		.["partUIData"][equipment.interface_id] = equipment.ui_data(user)

/obj/vehicle/sealed/space_pod/ui_static_data(mob/user)
	. = list()
	.["parts"] = list()
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		var/list/info = list()
		info["name"] = equipment.name
		info["desc"] = equipment.desc //todo maybe use examine?
		info["type"] = equipment.interface_id
		.["parts"] += list(info)

/obj/vehicle/sealed/space_pod/ui_status(mob/living/user, datum/ui_state/state)
	if(isnull(occupants[user]) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		return UI_CLOSE
	return user.stat < HARD_CRIT ? UI_INTERACTIVE : UI_UPDATE

/obj/vehicle/sealed/space_pod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, null)
	if(!ui)
		ui = new(user, src, "Pod")
		ui.open()

/obj/vehicle/sealed/space_pod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/id = params["partID"]
	if(!isnull(id))
		var/result
		for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
			if(equipment.interface_id != id)
				continue
			result = equipment.ui_act(action, params, ui, state)
		if(result)
			return result

	switch (action)
		if ("toggle-headlights")
			set_light_on(!light_on)
			update_appearance()
			playsound(loc, light_on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, TRUE)
			return TRUE
		if ("change-name")
			if(is_ic_filtered_for_pdas(params["newName"]))
				return
			name = strip_html(params["newName"], limit = MAX_NAME_LEN)

