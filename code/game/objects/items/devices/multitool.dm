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
	atom_size = ITEM_SIZE_SMALL
	tool_behaviour = TOOL_MULTITOOL
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	drop_sound = 'sound/items/handling/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/multitool_pickup.ogg'
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)
	custom_premium_price = PAYCHECK_HARD * 3
	toolspeed = 1
	usesound = 'sound/weapons/empty.ogg'
	var/obj/machinery/buffer // simple machine buffer for device linkage
	var/mode = 0

/obj/item/multitool/examine(mob/user)
	. = ..()
	. += span_notice("Its buffer [buffer ? "contains [buffer]." : "is empty."]")

/obj/item/multitool/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts the [src] to [user.p_their()] chest. It looks like [user.p_theyre()] trying to pulse [user.p_their()] heart off!"))
	return OXYLOSS//theres a reason it wasn't recommended by doctors


// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.

/obj/item/multitool/ai_detect
	var/detect_state = PROXIMITY_NONE
	var/rangealert = 8 //Glows red when inside
	var/rangewarning = 20 //Glows yellow when inside
	var/hud_type = DATA_HUD_AI_DETECT
	var/hud_on = FALSE
	var/mob/camera/ai_eye/remote/ai_detector/eye
	var/datum/action/item_action/toggle_multitool/toggle_action

/obj/item/multitool/ai_detect/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	eye = new /mob/camera/ai_eye/remote/ai_detector()
	toggle_action = new /datum/action/item_action/toggle_multitool(src)

/obj/item/multitool/ai_detect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(hud_on && ismob(loc))
		remove_hud(loc)
	QDEL_NULL(toggle_action)
	QDEL_NULL(eye)
	return ..()

/obj/item/multitool/ai_detect/ui_action_click()
	return

/obj/item/multitool/ai_detect/equipped(mob/living/carbon/human/user, slot)
	..()
	if(hud_on)
		show_hud(user)

/obj/item/multitool/ai_detect/dropped(mob/living/carbon/human/user)
	..()
	if(hud_on)
		remove_hud(user)

/obj/item/multitool/ai_detect/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][detect_state]"

/obj/item/multitool/ai_detect/process()
	var/old_detect_state = detect_state
	if(eye.eye_user)
		eye.setLoc(get_turf(src))
	multitool_detect()
	if(detect_state != old_detect_state)
		update_appearance()

/obj/item/multitool/ai_detect/proc/toggle_hud(mob/user)
	hud_on = !hud_on
	if(user)
		to_chat(user, span_notice("You toggle the ai detection HUD on [src] [hud_on ? "on" : "off"]."))
	if(hud_on)
		show_hud(user)
	else
		remove_hud(user)

/obj/item/multitool/ai_detect/proc/show_hud(mob/user)
	if(user && hud_type)
		var/atom/movable/screen/plane_master/camera_static/ai_detect_plane = user.hud_used.plane_masters["[CAMERA_STATIC_PLANE]"]
		ai_detect_plane.alpha = 64
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		if(!hud.hudusers[user])
			hud.add_hud_to(user)
		eye.eye_user = user
		eye.setLoc(get_turf(src))

/obj/item/multitool/ai_detect/proc/remove_hud(mob/user)
	if(user && hud_type)
		var/atom/movable/screen/plane_master/camera_static/ai_detect_plane = user.hud_used.plane_masters["[CAMERA_STATIC_PLANE]"]
		ai_detect_plane.alpha = 255
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(user)
		if(eye)
			eye.setLoc(null)
			eye.eye_user = null

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)

	for(var/mob/living/silicon/ai/AI as anything in GLOB.ai_list)
		if(AI.cameraFollow == src)
			detect_state = PROXIMITY_ON_SCREEN
			return

	for(var/mob/camera/ai_eye/AI_eye as anything in GLOB.aiEyes)
		if(!AI_eye.ai_detector_visible)
			continue

		var/distance = get_dist(our_turf, get_turf(AI_eye))

		if(distance == -1) //get_dist() returns -1 for distances greater than 127 (and for errors, so assume -1 is just max range)
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
	name = "Toggle AI detector HUD"
	check_flags = NONE

/datum/action/item_action/toggle_multitool/Trigger(trigger_flags)
	if(!..())
		return FALSE
	if(target)
		var/obj/item/multitool/ai_detect/M = target
		M.toggle_hud(owner)
	return TRUE

/obj/item/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "multitool"
	custom_materials = list(/datum/material/iron = 5000, /datum/material/silver = 2500, /datum/material/plasma = 5000, /datum/material/titanium = 2000, /datum/material/diamond = 2000)
	toolspeed = 0.1

/obj/item/multitool/cyborg
	name = "electronic multitool"
	desc = "Optimised version of a regular multitool. Streamlines processes handled by its internal microchip."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "multitool_cyborg"
	toolspeed = 0.5
