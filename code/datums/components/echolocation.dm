/datum/component/echolocation
	/// Radius of our view.
	var/echo_range = 4
	/// Time between echolocations.
	var/cooldown_time = 2 SECONDS
	/// Time for the image to start fading out.
	var/image_expiry_time = 1.5 SECONDS
	/// Time for the image to fade in.
	var/fade_in_time = 0.5 SECONDS
	/// Time for the image to fade out and delete itself.
	var/fade_out_time = 0.5 SECONDS
	/// Are images static? If yes, spawns them on the turf and makes them not change location. Otherwise they change location and pixel shift with the original.
	var/images_are_static = TRUE
	/// With mobs that have this echo group in their echolocation receiver trait, we share echo images.
	var/echo_group = null
	/// This trait blocks us from receiving echolocation.
	var/blocking_trait
	/// Ref of the client color we give to the echolocator.
	var/client_color
	/// Associative list of world.time when created to a list of the images.
	var/list/images = list()
	/// Associative list of world.time when created to a list of receivers.
	var/list/receivers = list()
	/// All the saved appearances, keyed by icon-icon_state.
	var/static/list/saved_appearances = list()
	/// Typecache of all the allowed paths to render.
	var/static/list/allowed_paths
	/// Typecache of turfs that are dangerous, to give them a special icon.
	var/static/list/danger_turfs
	/// A matrix that turns everything except #ffffff into pure blackness, used for our images (the outlines are #ffffff).
	var/static/list/black_white_matrix = list(85, 85, 85, 0, 85, 85, 85, 0, 85, 85, 85, 0, 0, 0, 0, 1, -254, -254, -254, 0)
	/// A matrix that turns everything into pure white.
	var/static/list/white_matrix = list(255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 0, 0, 0, 1, 0, -0, 0, 0)
	/// Cooldown for the echolocation.
	COOLDOWN_DECLARE(cooldown_last)

/datum/component/echolocation/Initialize(echo_range, cooldown_time, image_expiry_time, fade_in_time, fade_out_time, images_are_static, blocking_trait, echo_group, echo_icon, color_path)
	. = ..()
	var/mob/living/echolocator = parent
	if(!istype(echolocator))
		return COMPONENT_INCOMPATIBLE
	if(!danger_turfs)
		danger_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/chasm, /turf/open/lava, /turf/open/floor/fakespace, /turf/open/floor/fakepit, /turf/closed/wall/space))
	if(!allowed_paths)
		allowed_paths = typecacheof(list(/turf/closed, /obj, /mob/living)) + danger_turfs - typecacheof(/obj/effect/decal)
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
	if(!isnull(blocking_trait))
		src.blocking_trait = blocking_trait
	if(ispath(color_path))
		client_color = echolocator.add_client_colour(color_path)
	src.echo_group = echo_group || REF(src)
	ADD_TRAIT(echolocator, TRAIT_ECHOLOCATION_RECEIVER, echo_group)
	ADD_TRAIT(echolocator, TRAIT_TRUE_NIGHT_VISION, echo_group) //so they see all the tiles they echolocated, even if they are in the dark
	echolocator.become_blind(ECHOLOCATION_TRAIT)
	echolocator.overlay_fullscreen("echo", /atom/movable/screen/fullscreen/echo, echo_icon)
	START_PROCESSING(SSfastprocess, src)

/datum/component/echolocation/Destroy(force, silent)
	STOP_PROCESSING(SSfastprocess, src)
	var/mob/living/echolocator = parent
	QDEL_NULL(client_color)
	REMOVE_TRAIT(echolocator, TRAIT_ECHOLOCATION_RECEIVER, echo_group)
	REMOVE_TRAIT(echolocator, TRAIT_TRUE_NIGHT_VISION, echo_group)
	echolocator.cure_blind(ECHOLOCATION_TRAIT)
	echolocator.clear_fullscreen("echo")
	for(var/timeframe in images)
		delete_images(timeframe)
	return ..()

/datum/component/echolocation/process()
	var/mob/living/echolocator = parent
	if(echolocator.stat == DEAD)
		return
	echolocate()

