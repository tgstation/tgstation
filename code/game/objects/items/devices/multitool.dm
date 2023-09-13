#define PROXIMITY_NONE ""
#define PROXIMITY_ON_SCREEN "_red"
#define PROXIMITY_NEAR "_yellow"

/**
 * Multitool -- A multitool is used for hacking electronic devices.
 *
 */




/obj/item/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon = 'icons/obj/device.dmi'
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
	drop_sound = 'sound/items/handling/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/multitool_pickup.ogg'
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 0.2)
	custom_premium_price = PAYCHECK_COMMAND * 3
	toolspeed = 1
	usesound = 'sound/weapons/empty.ogg'
	var/datum/buffer // simple machine buffer for device linkage
	var/mode = 0

/obj/item/multitool/examine(mob/user)
	. = ..()
	. += span_notice("Its buffer [buffer ? "contains [buffer]." : "is empty."]")

/obj/item/multitool/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts the [src] to [user.p_their()] chest. It looks like [user.p_theyre()] trying to pulse [user.p_their()] heart off!"))
	return OXYLOSS//theres a reason it wasn't recommended by doctors

/obj/item/multitool/proc/set_buffer(datum/buffer)
	if(src.buffer)
		UnregisterSignal(src.buffer, COMSIG_QDELETING)
	if(QDELETED(buffer))
		return
	src.buffer = buffer
	RegisterSignal(buffer, COMSIG_QDELETING, PROC_REF(on_buffer_del))

/obj/item/multitool/proc/on_buffer_del(datum/source)
	SIGNAL_HANDLER
	buffer = null

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.

/obj/item/multitool/ai_detect
	actions_types = list(/datum/action/item_action/toggle_multitool)
	var/detect_state = PROXIMITY_NONE
	var/rangealert = 8 //Glows red when inside
	var/rangewarning = 20 //Glows yellow when inside
	var/hud_type = DATA_HUD_AI_DETECT
	var/detecting = FALSE

/obj/item/multitool/ai_detect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/multitool/ai_detect/ui_action_click()
	return

/obj/item/multitool/ai_detect/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][detect_state]"

/obj/item/multitool/ai_detect/process()
	var/old_detect_state = detect_state
	multitool_detect()
	if(detect_state != old_detect_state)
		update_appearance()

/obj/item/multitool/ai_detect/proc/toggle_detect(mob/user)
	detecting = !detecting
	if(user)
		to_chat(user, span_notice("You toggle the ai detection feature on [src] [detecting ? "on" : "off"]."))
	if(!detecting)
		detect_state = PROXIMITY_NONE
		update_appearance()
		STOP_PROCESSING(SSfastprocess, src)
		return
	if(detecting)
		START_PROCESSING(SSfastprocess, src)

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)
	detect_state = PROXIMITY_NONE

	for(var/mob/camera/ai_eye/AI_eye as anything in GLOB.aiEyes)
		if(!AI_eye.ai_detector_visible)
			continue

		var/distance = get_dist(our_turf, get_turf(AI_eye))

		if(distance == -1) //get_dist() returns -1 for distances greater than 127 (and for errors, so assume -1 is just max range)
			if(our_turf == get_turf(AI_eye)) // EXCEPT if the AI is on our TURF(ITS RIGHT ONTOP OF US!!!!)
				detect_state = PROXIMITY_ON_SCREEN
				break
			continue

		if(distance < rangealert) //ai should be able to see us
			detect_state = PROXIMITY_ON_SCREEN
			break
		if(distance < rangewarning) //ai cant see us but is close
			detect_state = PROXIMITY_NEAR

/mob/camera/ai_eye/remote/ai_detector
	name = "AI detector eye"
	ai_detector_visible = FALSE
	visible_icon = FALSE
	use_static = FALSE

/datum/action/item_action/toggle_multitool
	name = "Toggle AI detecting mode"
	check_flags = NONE

/datum/action/item_action/toggle_multitool/Trigger(trigger_flags)
	if(!..())
		return FALSE
	if(target)
		var/obj/item/multitool/ai_detect/M = target
		M.toggle_detect(owner)
	return TRUE

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
	icon_state = "multitool_cyborg"
	toolspeed = 0.5

#undef PROXIMITY_NEAR
#undef PROXIMITY_NONE
#undef PROXIMITY_ON_SCREEN
