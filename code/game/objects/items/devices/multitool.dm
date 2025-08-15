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
	icon_angle = -90
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

	COOLDOWN_START(src, next_apc_scan, 2 SECONDS)

	var/area/local_area = get_area(src)
	var/obj/machinery/power/apc/power_controller = local_area.apc
	if(!power_controller)
		user.balloon_alert(user, "couldn't find apc!")
		return

	var/dist = get_dist(src, power_controller)
	var/dir = get_dir(user, power_controller)
	var/balloon_message
	var/arrow_color

	switch(dist)
		if (0)
			user.balloon_alert(user, "found apc!")
			return
		if(1 to 5)
			arrow_color = COLOR_GREEN
		if(6 to 10)
			arrow_color = COLOR_YELLOW
		if(11 to 15)
			arrow_color = COLOR_ORANGE
		else
			arrow_color = COLOR_RED

	user.balloon_alert(user, balloon_message)

	var/datum/hud/user_hud = user.hud_used
	if(!user_hud || !istype(user_hud, /datum/hud) || !islist(user_hud.infodisplay))
		return

	var/atom/movable/screen/multitool_arrow/arrow = new(null, user_hud)
	arrow.color = arrow_color
	arrow.screen_loc = around_player
	arrow.transform = matrix(dir2angle(dir), MATRIX_ROTATE)

	user_hud.infodisplay += arrow
	user_hud.show_hud(user_hud.hud_version)

	QDEL_IN(arrow, 1.5 SECONDS)

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
	apc_scanner = FALSE
	/// How close the AI is to us
	var/detect_state = PROXIMITY_NONE
	/// Range at which the closest AI makes the multitool glow red
	var/rangealert = 8 //Glows red when inside
	/// Range at which the closest AI makes the multitool glow yellow
	var/rangewarning = 20 //Glows yellow when inside
	/// Is our HUD on
	var/hud_on = FALSE

	// static scan stuff
	/// hud object that the fake static images use
	var/obj/effect/overlay/ai_detect_hud/camera_unseen/hud_obj
	/// fake static image
	var/list/image/static_images = list()
	/// the client that we shoved those images to
	var/datum/weakref/static_viewer
	/// timerid for the timer that makes em disappear
	var/static_disappear_timer
	/// cooldown for actually doing a static scan
	COOLDOWN_DECLARE(static_scan_cd)

/obj/item/multitool/ai_detect/examine(mob/user)
	. = ..()
	if(!hud_on)
		return
	. += span_notice("You can right-click to scan for nearby unseen spots. They will be shown for exactly 8 seconds due to battery limitations.")
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
	cleanup_static()
	return ..()

/obj/item/multitool/ai_detect/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	toggle_hud(user)

/obj/item/multitool/ai_detect/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	scan_unseen(user)

/obj/item/multitool/ai_detect/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(hud_on)
		show_hud(user)

/obj/item/multitool/ai_detect/dropped(mob/living/carbon/human/user)
	. = ..()
	if(hud_on)
		remove_hud(user)
	cleanup_static()

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

	for(var/mob/eye/camera/ai/AI_eye in GLOB.camera_eyes)
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

/obj/item/multitool/ai_detect/proc/scan_unseen(mob/user)
	if(isnull(user?.client)) // the monkey incident of 2564
		return
	if(!COOLDOWN_FINISHED(src, static_scan_cd))
		balloon_alert(user, "recharging!")
		return
	cleanup_static()
	var/turf/our_turf = get_turf(src)
	var/list/datum/camerachunk/chunks = surrounding_chunks(our_turf)

	if(!hud_obj)
		hud_obj = new()
		SET_PLANE_W_SCALAR(hud_obj, PLANE_TO_TRUE(hud_obj.plane), GET_TURF_PLANE_OFFSET(our_turf))

	var/list/new_images = list()
	for(var/datum/camerachunk/chunk as anything in chunks)
		for(var/turf/seen_turf as anything in chunk.obscuredTurfs)
			var/image/img = image(loc = seen_turf, layer = ABOVE_ALL_MOB_LAYER)
			img.vis_contents += hud_obj
			SET_PLANE(img, GAME_PLANE, seen_turf)
			new_images += img
	user.client.images |= new_images
	static_viewer = WEAKREF(user.client)
	balloon_alert(user, "nearby unseen spots shown")
	static_disappear_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_static)), 8 SECONDS, TIMER_STOPPABLE)
	COOLDOWN_START(src, static_scan_cd, 4 SECONDS)

// copied from camera chunks but we are doing a really big edge case here though
/obj/item/multitool/ai_detect/proc/surrounding_chunks(turf/epicenter)
	. = list()
	var/static_range = /mob/eye/camera/ai::static_visibility_range
	var/x1 = max(1, epicenter.x - static_range)
	var/y1 = max(1, epicenter.y - static_range)
	var/x2 = min(world.maxx, epicenter.x + static_range)
	var/y2 = min(world.maxy, epicenter.y + static_range)

	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = GLOB.cameranet.getCameraChunk(x, y, epicenter.z)
			// removing cameras in build mode didnt affect it and i guess it needs an AI eye to update so we have to do this manually
			// unless we only want to see static in a jank manner only if an eye updates it
			chunk?.update() // UPDATE THE FUCK NOW
			. |= chunk

/obj/item/multitool/ai_detect/proc/cleanup_static()
	if(isnull(hud_obj)) //we never did anything
		return
	var/client/viewer = static_viewer?.resolve()
	viewer?.images -= static_images
	static_images.Cut()
	QDEL_NULL(hud_obj)
	viewer = null
	deltimer(static_disappear_timer)
	static_disappear_timer = null

/obj/item/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "multitool"
	inside_belt_icon_state = "multitool_alien"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.25, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/titanium = SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT)
	toolspeed = 0.1

/obj/item/multitool/cyborg
	name = "electronic multitool"
	desc = "Optimised version of a regular multitool. Streamlines processes handled by its internal microchip."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg_multitool"
	icon_angle = 0
	toolspeed = 0.5

#undef PROXIMITY_NEAR
#undef PROXIMITY_NONE
#undef PROXIMITY_ON_SCREEN
