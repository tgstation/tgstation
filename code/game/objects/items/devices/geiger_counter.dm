/obj/item/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "\improper Geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon = 'icons/obj/device.dmi'
	icon_state = "geiger_off"
	inhand_icon_state = "multitool"
	worn_icon_state = "geiger_counter"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	atom_size = ITEM_SIZE_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	custom_materials = list(/datum/material/iron = 150, /datum/material/glass = 150)

	var/last_perceived_radiation_danger = null

	var/scanning = FALSE

/obj/item/geiger_counter/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_IN_RANGE_OF_IRRADIATION, .proc/on_pre_potential_irradiation)

/obj/item/geiger_counter/examine(mob/user)
	. = ..()
	if(!scanning)
		return
	. += span_info("Alt-click it to clear stored radiation levels.")
	switch(last_perceived_radiation_danger)
		if(null)
			. += span_notice("Ambient radiation level count reports that all is well.")
		if(PERCEIVED_RADIATION_DANGER_LOW)
			. += span_alert("Ambient radiation levels slightly above average.")
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			. += span_warning("Ambient radiation levels above average.")
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			. += span_danger("Ambient radiation levels highly above average.")
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			. += span_suicide("Ambient radiation levels reaching critical level!")

/obj/item/geiger_counter/update_icon_state()
	if(!scanning)
		icon_state = "geiger_off"
		return ..()

	switch(last_perceived_radiation_danger)
		if(null)
			icon_state = "geiger_on_1"
		if(PERCEIVED_RADIATION_DANGER_LOW)
			icon_state = "geiger_on_2"
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			icon_state = "geiger_on_3"
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			icon_state = "geiger_on_4"
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			icon_state = "geiger_on_5"
	return ..()

/obj/item/geiger_counter/attack_self(mob/user)
	scanning = !scanning

	if (scanning)
		AddComponent(/datum/component/geiger_sound)
	else
		qdel(GetComponent(/datum/component/geiger_sound))

	update_appearance(UPDATE_ICON)
	to_chat(user, span_notice("[icon2html(src, user)] You switch [scanning ? "on" : "off"] [src]."))

/obj/item/geiger_counter/afterattack(atom/target, mob/living/user, params)
	. = ..()

	if (user.combat_mode)
		return

	if (!CAN_IRRADIATE(target))
		return

	user.visible_message(span_notice("[user] scans [target] with [src]."), span_notice("You scan [target]'s radiation levels with [src]..."))
	addtimer(CALLBACK(src, .proc/scan, target, user), 20, TIMER_UNIQUE) // Let's not have spamming GetAllContents

/obj/item/geiger_counter/equipped(mob/user, slot, initial)
	. = ..()

	RegisterSignal(user, COMSIG_IN_RANGE_OF_IRRADIATION, .proc/on_pre_potential_irradiation)

/obj/item/geiger_counter/dropped(mob/user, silent = FALSE)
	. = ..()

	UnregisterSignal(user, COMSIG_IN_RANGE_OF_IRRADIATION, .proc/on_pre_potential_irradiation)

/obj/item/geiger_counter/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	last_perceived_radiation_danger = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	addtimer(CALLBACK(src, .proc/reset_perceived_danger), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

	if (scanning)
		update_appearance(UPDATE_ICON)

/obj/item/geiger_counter/proc/reset_perceived_danger()
	last_perceived_radiation_danger = null
	if (scanning)
		update_appearance(UPDATE_ICON)

/obj/item/geiger_counter/proc/scan(atom/target, mob/user)
	if (SEND_SIGNAL(target, COMSIG_GEIGER_COUNTER_SCAN, user, src) & COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL)
		return

	to_chat(user, span_notice("[icon2html(src, user)] [isliving(target) ? "Subject" : "Target"] is free of radioactive contamination."))

/obj/item/geiger_counter/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	if(!scanning)
		to_chat(usr, span_warning("[src] must be on to reset its radiation level!"))
		return
	to_chat(usr, span_notice("You flush [src]'s radiation counts, resetting it to normal."))
	last_perceived_radiation_danger = null
	update_appearance(UPDATE_ICON)
