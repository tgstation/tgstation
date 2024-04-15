/datum/forklift_module
	var/name = "Generic Forklift Module"
	/// What atom typepath is used as a preview icon for the module.
	var/atom/module_ui_display_atom_typepath
	///What forklift am I attached to?
	var/obj/vehicle/ridden/forklift/my_forklift
	///Does this module build instantly? If not, leaves a construction hologram of the atom.
	var/build_instantly = FALSE
	///What does this module build? List of typepaths, leave empty if you're not doing a standard module.
	var/list/available_builds = list()
	///How many materials should it take to build stuff? Keep this ordered with the basetypes as low in the list as possible, so the price overrides work.s
	var/list/resource_price = list() // list(typepath = list(material_define = amount))
	///How long should it take to build things?
	var/build_length = 2 SECONDS
	///How long should it take to deconstruct?
	var/deconstruction_time = 2 SECONDS
	///What do you currently have selected?
	var/current_selected_typepath
	///What directions are available?
	var/list/available_directions = list(NORTH, EAST, SOUTH, WEST)
	///What direction is the placement facing?
	var/direction = NORTH
	///The preview image we're showing.
	var/image/preview_image
	///What was the last turf we moused over?
	var/turf/last_turf_moused_over
	///Do we want to PlaceOnTop or ChangeTurf when we finish construction, if we're a turf?
	var/turf_place_on_top = FALSE
	///Do we want to balloon alert the name of the new option when switching between build paths?
	var/show_name_on_change = TRUE
	///What path do we want to use for holograms?
	var/hologram_path = /obj/structure/building_hologram
	///What path do we want to ChangeTurf to when deconstructing a turf?
	var/turf_deconstruct_path = /turf/baseturf_bottom
	/// What is the UI interface for this module?
	var/ui_interface_name = "ConstructionForkliftModule_Default"

/datum/forklift_module/proc/get_ui_data_payload(mob/user)
	var/list/data = list()

	data["name"] = name
	data["build_instantly"] = build_instantly
	data["resource_price"] = resource_price
	data["build_length"] = build_length
	data["deconstruction_time"] = deconstruction_time
	data["current_selected_typepath"] = current_selected_typepath
	data["available_directions"] = available_directions
	data["direction"] = direction

	data["available_builds"] = list()
	for(var/atom/typepath as anything in available_builds)
		data["available_builds"]["[typepath]"] = list(
			"name" = typepath::name,
			"display_src" = get_atom_typepath_icon_as_img_src(typepath),
		)

	return data

/datum/forklift_module/proc/perform_module_ui_action(mob/user, action, list/params)
	switch(action)
		if("select-build-target")
			current_selected_typepath = text2path(params["typepath"])
			if(!(current_selected_typepath in available_builds))
				my_forklift.balloon_alert(user, "invalid build target!")
				current_selected_typepath = available_builds[1]
			return

		if("rotate")
			var/rotate_direction = params["direction"]
			switch(rotate_direction)
				if("ccw")
					direction = turn(direction, 90)
				if("cw")
					direction = turn(direction, -90)
				if("north")
					direction = NORTH
				if("flip")
					direction = turn(direction, 180)
			return

		else
			CRASH("unknown module action '[action]' for '[type]'")

/// Ideally, you place here.
/datum/forklift_module/proc/on_left_click(mob/source, atom/clickingon)
	if(!valid_placement_location(get_turf(clickingon)))
		playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
		my_forklift.balloon_alert(source, "invalid location!")
		return
	var/found_hologram = locate(/obj/structure/building_hologram) in get_turf(clickingon)
	if(found_hologram)
		playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
		my_forklift.balloon_alert(source, "already working here!")
		return
	var/datum/component/material_container/forklift_container = my_forklift.GetComponent(/datum/component/material_container) // material_container moment
	var/list/price_of_build = resource_price[current_selected_typepath]
	if(!price_of_build)
		CRASH("No price available for typepath of [current_selected_typepath] in [src.name]!")
	if(forklift_container.use_materials(price_of_build))
		if(build_instantly)
			playsound(clickingon, 'sound/machines/click.ogg', 50, TRUE)
			if(ispath(current_selected_typepath, /turf))
				var/turf/turf_to_replace = get_turf(clickingon)
				if(!turf_place_on_top)
					turf_to_replace.ChangeTurf(current_selected_typepath)
				else
					turf_to_replace.place_on_top(current_selected_typepath)
			else
				var/atom/new_atom = create_atom(clickingon)
				after_build(new_atom)
		else
			var/obj/structure/building_hologram/hologram = new hologram_path(get_turf(clickingon))
			hologram.my_forklift = my_forklift
			hologram.build_length = build_length
			hologram.material_price = price_of_build
			hologram.setup_icon(current_selected_typepath, direction)
			hologram.before_build(src)
			LAZYADD(my_forklift.holograms, hologram)
			playsound(my_forklift, 'sound/effects/pop.ogg', 50, FALSE)
		LAZYREMOVE(source.client.images, preview_image)
		qdel(preview_image)
		update_preview_icon()
		preview_image.loc = get_turf(clickingon)
		LAZYOR(source.client.images, preview_image)
	else
		playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
		my_forklift.balloon_alert(source, "not enough materials!")
		return

