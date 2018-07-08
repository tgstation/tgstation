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
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_MULTITOOL
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	var/obj/machinery/buffer // simple machine buffer for device linkage
	hitsound = 'sound/weapons/tap.ogg'
	toolspeed = 1
	tool_behaviour = TOOL_MULTITOOL
	usesound = 'sound/weapons/empty.ogg'
	var/datum/integrated_io/selected_io = null  //functional for integrated circuits.
	var/mode = 0

/obj/item/multitool/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] puts the [src] to [user.p_their()] chest. It looks like [user.p_theyre()] trying to pulse [user.p_their()] heart off!</span>")
	return OXYLOSS//theres a reason it wasnt recommended by doctors

/obj/item/multitool/attack_self(mob/user)
	if(selected_io)
		selected_io = null
		to_chat(user, "<span class='notice'>You clear the wired connection from the multitool.</span>")
	update_icon()

/obj/item/multitool/update_icon()
	if(selected_io)
		icon_state = "multitool_red"
	else
		icon_state = "multitool"

/obj/item/multitool/proc/wire(var/datum/integrated_io/io, mob/user)
	if(!io.holder.assembly)
		to_chat(user, "<span class='warning'>\The [io.holder] needs to be secured inside an assembly first.</span>")
		return

	if(selected_io)
		if(io == selected_io)
			to_chat(user, "<span class='warning'>Wiring \the [selected_io.holder]'s [selected_io.name] into itself is rather pointless.</span>")
			return
		if(io.io_type != selected_io.io_type)
			to_chat(user, "<span class='warning'>Those two types of channels are incompatible.  The first is a [selected_io.io_type], \
			while the second is a [io.io_type].</span>")
			return
		if(io.holder.assembly && io.holder.assembly != selected_io.holder.assembly)
			to_chat(user, "<span class='warning'>Both \the [io.holder] and \the [selected_io.holder] need to be inside the same assembly.</span>")
			return
		io.connect_pin(selected_io)

		to_chat(user, "<span class='notice'>You connect \the [selected_io.holder]'s [selected_io.name] to \the [io.holder]'s [io.name].</span>")
		selected_io.holder.interact(user) // This is to update the UI.
		selected_io = null

	else
		selected_io = io
		to_chat(user, "<span class='notice'>You link \the multitool to \the [selected_io.holder]'s [selected_io.name] data channel.</span>")

	update_icon()


/obj/item/multitool/proc/unwire(var/datum/integrated_io/io1, var/datum/integrated_io/io2, mob/user)
	if(!io1.linked.len || !io2.linked.len)
		to_chat(user, "<span class='warning'>There is nothing connected to the data channel.</span>")
		return

	if(!(io1 in io2.linked) || !(io2 in io1.linked) )
		to_chat(user, "<span class='warning'>These data pins aren't connected!</span>")
		return
	else
		io1.disconnect_pin(io2)
		to_chat(user, "<span class='notice'>You clip the data connection between the [io1.holder.displayed_name]'s \
		[io1.name] and the [io2.holder.displayed_name]'s [io2.name].</span>")
		io1.holder.interact(user) // This is to update the UI.
		update_icon()



// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.

/obj/item/multitool/ai_detect
	var/track_cooldown = 0
	var/track_delay = 10 //How often it checks for proximity
	var/detect_state = PROXIMITY_NONE
	var/rangealert = 8	//Glows red when inside
	var/rangewarning = 20 //Glows yellow when inside
	var/hud_type = DATA_HUD_AI_DETECT
	var/hud_on = FALSE
	var/mob/camera/aiEye/remote/ai_detector/eye
	var/datum/action/item_action/toggle_multitool/toggle_action

/obj/item/multitool/ai_detect/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	eye = new /mob/camera/aiEye/remote/ai_detector()
	toggle_action = new /datum/action/item_action/toggle_multitool(src)

/obj/item/multitool/ai_detect/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(hud_on && ismob(loc))
		remove_hud(loc)
	QDEL_NULL(toggle_action)
	QDEL_NULL(eye)
	return ..()

/obj/item/multitool/ai_detect/ui_action_click()
	return

/obj/item/multitool/ai_detect/update_icon()
	if(selected_io)
		icon_state = "multitool_red"
	else
		icon_state = "[initial(icon_state)][detect_state]"

/obj/item/multitool/ai_detect/equipped(mob/living/carbon/human/user, slot)
	..()
	if(hud_on)
		show_hud(user)

/obj/item/multitool/ai_detect/dropped(mob/living/carbon/human/user)
	..()
	if(hud_on)
		remove_hud(user)

/obj/item/multitool/ai_detect/process()
	if(track_cooldown > world.time)
		return
	detect_state = PROXIMITY_NONE
	if(eye.eye_user)
		eye.setLoc(get_turf(src))
	multitool_detect()
	update_icon()
	track_cooldown = world.time + track_delay

/obj/item/multitool/ai_detect/proc/toggle_hud(mob/user)
	hud_on = !hud_on
	if(user)
		to_chat(user, "<span class='notice'>You toggle the ai detection HUD on [src] [hud_on ? "on" : "off"].</span>")
	if(hud_on)
		show_hud(user)
	else
		remove_hud(user)

/obj/item/multitool/ai_detect/proc/show_hud(mob/user)
	if(user && hud_type)
		var/obj/screen/plane_master/camera_static/PM = user.hud_used.plane_masters["[CAMERA_STATIC_PLANE]"]
		PM.alpha = 150
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		if(!H.hudusers[user])
			H.add_hud_to(user)
		eye.eye_user = user
		eye.setLoc(get_turf(src))

/obj/item/multitool/ai_detect/proc/remove_hud(mob/user)
	if(user && hud_type)
		var/obj/screen/plane_master/camera_static/PM = user.hud_used.plane_masters["[CAMERA_STATIC_PLANE]"]
		PM.alpha = 255
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.remove_hud_from(user)
		if(eye)
			eye.setLoc(null)
			eye.eye_user = null

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(AI.cameraFollow == src)
			detect_state = PROXIMITY_ON_SCREEN
			break

	if(detect_state)
		return
	var/datum/camerachunk/chunk = GLOB.cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z)
	if(chunk && chunk.seenby.len)
		for(var/mob/camera/aiEye/A in chunk.seenby)
			if(!A.ai_detector_visible)
				continue
			var/turf/detect_turf = get_turf(A)
			if(get_dist(our_turf, detect_turf) < rangealert)
				detect_state = PROXIMITY_ON_SCREEN
				break
			if(get_dist(our_turf, detect_turf) < rangewarning)
				detect_state = PROXIMITY_NEAR
				break

/mob/camera/aiEye/remote/ai_detector
	name = "AI detector eye"
	ai_detector_visible = FALSE
	use_static = USE_STATIC_TRANSPARENT
	visible_icon = FALSE

/datum/action/item_action/toggle_multitool
	name = "Toggle AI detector HUD"
	check_flags = NONE

/datum/action/item_action/toggle_multitool/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/item/multitool/ai_detect/M = target
		M.toggle_hud(owner)
	return 1

/obj/item/multitool/cyborg
	name = "multitool"
	desc = "Optimised and stripped-down version of a regular multitool."
	toolspeed = 0.5

/obj/item/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "multitool"
	toolspeed = 0.1
