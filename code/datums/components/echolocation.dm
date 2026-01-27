/datum/component/echolocation
	/// Radius of our echolocation.
	var/echo_range = 5
	/// Time for the image to start fading out.
	var/image_expiry_time = 0.7 SECONDS
	/// Time for the image to fade in.
	var/fade_in_time = 0.2 SECONDS
	/// Time for the image to fade out and delete itself.
	var/fade_out_time = 0.3 SECONDS

	/// Assoc list of world.time to atom ref to active image
	VAR_PRIVATE/list/active_images = list()
	/// All the saved appearances, keyed by icon-icon_state.
	VAR_PRIVATE/static/list/saved_appearances = list()

	/// Typepache of atom types that will be highlighted with an image on ABOVE_GAME_PLANE.
	var/list/highlighted_paths
	/// Typepache of atom types that will have an image generated on WALL_PLANE,
	/// so they stick out from the floor but they don't obstruct game objects.
	VAR_PRIVATE/list/background_paths
	/// Typecache of turfs that are dangerous, to give them a special icon.
	VAR_PRIVATE/list/danger_turfs

	/// The focus action for adjusting echolocation settings.
	var/datum/action/echolocation_focus/focus

	/// A matrix that turns everything except #ffffff into pure blackness, used for our images (the outlines are #ffffff).
	VAR_PRIVATE/static/list/black_white_matrix
	/// List of planes we apply our filters to.
	VAR_PRIVATE/static/list/planes

/datum/component/echolocation/Initialize(
	echo_range = src.echo_range,
	image_expiry_time = src.image_expiry_time,
	fade_in_time = src.fade_in_time,
	fade_out_time = src.fade_out_time,
	echo_icon,
)
	. = ..()
	var/mob/living/echolocator = parent
	if(!istype(echolocator))
		return COMPONENT_INCOMPATIBLE

	danger_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/chasm, /turf/open/lava, /turf/open/floor/fakespace, /turf/open/floor/fakepit, /turf/closed/wall/space))
	highlighted_paths = list()
	background_paths = typecacheof(list(/obj/structure/bed, /obj/structure/table))

	black_white_matrix ||= list(85, 85, 85, 0, 85, 85, 85, 0, 85, 85, 85, 0, 0, 0, 0, 1, -254, -254, -254, 0)
	planes ||= list(ABOVE_GAME_PLANE, FLOOR_PLANE, GAME_PLANE, WALL_PLANE)

	focus = new(src)
	focus.Grant(parent)

	src.echo_range = echo_range
	src.image_expiry_time = image_expiry_time
	src.fade_in_time = fade_in_time
	src.fade_out_time = fade_out_time

	ADD_TRAIT(echolocator, TRAIT_ECHOLOCATOR, ECHOLOCATION_TRAIT)
	ADD_TRAIT(echolocator, TRAIT_SIGHT_BYPASS, ECHOLOCATION_TRAIT)
	echolocator.become_blind(ECHOLOCATION_TRAIT)
	echolocator.overlay_fullscreen(ECHOLOCATION_TRAIT, /atom/movable/screen/fullscreen/echo, echo_icon)
	echolocator.apply_status_effect(/datum/status_effect/grouped/see_no_names, ECHOLOCATION_TRAIT)
	START_PROCESSING(SSfastprocess, src)

	for(var/tplane in planes)
		for (var/atom/movable/screen/plane_master/game_plane as anything in echolocator.hud_used?.get_true_plane_masters(tplane))
			game_plane.add_filter("[ECHOLOCATION_TRAIT]_color", 1, color_matrix_filter(black_white_matrix))
			game_plane.add_filter("[ECHOLOCATION_TRAIT]_outline", 1, outline_filter(size = 1, color = COLOR_WHITE))

	echolocator.update_sight()

/datum/component/echolocation/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	var/mob/living/echolocator = parent

	REMOVE_TRAIT(echolocator, TRAIT_ECHOLOCATOR, ECHOLOCATION_TRAIT)
	REMOVE_TRAIT(echolocator, TRAIT_SIGHT_BYPASS, ECHOLOCATION_TRAIT)
	echolocator.cure_blind(ECHOLOCATION_TRAIT)
	echolocator.clear_fullscreen(ECHOLOCATION_TRAIT)
	echolocator.remove_status_effect(/datum/status_effect/grouped/see_no_names, ECHOLOCATION_TRAIT)
	QDEL_NULL(focus)

	for(var/tplane in planes)
		for (var/atom/movable/screen/plane_master/game_plane as anything in echolocator.hud_used?.get_true_plane_masters(tplane))
			game_plane.remove_filter("[ECHOLOCATION_TRAIT]_color")
			game_plane.remove_filter("[ECHOLOCATION_TRAIT]_outline")

	echolocator.update_sight()

	for(var/time, image_list in active_images)
		for(var/atom_ref, echo_image in image_list)
			echolocator.client?.images -= echo_image

	return ..()

/datum/component/echolocation/process()
	var/mob/living/echolocator = parent
	if(echolocator.stat == DEAD)
		return
	echolocate()

