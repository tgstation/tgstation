#define PROXIMITY_NONE ""
#define PROXIMITY_ON_SCREEN "_red"
#define PROXIMITY_NEAR "_yellow"

/**
 * Multitool -- A multitool is used for hacking electronic devices.
 *
 */




/obj/item/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors. You can activate it in-hand to locate the nearest APC."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "multitool"
	inhand_icon_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_MULTITOOL
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	drop_sound = 'sound/items/handling/tools/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/multitool_pickup.ogg'
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 0.2)
	custom_premium_price = PAYCHECK_COMMAND * 3
	toolspeed = 1
	usesound = 'sound/items/weapons/empty.ogg'
	var/datum/buffer // simple machine buffer for device linkage
	var/mode = 0
	var/apc_scanner = TRUE
	COOLDOWN_DECLARE(next_apc_scan)

/obj/item/multitool/Destroy()
	if(buffer)
		remove_buffer(buffer)
	return ..()

/obj/item/multitool/examine(mob/user)
	. = ..()
	. += span_notice("Its buffer [buffer ? "contains [buffer]." : "is empty."]")

/obj/item/multitool/attack_self(mob/user, list/modifiers)
	. = ..()

	if(. || !apc_scanner)
		return

	scan_apc(user)

/obj/item/multitool/attack_self_secondary(mob/user, modifiers)
	. = ..()

	if(. || !apc_scanner)
		return

	scan_apc(user)

/obj/item/multitool/proc/scan_apc(mob/user)
	if(!COOLDOWN_FINISHED(src, next_apc_scan))
		return

	COOLDOWN_START(src, next_apc_scan, 1 SECONDS)

	var/area/local_area = get_area(src)
	var/power_controller = local_area.apc
	if(power_controller)
		user.balloon_alert(user, "[get_dist(src, power_controller)]m [dir2text(get_dir(src, power_controller))]")
	else
		user.balloon_alert(user, "couldn't find apc!")

/obj/item/multitool/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts the [src] to [user.p_their()] chest. It looks like [user.p_theyre()] trying to pulse [user.p_their()] heart off!"))
	return OXYLOSS//there's a reason it wasn't recommended by doctors

/**
 * Sets the multitool internal object buffer
 *
 * Arguments:
 * * buffer - the new object to assign to the multitool's buffer
 */
/obj/item/multitool/proc/set_buffer(datum/buffer)
	if(src.buffer)
		UnregisterSignal(src.buffer, COMSIG_QDELETING)
		remove_buffer(src.buffer)
	src.buffer = buffer
	if(!QDELETED(buffer))
		RegisterSignal(buffer, COMSIG_QDELETING, PROC_REF(remove_buffer))

/**
 * Called when the buffer's stored object is deleted
 *
 * This proc does not clear the buffer of the multitool, it is here to
 * handle the deletion of the object the buffer references
 */
/obj/item/multitool/proc/remove_buffer(datum/source)
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_MULTITOOL_REMOVE_BUFFER, source)
	buffer = null

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.

/obj/item/multitool/ai_detect
	/// How close the AI is to us
	var/detect_state = PROXIMITY_NONE
	/// Range at which the closest AI makes the multitool glow red
	var/rangealert = 8 //Glows red when inside
	/// Range at which the closest AI makes the multitool glow yellow
	var/rangewarning = 20 //Glows yellow when inside
	/// Is our HUD on
	var/hud_on = FALSE

/obj/item/multitool/ai_detect/examine(mob/user)
	. = ..()
	if(!hud_on)
		return
	. += span_notice("You can right-click to scan for a nearby APC.")
	switch(detect_state)
		if(PROXIMITY_NONE)
			. += span_green("No AI should be currently looking at you. Keep on your clandestine activities.")
		if(PROXIMITY_NEAR)
			. += span_warning("An AI is getting uncomfortably close. Maybe time to drop what youre doing.")
		if(PROXIMITY_ON_SCREEN)
			. += span_danger("An AI is (probably) looking at you. You should probably hide this.")

/obj/item/multitool/ai_detect/Destroy()
	if(hud_on && ismob(loc))
		remove_hud(loc)
	return ..()

/obj/item/multitool/ai_detect/attack_self(mob/user, modifiers)
	apc_scanner = FALSE //we want to toggle hud, not check for APC
	toggle_hud(user)
	return ..()

/obj/item/multitool/ai_detect/attack_self_secondary(mob/user, modifiers)
	apc_scanner = TRUE // so we can use rightclick instead of leftclick to scan apc
	return ..()

/obj/item/multitool/ai_detect/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(hud_on)
		show_hud(user)

/obj/item/multitool/ai_detect/dropped(mob/living/carbon/human/user)
	. = ..()
	if(hud_on)
		remove_hud(user)

/obj/item/multitool/ai_detect/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][detect_state]"

/obj/item/multitool/ai_detect/process()
	var/old_detect_state = detect_state
	multitool_detect()
	if(detect_state != old_detect_state)
		update_appearance()

/obj/item/multitool/ai_detect/proc/toggle_hud(mob/user)
	hud_on = !hud_on
	if(user)
		to_chat(user, span_notice("You toggle the ai detection feature on [src] [hud_on ? "on" : "off"]."))
	if(hud_on)
		START_PROCESSING(SSfastprocess, src)
		show_hud(user)
	else
		STOP_PROCESSING(SSfastprocess, src)
		detect_state = PROXIMITY_NONE
		update_appearance(UPDATE_ICON)
		remove_hud(user)

/obj/item/multitool/ai_detect/proc/show_hud(mob/user)
	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	hud.show_to(user)

/obj/item/multitool/ai_detect/proc/remove_hud(mob/user)
	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	hud.hide_from(user)

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)
	detect_state = PROXIMITY_NONE

	for(var/mob/camera/ai_eye/AI_eye as anything in GLOB.aiEyes)
		if(!AI_eye.ai_detector_visible)
			continue

		var/turf/ai_turf = get_turf(AI_eye)
		var/distance = get_dist(our_turf, ai_turf)

		if(distance == -1) //get_dist() returns -1 for distances greater than 127 (and for errors, so assume -1 is just max range)
			if(ai_turf == our_turf)
				detect_state = PROXIMITY_ON_SCREEN
				break
			continue

		if(distance < rangealert) //ai should be able to see us
			detect_state = PROXIMITY_ON_SCREEN
			break
		if(distance < rangewarning) //ai can't see us but is close
			detect_state = PROXIMITY_NEAR

/obj/item/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "multitool"
	belt_icon_state = "multitool_alien"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.25, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/titanium = SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT)
	toolspeed = 0.1

/obj/item/multitool/cyborg
	name = "electronic multitool"
	desc = "Optimised version of a regular multitool. Streamlines processes handled by its internal microchip."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_multitool"
	toolspeed = 0.5

#undef PROXIMITY_NEAR
#undef PROXIMITY_NONE
#undef PROXIMITY_ON_SCREEN