/datum/component/echolocation/proc/echolocate()
	if(!COOLDOWN_FINISHED(src, cooldown_last))
		return
	COOLDOWN_START(src, cooldown_last, cooldown_time)
	var/mob/living/echolocator = parent
	var/real_echo_range = echo_range
	if(HAS_TRAIT(echolocator, TRAIT_ECHOLOCATION_EXTRA_RANGE))
		real_echo_range += 2
	var/list/filtered = list()
	var/list/seen = dview(real_echo_range, get_turf(echolocator.client?.eye || echolocator), invis_flags = echolocator.see_invisible)
	for(var/atom/seen_atom as anything in seen)
		if(!seen_atom.alpha)
			continue
		if(allowed_paths[seen_atom.type])
			filtered += seen_atom
	if(!length(filtered))
		return
	var/current_time = "[world.time]"
	images[current_time] = list()
	receivers[current_time] = list()
	for(var/mob/living/viewer in filtered)
		if(blocking_trait && HAS_TRAIT(viewer, blocking_trait))
			continue
		if(HAS_TRAIT_FROM(viewer, TRAIT_ECHOLOCATION_RECEIVER, echo_group))
			receivers[current_time] += viewer
	for(var/atom/filtered_atom as anything in filtered)
		show_image(saved_appearances["[filtered_atom.icon]-[filtered_atom.icon_state]"] || generate_appearance(filtered_atom), filtered_atom, current_time)
	addtimer(CALLBACK(src, PROC_REF(fade_images), current_time), image_expiry_time)

/datum/component/echolocation/proc/show_image(image/input_appearance, atom/input, current_time)
	var/image/final_image = image(input_appearance)
	final_image.layer += EFFECTS_LAYER
	final_image.plane = FULLSCREEN_PLANE
	final_image.loc = images_are_static ? get_turf(input) : input
	final_image.dir = input.dir
	final_image.alpha = 0
	if(images_are_static)
		final_image.pixel_x = input.pixel_x
		final_image.pixel_y = input.pixel_y
	if(HAS_TRAIT_FROM(input, TRAIT_ECHOLOCATION_RECEIVER, echo_group)) //mark other echolocation with full white
		final_image.color = white_matrix
	images[current_time] += final_image
	for(var/mob/living/echolocate_receiver as anything in receivers[current_time])
		if(echolocate_receiver == input)
			continue
		if(echolocate_receiver.client)
			echolocate_receiver.client.images += final_image
	animate(final_image, alpha = 255, time = fade_in_time)

/datum/component/echolocation/proc/generate_appearance(atom/input)
	var/use_outline = TRUE
	var/mutable_appearance/copied_appearance = new /mutable_appearance()
	copied_appearance.appearance = input
	if(istype(input, /obj/machinery/door/airlock)) //i hate you
		copied_appearance.cut_overlays()
		copied_appearance.icon = 'icons/obj/doors/airlocks/station/public.dmi'
		copied_appearance.icon_state = "closed"
	else if(danger_turfs[input.type])
		copied_appearance.icon = 'icons/turf/floors.dmi'
		copied_appearance.icon_state = "danger"
		use_outline = FALSE
	copied_appearance.color = black_white_matrix
	if(use_outline)
		copied_appearance.filters += outline_filter(size = 1, color = COLOR_WHITE)
	if(!images_are_static)
		copied_appearance.pixel_x = 0
		copied_appearance.pixel_y = 0
		copied_appearance.transform = matrix()
	if(!iscarbon(input)) //wacky overlay people get generated everytime
		saved_appearances["[input.icon]-[input.icon_state]"] = copied_appearance
	return copied_appearance

/datum/component/echolocation/proc/fade_images(from_when)
	for(var/image_echo in images[from_when])
		animate(image_echo, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, PROC_REF(delete_images), from_when), fade_out_time)

/datum/component/echolocation/proc/delete_images(from_when)
	for(var/mob/living/echolocate_receiver as anything in receivers[from_when])
		if(!echolocate_receiver.client)
			continue
		for(var/image_echo in images[from_when])
			echolocate_receiver.client.images -= image_echo
	images -= from_when
	receivers -= from_when

/atom/movable/screen/fullscreen/echo
	icon_state = "echo"
	layer = ECHO_LAYER
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/echo/Initialize(mapload)
	. = ..()
	particles = new /particles/echo()

/atom/movable/screen/fullscreen/echo/Destroy()
	QDEL_NULL(particles)
	return ..()

/particles/echo
	icon = 'icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 1, "echo2" = 1, "echo3" = 2)
	width = 480
	height = 480
	count = 1000
	spawning = 0.5
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	gravity = list(0, -0.1)
	position = generator(GEN_BOX, list(-240, -240), list(240, 240), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.1, 0), list(0.1, 0))
	rotation = generator(GEN_NUM, 0, 360, NORMAL_RAND)
