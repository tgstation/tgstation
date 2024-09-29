ADMIN_VERB(pod_debug_panel, R_ADMIN, "Show Pod Equipment Panel", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, obj/vehicle/sealed/space_pod/pod)
	var/datum/podpanel/podpanel = new(user.mob, pod)
	podpanel.ui_interact(user.mob)

/datum/podpanel
	/// the space pod this panel belongs to
	var/obj/vehicle/sealed/space_pod/pod

/datum/podpanel/New(obj/vehicle/sealed/space_pod/target)
	if(!istype(target))
		qdel(src)
		CRASH("that is not a pod stop that")
	pod = target
	RegisterSignal(pod, COMSIG_QDELETING, PROC_REF(pod_destroyed))

/datum/podpanel/proc/pod_destroyed(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/podpanel/Destroy(force)
	pod = null
	return ..()

/datum/podpanel/ui_state(mob/user)
	return GLOB.admin_state

/datum/podpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PodDebugPanel")
		ui.open()

/datum/podpanel/ui_data(mob/user)
	. = list()
	var/obj/item/stock_parts/power_store/cell = pod.get_cell()
	.["pod"] = list(
		"ref" = REF(pod),
		"name" = pod.name,
		"has_cell" = !isnull(cell),
		"charge" = cell?.charge,
		"maxcharge" = cell?.maxcharge,
	)
	.["parts"] = list()
	for(var/obj/item/pod_equipment/equipment as anything in pod.get_all_parts())
		var/data = list()
		data["slot"] = equipment.slot
		data["name"] = equipment.name
		data["ref"] = REF(equipment)
		.["parts"] += list(data)

/datum/podpanel/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("rename") //idk what this is for VV does this already
			var/wanted_name = tgui_input_text(usr, "Name", "Name", pod.name)
			if(!wanted_name)
				return
			pod.name = wanted_name
		if("set_charge")
			if(isnull(pod.cell))
				return
			var/new_charge = tgui_input_number(usr, "Charge", "Charge", pod.cell.charge, pod.cell.maxcharge)
			pod.cell.charge = new_charge
		if("remove_cell")
			if(isnull(pod.cell))
				return
			QDEL_NULL(pod.cell)
			pod.update_appearance()
		if("change_cell")
			var/wanted_type = tgui_input_list(usr, "What cell", "What cell", subtypesof(/obj/item/stock_parts/power_store/battery))
			if(!istype(wanted_type, /obj/item/stock_parts/power_store/battery))
				return
			QDEL_NULL(pod.cell)
			pod.cell = new wanted_type(pod)
			pod.update_appearance()
		if("add_part")
			var/wanted_type = tgui_input_list(usr, "What part", "What part (Warning, no attachment checks)", subtypesof(/obj/item/pod_equipment))
			if(!istype(wanted_type, /obj/item/pod_equipment))
				return
			pod.equip_item(new wanted_type)
		if("delete_part")
			var/part = locate(params["partRef"])
			if(!istype(part, /obj/item/pod_equipment))
				return
			qdel(part)
		if("detach_part")
			var/part = locate(params["partRef"])
			if(!istype(part, /obj/item/pod_equipment))
				return
			pod.unequip_item(part)
