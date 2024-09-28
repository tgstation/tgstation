// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.
/mob/camera/ai_eye
	name = "Inactive AI Eye"

	icon_state = "ai_camera"
	icon = 'icons/mob/silicon/cameramob.dmi'
	invisibility = INVISIBILITY_MAXIMUM
	hud_possible = list(ANTAG_HUD, AI_DETECT_HUD = HUD_LIST_LIST)
	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	var/relay_speech = FALSE
	var/use_static = TRUE
	var/static_visibility_range = 16
	var/ai_detector_visible = TRUE
	var/ai_detector_color = COLOR_RED
	interaction_range = INFINITY

/mob/camera/ai_eye/Initialize(mapload)
	. = ..()
	GLOB.aiEyes += src
	update_ai_detect_hud()
	setLoc(loc, TRUE)

/mob/camera/ai_eye/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	update_ai_detect_hud()

/mob/camera/ai_eye/examine(mob/user) //Displays a silicon's laws to ghosts
	. = ..()
	if(istype(ai) && ai.laws && isobserver(user))
		. += "<b>[ai] has the following laws:</b>"
		for(var/law in ai.laws.get_law_list(include_zeroth = TRUE))
			. += law

/mob/camera/ai_eye/proc/update_ai_detect_hud()
	var/datum/atom_hud/ai_detector/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	var/list/old_images = hud_list[AI_DETECT_HUD]
	if(!ai_detector_visible)
		hud.remove_atom_from_hud(src)
		QDEL_LIST(old_images)
		return

	if(!length(hud.hud_users))
		return //no one is watching, do not bother updating anything

	hud.remove_atom_from_hud(src)

	var/static/list/vis_contents_opaque = list()
	var/turf/our_turf = get_turf(src)
	var/our_z_offset = GET_TURF_PLANE_OFFSET(our_turf)
	var/key = "[our_z_offset]-[ai_detector_color]"

	var/obj/effect/overlay/ai_detect_hud/hud_obj = vis_contents_opaque[key]
	if(!hud_obj)
		hud_obj = new /obj/effect/overlay/ai_detect_hud()
		SET_PLANE_W_SCALAR(hud_obj, PLANE_TO_TRUE(hud_obj.plane), our_z_offset)
		hud_obj.color = ai_detector_color
		vis_contents_opaque[key] = hud_obj

	var/list/new_images = list()
	var/list/turfs = get_visible_turfs()
	for(var/T in turfs)
		var/image/I = (old_images.len > new_images.len) ? old_images[new_images.len + 1] : image(null, T)
		I.loc = T
		I.vis_contents += hud_obj
		new_images += I
	for(var/i in (new_images.len + 1) to old_images.len)
		qdel(old_images[i])
	hud_list[AI_DETECT_HUD] = new_images
	hud.add_atom_to_hud(src)

/mob/camera/ai_eye/proc/get_visible_turfs()
	if(!isturf(loc))
		return list()
	var/client/C = GetViewerClient()
	var/view = C ? getviewsize(C.view) : getviewsize(world.view)
	var/turf/lowerleft = locate(max(1, x - (view[1] - 1)/2), max(1, y - (view[2] - 1)/2), z)
	var/turf/upperright = locate(min(world.maxx, lowerleft.x + (view[1] - 1)), min(world.maxy, lowerleft.y + (view[2] - 1)), lowerleft.z)
	return block(lowerleft, upperright)

/// Used in cases when the eye is located in a movable object (i.e. mecha)
/mob/camera/ai_eye/proc/update_visibility()
	SIGNAL_HANDLER
	if(use_static)
		ai.camera_visibility(src)

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/ai_eye/proc/setLoc(destination, force_update = FALSE)
	if(!ai)
		return
	if(!isturf(ai.loc))
		return
	destination = get_turf(destination)
	if(!force_update && (destination == get_turf(src)))
		return //we are already here!
	if (destination)
		abstract_move(destination)
	else
		moveToNullspace()
	if(use_static)
		ai.camera_visibility(src)
	if(ai.client && !ai.multicam_on)
		ai.client.set_eye(src)
	update_ai_detect_hud()
	update_parallax_contents()
	//Holopad
	if(istype(ai.current, /obj/machinery/holopad))
		var/obj/machinery/holopad/H = ai.current
		if(!H.move_hologram(ai, destination))
			H.clear_holo(ai)

	if(ai.camera_light_on)
		ai.light_cameras()
	if(ai.master_multicam)
		ai.master_multicam.refresh_view()

