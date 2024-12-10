/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*8, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 2)
	attachable = TRUE

	var/scanning = FALSE
	var/health_scan
	var/health_target = HEALTH_THRESHOLD_CRIT

/obj/item/assembly/health/examine(mob/user)
	. = ..()
	. += "[src.scanning ? "The sensor is on and you can see [health_scan] displayed on the screen" : "The sensor is off"]."

/obj/item/assembly/health/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(iscarbon(old_loc))
		UnregisterSignal(old_loc, COMSIG_MOB_GET_STATUS_TAB_ITEMS)
	if(iscarbon(loc))
		RegisterSignal(loc, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

/obj/item/assembly/health/activate()
	if(!..())
		return FALSE//Cooldown check
	toggle_scan()
	return TRUE

/obj/item/assembly/health/toggle_secure()
	secured = !secured
	if(secured && scanning)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		STOP_PROCESSING(SSobj, src)
	update_appearance()
	return secured

/obj/item/assembly/health/process()
	//not ready yet
	if(!scanning || !secured)
		return

	//look for a mob in either our location or in the connected holder
	var/atom/object = src
	if(connected?.holder)
		object = connected.holder
	while(!ismob(object))
		object = object.loc
		if(isnull(object)) //we went too far
			return

	//only do the pulse if we are within alarm thresholds
	var/mob/living/target_mob = object
	health_scan = target_mob.health
	if(health_scan > health_target)
		return

	//do the pulse & the scan
	pulse()
	audible_message(span_infoplain("[icon2html(src, hearers(src))] *beep* *beep* *beep*"))
	playsound(src, 'sound/machines/beep/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	toggle_scan()

/obj/item/assembly/health/proc/toggle_scan()
	if(!secured)
		return 0
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	return

/obj/item/assembly/health/proc/toggle_target()
	if(health_target == HEALTH_THRESHOLD_CRIT)
		health_target = HEALTH_THRESHOLD_DEAD
	else
		health_target = HEALTH_THRESHOLD_CRIT
	return

/obj/item/assembly/health/proc/get_status_tab_item(mob/living/carbon/source, list/items)
	SIGNAL_HANDLER
	items += "Health: [round((source.health / source.maxHealth) * 100)]%"


/obj/item/assembly/health/ui_status(mob/user, datum/ui_state/state)
	return is_secured(user) ? ..() : UI_CLOSE

/obj/item/assembly/health/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HealthSensor", name)
		ui.open()

/obj/item/assembly/health/ui_data(mob/user)
	var/list/data = list()
	data["health"] = health_scan
	data["scanning"] = scanning
	data["target"] = health_target
	return data

/obj/item/assembly/health/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	switch(action)
		if("scanning")
			toggle_scan()
			return TRUE
		if("target")
			toggle_target()
			return TRUE
