//Picture in picture

/atom/movable/screen/movable/pic_in_pic/ai
	var/mob/living/silicon/ai/ai
	var/mutable_appearance/highlighted_background
	var/highlighted = FALSE
	var/mob/camera/ai_eye/pic_in_pic/aiEye

/atom/movable/screen/movable/pic_in_pic/ai/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	aiEye = new /mob/camera/ai_eye/pic_in_pic()
	aiEye.screen = src

/atom/movable/screen/movable/pic_in_pic/ai/Destroy()
	set_ai(null)
	QDEL_NULL(aiEye)
	return ..()

/atom/movable/screen/movable/pic_in_pic/ai/Click()
	..()
	if(ai)
		ai.select_main_multicam_window(src)

/atom/movable/screen/movable/pic_in_pic/ai/make_backgrounds()
	..()
	highlighted_background = new /mutable_appearance()
	highlighted_background.icon = 'icons/hud/pic_in_pic.dmi'
	highlighted_background.icon_state = "background_highlight"
	highlighted_background.layer = SPACE_LAYER

/atom/movable/screen/movable/pic_in_pic/ai/add_background()
	if((width > 0) && (height > 0))
		var/matrix/M = matrix()
		M.Scale(width + 0.5, height + 0.5)
		M.Translate((width-1)/2 * ICON_SIZE_X, (height-1)/2 * ICON_SIZE_Y)
		highlighted_background.transform = M
		standard_background.transform = M
		add_overlay(highlighted ? highlighted_background : standard_background)

/atom/movable/screen/movable/pic_in_pic/ai/set_view_size(width, height, do_refresh = TRUE)
	aiEye.static_visibility_range = (round(max(width, height) / 2) + 1)
	if(ai)
		ai.camera_visibility(aiEye)
	..()

/atom/movable/screen/movable/pic_in_pic/ai/set_view_center(atom/target, do_refresh = TRUE)
	..()
	aiEye.setLoc(get_turf(target))

/atom/movable/screen/movable/pic_in_pic/ai/refresh_view()
	..()
	aiEye.setLoc(get_turf(center))

/atom/movable/screen/movable/pic_in_pic/ai/proc/highlight()
	if(highlighted)
		return
	highlighted = TRUE
	cut_overlay(standard_background)
	add_overlay(highlighted_background)

/atom/movable/screen/movable/pic_in_pic/ai/proc/unhighlight()
	if(!highlighted)
		return
	highlighted = FALSE
	cut_overlay(highlighted_background)
	add_overlay(standard_background)

/atom/movable/screen/movable/pic_in_pic/ai/proc/set_ai(mob/living/silicon/ai/new_ai)
	if(ai)
		ai.multicam_screens -= src
		ai.all_eyes -= aiEye
		if(ai.master_multicam == src)
			ai.master_multicam = null
		if(ai.multicam_on)
			unshow_to(ai.client)
	ai = new_ai
	if(new_ai)
		new_ai.multicam_screens += src
		ai.all_eyes += aiEye
		if(new_ai.multicam_on)
			show_to(new_ai.client)

//Turf, area, and landmark for the viewing room

/turf/open/ai_visible
	name = ""
	icon = 'icons/hud/pic_in_pic.dmi'
	icon_state = "room_background"
	turf_flags = NOJAUNT

/turf/open/ai_visible/Initialize(mapload)
	. = ..()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(multiz_offset_increase))
	multiz_offset_increase(SSmapping)

/turf/open/ai_visible/proc/multiz_offset_increase(datum/source)
	SIGNAL_HANDLER
	SET_PLANE_W_SCALAR(src, initial(plane), SSmapping.max_plane_offset)

/area/centcom/ai_multicam_room
	name = "ai_multicam_room"
	icon_state = "ai_camera_room"
	static_lighting = FALSE

	base_lighting_alpha = 255
	area_flags = NOTELEPORT | HIDDEN_AREA | UNIQUE_AREA
	ambientsounds = null
	flags_1 = NONE

GLOBAL_DATUM(ai_camera_room_landmark, /obj/effect/landmark/ai_multicam_room)

/obj/effect/landmark/ai_multicam_room
	name = "ai camera room"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"

/obj/effect/landmark/ai_multicam_room/Initialize(mapload)
	. = ..()
	qdel(GLOB.ai_camera_room_landmark)
	GLOB.ai_camera_room_landmark = src

/obj/effect/landmark/ai_multicam_room/Destroy()
	if(GLOB.ai_camera_room_landmark == src)
		GLOB.ai_camera_room_landmark = null
	return ..()

//Dummy camera eyes

/mob/camera/ai_eye/pic_in_pic
	name = "Secondary AI Eye"
	invisibility = INVISIBILITY_OBSERVER
	mouse_opacity = MOUSE_OPACITY_ICON
	icon_state = "ai_pip_camera"
	var/atom/movable/screen/movable/pic_in_pic/ai/screen
	var/list/cameras_telegraphed = list()
	var/telegraph_cameras = TRUE
	var/telegraph_range = 7
	ai_detector_color = COLOR_ORANGE

