/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*8, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 2)
	attachable = TRUE

	var/scanning = FALSE
	var/health_scan
	var/alarm_health = HEALTH_THRESHOLD_CRIT

/obj/item/assembly/health/examine(mob/user)
	. = ..()
	. += "Use it in hand to turn it off/on and Alt-click to swap between \"detect death\" mode and \"detect critical state\" mode."
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

/obj/item/assembly/health/AltClick(mob/living/user)
	if(alarm_health == HEALTH_THRESHOLD_CRIT)
		alarm_health = HEALTH_THRESHOLD_DEAD
		to_chat(user, span_notice("You toggle [src] to \"detect death\" mode."))
	else
		alarm_health = HEALTH_THRESHOLD_CRIT
		to_chat(user, span_notice("You toggle [src] to \"detect critical state\" mode."))

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
	if(health_scan > alarm_health)
		return

	//do the pulse & the scan
	pulse()
	audible_message("<span class='infoplain'>[icon2html(src, hearers(src))] *beep* *beep* *beep*</span>")
	playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
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

/obj/item/assembly/health/attack_self(mob/user)
	. = ..()
	if (secured)
		balloon_alert(user, "scanning [scanning ? "disabled" : "enabled"]")
	else
		balloon_alert(user, "secure it first!")
	toggle_scan()

/obj/item/assembly/health/proc/get_status_tab_item(mob/living/carbon/source, list/items)
	SIGNAL_HANDLER
	items += "Health: [round((source.health / source.maxHealth) * 100)]%"