/datum/forklift_module/proc/create_atom(atom/clickingon)
	var/atom/created_atom = new current_selected_typepath(get_turf(clickingon))
	return created_atom

/datum/forklift_module/proc/after_build(atom/built_atom)
	built_atom.dir = direction
	return

/// Ideally, you remove here.
/datum/forklift_module/proc/on_right_click(mob/source, atom/clickingon)
	if(get_dist(my_forklift, clickingon) > 7)
		return
	var/list/price_of_build = resource_price[clickingon.type]
	if(istype(clickingon, /obj/structure/building_hologram))
		var/obj/structure/building_hologram/hologram = clickingon
		if(istype(hologram, /obj/structure/building_hologram/deconstruction))
			hologram.give_refund = FALSE
			qdel(hologram)
			my_forklift.balloon_alert(source, "cancelled refund")
			return
		price_of_build = hologram.material_price // Refund this hologram and cancel the construction on it
		var/datum/component/material_container/forklift_container = my_forklift.GetComponent(/datum/component/material_container) // material_container moment
		qdel(hologram)
		if(!forklift_container.add_materials(price_of_build))
			playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
			my_forklift.balloon_alert(source, "not enough space to refund!")
			return

	else
		if(!price_of_build)
			playsound(my_forklift, 'sound/machines/buzz-two.ogg', 30, TRUE)
			my_forklift.balloon_alert(source, "not refundable on this module!")
			return
		var/obj/structure/building_hologram/deconstruction/hologram = new /obj/structure/building_hologram/deconstruction(get_turf(clickingon))
		hologram.my_forklift = my_forklift
		hologram.build_length = build_length
		hologram.material_price = price_of_build
		hologram.targeted_atom = clickingon
		hologram.layer = clickingon.layer + 0.1
		LAZYADD(my_forklift.holograms, hologram)
		playsound(my_forklift, 'sound/effects/pop.ogg', 50, FALSE)

/// Ideally, you cycle through available build options here.
/datum/forklift_module/proc/on_scrollwheel(mob/source, atom/A, scrolled_up)
	if(scrolled_up)
		current_selected_typepath = next_list_item(current_selected_typepath, available_builds)
	else
		current_selected_typepath = previous_list_item(current_selected_typepath, available_builds)
	LAZYREMOVE(source.client.images, preview_image)
	qdel(preview_image)
	update_preview_icon()
	preview_image.loc = last_turf_moused_over
	LAZYOR(source.client.images, preview_image)
	var/atom/current_atom = current_selected_typepath
	if(show_name_on_change)
		my_forklift.balloon_alert(source, initial(current_atom.name))
	playsound(my_forklift, 'sound/effects/pop.ogg', 50, FALSE)

/// Ideally, you rotate here or cycle through a setting.
/datum/forklift_module/proc/on_ctrl_scrollwheel(mob/source, atom/A, scrolled_up)
	if(scrolled_up)
		direction = next_list_item(direction, available_directions)
	else
		direction = previous_list_item(direction, available_directions)
	LAZYREMOVE(source.client.images, preview_image)
	qdel(preview_image)
	update_preview_icon()
	preview_image.loc = last_turf_moused_over
	LAZYOR(source.client.images, preview_image)
	playsound(my_forklift, 'sound/effects/pop.ogg', 50, FALSE)

/// More available inputs, if the module needs it.
/datum/forklift_module/proc/on_middle_click(mob/source, atom/clickingon)
	return

/// More available inputs, if the module needs it.
/datum/forklift_module/proc/on_alt_scrollwheel(mob/source, atom/A, scrolled_up)
	return

/// Handles the visual preview updating.
/datum/forklift_module/proc/on_mouse_entered(mob/source, atom/A)
	if(last_turf_moused_over == get_turf(A))
		return
	last_turf_moused_over = get_turf(A)
	LAZYREMOVE(source.client.images, preview_image)
	qdel(preview_image)
	update_preview_icon()
	preview_image.loc = get_turf(A)
	LAZYOR(source.client.images, preview_image)

/// Renders out an icon to overlay on the turf for the user.
/datum/forklift_module/proc/update_preview_icon()
	var/atom/temp_atom = current_selected_typepath
	preview_image = image(initial(temp_atom.icon), last_turf_moused_over, initial(temp_atom.icon_state), dir = direction)
	var/image/directional_overlay = image('icons/effects/buymode.dmi', icon_state = "direction_marker", dir = direction)
	var/datum/component/material_container/forklift_container = my_forklift.GetComponent(/datum/component/material_container) // material_container moment
	var/list/price_of_build = resource_price[current_selected_typepath]
	if(!price_of_build)
		CRASH("No price available for typepath of [current_selected_typepath] in [src.name]!")
	if(!valid_placement_location(last_turf_moused_over) || !forklift_container.has_materials(price_of_build))
		qdel(directional_overlay)
		directional_overlay = image('icons/effects/buymode.dmi', icon_state = "direction_marker_invalid", dir = direction)
	preview_image.add_overlay(directional_overlay)
	preview_image.alpha = 128

/// Returns true or false if the placement location is valid.
/datum/forklift_module/proc/valid_placement_location(location)
	return TRUE