/mob/camera/ai_eye/zMove(dir, turf/target, z_move_flags = NONE, recursions_left = 1, list/falling_movs)
	. = ..()
	if(.)
		setLoc(loc, force_update = TRUE)

/mob/camera/ai_eye/Move()
	return

/mob/camera/ai_eye/proc/GetViewerClient()
	if(ai)
		return ai.client
	return null

/mob/camera/ai_eye/Destroy()
	if(ai)
		ai.all_eyes -= src
		ai = null
	for(var/V in visibleCameraChunks)
		var/datum/camerachunk/c = V
		c.remove(src)
	GLOB.aiEyes -= src
	if(ai_detector_visible)
		var/datum/atom_hud/ai_detector/hud = GLOB.huds[DATA_HUD_AI_DETECT]
		hud.remove_atom_from_hud(src)
		var/list/L = hud_list[AI_DETECT_HUD]
		QDEL_LIST(L)
	return ..()

/atom/proc/move_camera_by_click()
	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/AI = usr
	if(AI.eyeobj && (AI.multicam_on || (AI.client.eye == AI.eyeobj)) && (AI.eyeobj.z == z))
		AI.ai_tracking_tool.reset_tracking()
		if (isturf(loc) || isturf(src))
			AI.eyeobj.setLoc(src)

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.
#define SPRINT_PER_TICK 0.5
#define MAX_SPRINT 50
#define SPRINT_PER_STEP 20
/mob/living/silicon/ai/proc/AIMove(direction)
	if(last_moved && last_moved + 1 < world.timeofday)
		// Decay sprint based off how long it took us to input this next move
		var/missed_sprint = max((world.timeofday + 1) - last_moved, 0) * SPRINT_PER_TICK
		sprint = max(sprint - missed_sprint * 7, initial(sprint))

	// We move a full step, at least. Can't glide more with our current movement mode, so this is how I have to live
	var/step_count = 0
	for(var/i = 0; i < max(sprint, initial(sprint)); i += SPRINT_PER_STEP)
		step_count += 1
		var/turf/step = get_turf(get_step(eyeobj, direction))
		if(step)
			eyeobj.setLoc(step)

	// I'd like to make this scale with the steps we take, but it like, just can't
	// So we're doin this instead
	eyeobj.glide_size = world.icon_size

	last_moved = world.timeofday
	if(acceleration)
		sprint = min(sprint + SPRINT_PER_TICK, MAX_SPRINT)
	else
		sprint = initial(sprint)

	ai_tracking_tool.reset_tracking()

#undef SPRINT_PER_STEP
#undef MAX_SPRINT
#undef SPRINT_PER_TICK

// Return to the Core.
/mob/living/silicon/ai/proc/view_core()
	if(istype(current,/obj/machinery/holopad))
		var/obj/machinery/holopad/H = current
		H.clear_holo(src)
	else
		current = null
	if(ai_tracking_tool)
		ai_tracking_tool.reset_tracking()

	if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		stack_trace("AI eye object wasn't found! Location: [loc] / Eyeobj: [eyeobj] / QDELETED: [QDELETED(eyeobj)] / Eye loc: [eyeobj?.loc]")
		QDEL_NULL(eyeobj)
		create_eye()

	eyeobj?.setLoc(loc)

/mob/living/silicon/ai/proc/create_eye()
	if(eyeobj)
		return
	eyeobj = new /mob/camera/ai_eye()
	all_eyes += eyeobj
	eyeobj.ai = src
	eyeobj.setLoc(loc)
	eyeobj.name = "[name] (AI Eye)"
	eyeobj.real_name = eyeobj.name
	set_eyeobj_visible(TRUE)

/mob/living/silicon/ai/proc/set_eyeobj_visible(state = TRUE)
	if(!eyeobj)
		return
	eyeobj.mouse_opacity = state ? MOUSE_OPACITY_ICON : initial(eyeobj.mouse_opacity)
	if(state)
		eyeobj.SetInvisibility(INVISIBILITY_OBSERVER, id=type)
	else
		eyeobj.RemoveInvisibility(type)

/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	if(incapacitated)
		return
	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")

/mob/camera/ai_eye/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if(relay_speech && speaker && ai && !radio_freq && speaker != ai && GLOB.cameranet.checkCameraVis(speaker))
		ai.relay_speech(message, speaker, message_language, raw_message, radio_freq, spans, message_mods)

/obj/effect/overlay/ai_detect_hud
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = ""
	alpha = 100
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