/datum/component/echolocation/proc/echolocate()
	var/mob/living/echolocator = parent
	var/list/filtered = list()

	for(var/atom/seen_atom as anything in dview(echo_range, get_turf(echolocator.client?.eye || echolocator), invis_flags = echolocator.see_invisible))
		if(!seen_atom.alpha)
			continue
		if(!is_type_in_typecache(seen_atom, danger_turfs) \
			&& !is_type_in_typecache(seen_atom, highlighted_paths) \
			&& !is_type_in_typecache(seen_atom, background_paths))
			continue
		filtered += seen_atom

	if(!length(filtered))
		return

	var/list/known_refs = list()
	for(var/time, image_list in active_images)
		for(var/atom_ref, echo_image in image_list)
			known_refs[atom_ref] = time

	var/current_time = "[world.time]"
	active_images[current_time] = list()

	for(var/atom/filtered_atom as anything in filtered)
		// if we are already showing an image for this atom, just update its time so it sticks around longer
		var/atom_ref = REF(filtered_atom)
		if(known_refs[atom_ref])
			var/old_time = known_refs[atom_ref]
			var/image/old_image = active_images[old_time][atom_ref]
			active_images[old_time] -= atom_ref
			active_images[current_time][atom_ref] = old_image
			// if they are mid fade, cancel it
			animate(old_image, time = 0, alpha = 255)
			continue

		// generates a new image for this atom
		var/image/found_appearance = saved_appearances["[filtered_atom.icon]-[filtered_atom.icon_state]"] || generate_appearance(filtered_atom)
		var/image/final_image = image(found_appearance)
		var/is_background = is_type_in_typecache(filtered_atom, background_paths)
		if(is_background || PLANE_TO_TRUE(found_appearance.plane) == FLOOR_PLANE)
			// I am being evil here and using wall plane due to being in-between of game plane and floor plane
			// Why? Because we need background/floor objects to have their own layering, otherwise the effect is blended in wrong
			// These objects will scarcely interact with real walls so it's... fine
			final_image.layer = ABOVE_NORMAL_TURF_LAYER
			SET_PLANE(final_image, WALL_PLANE, filtered_atom)
		else if(is_type_in_typecache(filtered_atom, danger_turfs))
			SET_PLANE(final_image, FLOOR_PLANE, filtered_atom)
		else
			SET_PLANE(final_image, ABOVE_GAME_PLANE, filtered_atom)
		// Setting loc so we should disregard pixel offsets
		final_image.pixel_w = 0
		final_image.pixel_x = 0
		final_image.pixel_y = 0
		final_image.pixel_z = 0
		final_image.loc = filtered_atom
		final_image.dir = filtered_atom.dir
		final_image.alpha = 0
		animate(final_image, alpha = 255, time = fade_in_time)

		active_images[current_time] ||= list()
		active_images[current_time][atom_ref] = final_image

		echolocator.client?.images += final_image

	addtimer(CALLBACK(src, PROC_REF(fade_images), current_time), image_expiry_time)

/datum/component/echolocation/proc/generate_appearance(atom/input)
	var/mutable_appearance/copied_appearance = new()
	copied_appearance.appearance = input
	if(danger_turfs[input.type])
		copied_appearance.icon = 'icons/turf/floors.dmi'
		copied_appearance.icon_state = "danger"

	if(input.icon && input.icon_state)
		saved_appearances["[input.icon]-[input.icon_state]"] = copied_appearance
	copied_appearance.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	return copied_appearance

/datum/component/echolocation/proc/fade_images(from_time)
	for(var/atom_ref, echo_image in active_images[from_time])
		animate(echo_image, alpha = 0, time = fade_out_time)

	addtimer(CALLBACK(src, PROC_REF(cleanup_images), from_time), fade_out_time + 0.5 SECONDS)

/datum/component/echolocation/proc/cleanup_images(from_time)
	var/mob/living/echolocator = parent
	for(var/atom_ref, echo_image in active_images[from_time])
		echolocator.client?.images -= echo_image
	active_images -= from_time

/atom/movable/screen/fullscreen/echo
	icon_state = "echo"
	layer = 30
	plane = PLANE_SPACE_PARALLAX
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/echo/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	particles = new /particles/echo()

/atom/movable/screen/fullscreen/echo/Destroy()
	QDEL_NULL(particles)
	return ..()


/datum/action/echolocation_focus
	name = "Echolocation Focus"
	desc = "Focus your echolocation to reveal more details or ignore certain objects."

	/// Assoc list of option name to typecache list
	var/static/list/options
	/// List of currently selected option names
	var/list/selected_options

/datum/action/echolocation_focus/New(Target)
	. = ..()
	if(!options)
		var/list/all_floor_objects = list(/obj/machinery/atmospherics/components)
		for(var/obj/floor_type as anything in typesof(/obj/machinery, /obj/structure))
			if(initial(floor_type.plane) == FLOOR_PLANE)
				all_floor_objects += floor_type

		options = list()
		options["Blood"] = typecacheof(/obj/effect/decal/cleanable/blood)
		options["Items"] = typecacheof(/obj/item)
		options["Floor Objects"] = typecacheof(all_floor_objects)

	selected_options = list(options[1], options[2])
	update_echocomp()

/datum/action/echolocation_focus/proc/update_echocomp()
	var/datum/component/echolocation/echo_comp = target
	echo_comp.highlighted_paths.Cut()
	for(var/option_name in selected_options)
		echo_comp.highlighted_paths |= options[option_name]

/datum/action/echolocation_focus/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	ui_interact(clicker)

/datum/action/echolocation_focus/ui_status(mob/user, datum/ui_state/state)
	return IsAvailable() ? UI_INTERACTIVE : UI_CLOSE

/datum/action/echolocation_focus/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new /datum/tgui(user, src, "EcholocationFocus")
		ui.open()

/datum/action/echolocation_focus/ui_data(mob/user)
	var/list/data = list()

	data["selected_options"] = selected_options
	data["all_options"] = assoc_to_keys(options)

	return data

/datum/action/echolocation_focus/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action != "toggle")
		return

	var/toggled_option = params["option"]
	if(toggled_option in selected_options)
		selected_options -= toggled_option
	else
		selected_options += toggled_option
	update_echocomp()
	return TRUE
