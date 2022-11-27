/datum/component/echolocation
	var/echo_range = 4
	var/cooldown_time = 2 SECONDS
	var/image_expiry_time = 1.5 SECONDS
	var/fade_in_time = 0.5 SECONDS
	var/fade_out_time = 0.5 SECONDS
	var/images_are_static = FALSE
	var/list/images = list()
	var/static/list/saved_appearances = list()
	var/static/list/allowed_paths
	var/static/list/black_white_matrix = list(85, 85, 85, 0, 85, 85, 85, 0, 85, 85, 85, 0, 0, 0, 0, 1, -254, -254, -254, 0)
	COOLDOWN_DECLARE(cooldown_last)

/datum/component/echolocation/Initialize(echo_range, cooldown_time, image_expiry_time, fade_in_time, fade_out_time, images_are_static)
	. = ..()
	var/mob/echolocator = parent
	if(!istype(echolocator))
		return COMPONENT_INCOMPATIBLE
	if(!allowed_paths)
		allowed_paths = typecacheof(list(/turf/closed, /obj, /mob/living))
	if(!isnull(echo_range))
		src.echo_range = echo_range
	if(!isnull(cooldown_time))
		src.cooldown_time = cooldown_time
	if(!isnull(image_expiry_time))
		src.image_expiry_time = image_expiry_time
	if(!isnull(fade_in_time))
		src.fade_in_time = fade_in_time
	if(!isnull(fade_out_time))
		src.fade_out_time = fade_out_time
	if(!isnull(images_are_static))
		src.images_are_static = images_are_static
	echolocator.overlay_fullscreen("echo", /atom/movable/screen/fullscreen/echo)
	START_PROCESSING(SSobj, src)

/datum/component/echolocation/Destroy(force, silent)
	STOP_PROCESSING(SSobj, src)
	var/mob/echolocator = parent
	echolocator.clear_fullscreen("echo")
	for(var/timeframe in images)
		delete_images(timeframe)
	return ..()

/datum/component/echolocation/process()
	var/mob/echolocator = parent
	if(!echolocator.client)
		return
	echolocate()

/datum/component/echolocation/proc/echolocate()
	if(!COOLDOWN_FINISHED(src, cooldown_last))
		return
	COOLDOWN_START(src, cooldown_last, cooldown_time)
	var/mob/echolocator = parent
	var/list/filtered = list()
	var/list/seen = oview(echo_range, echolocator)
	for(var/atom/seen_atom as anything in seen)
		if(seen_atom.invisibility > echolocator.see_invisible || !seen_atom.alpha)
			continue
		if(allowed_paths[seen_atom.type])
			filtered += seen_atom
	if(!length(filtered))
		return
	var/current_time = "[world.time]"
	images[current_time] = list()
	for(var/atom/filtered_atom as anything in filtered)
		show_image(saved_appearances["[filtered_atom.icon]-[filtered_atom.icon_state]"] || generate_appearance(filtered_atom), filtered_atom, current_time)
	addtimer(CALLBACK(src, .proc/fade_images, current_time), image_expiry_time)

/datum/component/echolocation/proc/show_image(image/input_appearance, atom/input, current_time)
	var/mob/echolocator = parent
	var/image/final_image = image(input_appearance)
	final_image.layer += EFFECTS_LAYER
	final_image.plane = FULLSCREEN_PLANE
	final_image.loc = images_are_static ? get_turf(input) : input
	final_image.dir = input.dir
	final_image.alpha = 0
	images[current_time] += final_image
	if(echolocator.client)
		echolocator.client.images += final_image
	animate(final_image, alpha = 255, time = fade_in_time)

/datum/component/echolocation/proc/generate_appearance(atom/input)
	var/mutable_appearance/copied_appearance = new /mutable_appearance()
	copied_appearance.appearance = input
	if(istype(input, /obj/machinery/door/airlock)) //i hate you
		copied_appearance.icon = input.icon
		copied_appearance.icon_state = "closed"
	copied_appearance.color = black_white_matrix
	copied_appearance.filters += outline_filter(size = 1, color = COLOR_WHITE)
	if(!images_are_static)
		copied_appearance.pixel_x = 0
		copied_appearance.pixel_y = 0
		copied_appearance.transform = matrix()
	if(!iscarbon(input)) //wacky overlay people get generated everytime
		saved_appearances["[input.icon]-[input.icon_state]"] = copied_appearance
	return copied_appearance

/datum/component/echolocation/proc/fade_images(from_when)
	for(var/image_echo as anything in images[from_when])
		animate(image_echo, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, .proc/delete_images, from_when), fade_out_time)

/datum/component/echolocation/proc/delete_images(from_when)
	var/mob/echolocator = parent
	for(var/image_echo as anything in images[from_when])
		if(echolocator.client)
			echolocator.client.images -= image_echo
		qdel(image_echo)
	images -= from_when

/atom/movable/screen/fullscreen/echo
	icon_state = "echo"