/mob/camera/ai_eye/pic_in_pic/GetViewerClient()
	if(screen?.ai)
		return screen.ai.client

/mob/camera/ai_eye/pic_in_pic/setLoc(turf/destination, force_update = FALSE)
	if (destination)
		abstract_move(destination)
	else
		moveToNullspace()
	if(screen?.ai)
		screen.ai.camera_visibility(src)
	else
		GLOB.cameranet.visibility(src)
	update_camera_telegraphing()
	update_ai_detect_hud()

/mob/camera/ai_eye/pic_in_pic/get_visible_turfs()
	return screen ? screen.get_visible_turfs() : list()

/mob/camera/ai_eye/pic_in_pic/proc/update_camera_telegraphing()
	if(!telegraph_cameras)
		return
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/chunk as anything in visibleCameraChunks)
		for (var/z_key in chunk.cameras)
			for(var/obj/machinery/camera/camera as anything in chunk.cameras[z_key])
				if (!camera.can_use() || (get_dist(camera, src) > telegraph_range))
					continue
				visible |= camera

	add = visible - cameras_telegraphed
	remove = cameras_telegraphed - visible

	for (var/obj/machinery/camera/C as anything in remove)
		if(QDELETED(C))
			continue
		cameras_telegraphed -= C
		C.in_use_lights--
		C.update_appearance()
	for (var/obj/machinery/camera/C as anything in add)
		if(QDELETED(C))
			continue
		cameras_telegraphed |= C
		C.in_use_lights++
		C.update_appearance()

/mob/camera/ai_eye/pic_in_pic/proc/disable_camera_telegraphing()
	telegraph_cameras = FALSE
	for (var/obj/machinery/camera/C as anything in cameras_telegraphed)
		if(QDELETED(C))
			continue
		C.in_use_lights--
		C.update_appearance()
	cameras_telegraphed.Cut()

/mob/camera/ai_eye/pic_in_pic/Destroy()
	disable_camera_telegraphing()
	return ..()

//AI procs

/mob/living/silicon/ai/proc/drop_new_multicam(silent = FALSE)
	if(!CONFIG_GET(flag/allow_ai_multicam))
		if(!silent)
			to_chat(src, span_warning("This action is currently disabled. Contact an administrator to enable this feature."))
		return
	if(!eyeobj)
		return
	if(multicam_screens.len >= max_multicams)
		if(!silent)
			to_chat(src, span_warning("Cannot place more than [max_multicams] multicamera windows."))
		return
	var/atom/movable/screen/movable/pic_in_pic/ai/C = new /atom/movable/screen/movable/pic_in_pic/ai()
	C.set_view_size(3, 3, FALSE)
	C.set_view_center(get_turf(eyeobj))
	C.set_ai(src)
	if(!silent)
		to_chat(src, span_notice("Added new multicamera window."))
	return C

/mob/living/silicon/ai/proc/toggle_multicam()
	if(!CONFIG_GET(flag/allow_ai_multicam))
		to_chat(src, span_warning("This action is currently disabled. Contact an administrator to enable this feature."))
		return
	if(multicam_on)
		end_multicam()
	else
		start_multicam()

/mob/living/silicon/ai/proc/start_multicam()
	if(multicam_on || aiRestorePowerRoutine || !isturf(loc))
		return
	if(!GLOB.ai_camera_room_landmark)
		to_chat(src, span_warning("This function is not available at this time."))
		return
	multicam_on = TRUE
	refresh_multicam()
	to_chat(src, span_notice("Multiple-camera viewing mode activated."))

/mob/living/silicon/ai/proc/refresh_multicam()
	reset_perspective(GLOB.ai_camera_room_landmark)
	if(client)
		for(var/V in multicam_screens)
			var/atom/movable/screen/movable/pic_in_pic/P = V
			P.show_to(client)

/mob/living/silicon/ai/proc/end_multicam()
	if(!multicam_on)
		return
	multicam_on = FALSE
	select_main_multicam_window(null)
	if(client)
		for(var/V in multicam_screens)
			var/atom/movable/screen/movable/pic_in_pic/P = V
			P.unshow_to(client)
	reset_perspective()
	to_chat(src, span_notice("Multiple-camera viewing mode deactivated."))


/mob/living/silicon/ai/proc/select_main_multicam_window(atom/movable/screen/movable/pic_in_pic/ai/P)
	if(master_multicam == P)
		return

	if(master_multicam)
		master_multicam.set_view_center(get_turf(eyeobj), FALSE)
		master_multicam.unhighlight()
		master_multicam = null

	if(P)
		P.highlight()
		eyeobj.setLoc(get_turf(P.center))
		P.set_view_center(eyeobj)
		master_multicam = P
