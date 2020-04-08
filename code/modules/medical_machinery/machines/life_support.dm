
/obj/machinery/medical/life_support
	name = "Basic Life Support Unit"
	desc = "A bulky table with a lot of blinking lights installed and a small monitor that checks the users health."
	icon = 'icons/obj/machines/life_support.dmi'
	icon_state = "basic"
	circuit = /obj/item/circuitboard/machine/life_support
	idle_power_usage = 100
	active_power_usage = 500
	///Maximum damage someone can have and still live while hooked up
	var/health_treshold = -200
	///Determines if this is active or not.
	var/active = TRUE

/obj/machinery/medical/life_support/update_overlays()
	. = ..()
	var/mutable_appearance/monitor_overlay
	if(machine_stat && (NOPOWER|BROKEN))
		monitor_overlay = mutable_appearance(icon,"nopower")
		. += monitor_overlay
		return

	if(!attached || !active)
		monitor_overlay=  mutable_appearance(icon,"noone")
		. += monitor_overlay
		return

	switch(attached.health)
		if(-INFINITY to HEALTH_THRESHOLD_DEAD)
			monitor_overlay= mutable_appearance(icon,"death")
		if(HEALTH_THRESHOLD_DEAD+1 to HEALTH_THRESHOLD_FULLCRIT)
			monitor_overlay= mutable_appearance(icon,"hardcrit")
		if(HEALTH_THRESHOLD_FULLCRIT+1 to HEALTH_THRESHOLD_CRIT)
			monitor_overlay= mutable_appearance(icon,"softcrit")
		if(1 to INFINITY)
			monitor_overlay= mutable_appearance(icon,"alive")
	. += monitor_overlay


/obj/machinery/medical/life_support/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	active = anchored
	return

/obj/machinery/medical/life_support/clear_status()
	. = ..()
	attached.remove_status_effect(STATUS_EFFECT_LIFE_SUPPORT, STASIS_MACHINE_EFFECT)
	attached.update_stat()

/obj/machinery/medical/life_support/process()
	. = ..()
	if(attached.health < health_treshold)
		clear_status()
		update_overlays()
		update_icon()
		return
	attached.apply_status_effect(STATUS_EFFECT_LIFE_SUPPORT, STASIS_MACHINE_EFFECT)
	attached.update_stat()
	return

/obj/machinery/medical/life_support/advanced
	name = "Advanced Life Support Unit"
	desc = "A miracle of space engineering, this machine allows you to indefinitely suspend someone in a stasis like state, but uses up massive amounts of electricity to do so."
	icon_state = "advanced"
	circuit = /obj/item/circuitboard/machine/life_support/advanced
	idle_power_usage = 250
	active_power_usage = 1000
	fair_market_price = 50
	health_treshold = -1000

/obj/machinery/medical/life_support/mobile
	name = "Mobile Life Support Unit"
	desc = "A miracle of space engineering, allows you to suspend someone in a coma-like state, wherever you go!"
	icon_state = "mobile"
	circuit = /obj/item/circuitboard/machine/life_support/mobile
	idle_power_usage = 50
	active_power_usage = 200
	anchored = FALSE

/obj/machinery/medical/life_support/mobile/wrench_act(mob/living/user, obj/item/I) //unewrenchable
	return
