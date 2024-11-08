/obj/item/wargame_projector
	name = "holographic projector"
	desc = "A handy-dandy holographic projector developed by the Port Authority Naval Command for playing wargames with, this one seems broken."
	icon = 'modular_doppler/wargaming/icons/projectors_and_holograms.dmi'
	icon_state = "projector"
	base_icon_state = "projector"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	/// All of the signs this projector is maintaining
	var/list/projections
	/// The maximum number of projections this can support
	var/max_signs = 1
	/// The color to give holograms when created
	var/holosign_color = COLOR_WHITE
	/// The type of hologram to spawn on click
	var/holosign_type = /obj/structure/wargame_hologram
	/// A list containing all of the possible holosigns this can choose from
	var/list/holosign_options = list(
		/obj/structure/wargame_hologram,
	)
	/// Contains all of the colors that the holograms can be changed to spawn as
	var/static/list/color_options = list(
		"Red" = COLOR_RED_LIGHT,
		"Orange" = COLOR_LIGHT_ORANGE,
		"Yellow" = COLOR_VIVID_YELLOW,
		"Green" = COLOR_VIBRANT_LIME,
		"Blue" = COLOR_BLUE_LIGHT,
		"Pink" = COLOR_FADED_PINK,
		"White" = COLOR_WHITE,
		"Gray" = COLOR_GRAY,
		"Brown" = COLOR_BROWN,
		"Ice" = COLOR_BLUE_GRAY,
	)
	/// Will hold the choices for radial menu use, populated on init
	var/list/radial_choices = list()
	/// A names to path list for the projections filled out by populate_radial_choice_lists() on init
	var/list/projection_names_to_path = list()

/obj/item/wargame_projector/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)
	update_appearance()
	populate_radial_choice_lists()

/obj/item/wargame_projector/handle_openspace_click(turf/target, mob/user, click_parameters)
	ranged_interact_with_atom(target, user, params2list(click_parameters))

/obj/item/wargame_projector/update_appearance()
	. = ..()
	cut_overlays()

	var/image/color_select_overlay = image(icon = icon, icon_state = "[base_icon_state]_screen")
	color_select_overlay.color = holosign_color
	add_overlay(color_select_overlay)

/obj/item/wargame_projector/examine(mob/user)
	. = ..()
	if(projections)
		. += span_notice("It is currently maintaining <b>[projections.len]/[max_signs]</b> projections.")
	. += span_notice("Use the projector <b>in hand</b> to change what type of hologram it creates.")
	. += span_notice("<b>Alt clicking</b> the projector will let you change the color of the next hologram it makes.")
	. += span_warning("<b>Control clicking</b> the projector will allow you to clear all active holograms.")

/obj/item/wargame_projector/proc/populate_radial_choice_lists()
	if(!length(radial_choices) || !length(projection_names_to_path))
		for(var/obj/structure/wargame_hologram/hologram as anything in holosign_options)
			projection_names_to_path[initial(hologram.name)] = hologram
			radial_choices[initial(hologram.name)] = image(icon = initial(hologram.icon), icon_state = initial(hologram.icon_state))

/// Changes the selected hologram to one of the options from the hologram list
/obj/item/wargame_projector/proc/select_hologram(mob/user)
	var/picked_choice = show_radial_menu(
		user,
		src,
		radial_choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	holosign_type = projection_names_to_path[picked_choice]

/obj/item/wargame_projector/attack_self(mob/user)
	select_hologram(user)

/obj/item/wargame_projector/click_alt(mob/user)
	var/selected_color = tgui_input_list(user, "Select a color", "Color Selection", color_options)
	if(isnull(selected_color))
		balloon_alert(user, "no color change")
		return
	var/color_to_set_to = color_options[selected_color]
	holosign_color = color_to_set_to
	balloon_alert(user, "color changed")
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/wargame_projector/item_ctrl_click(mob/user)
	if(tgui_alert(usr,"Clear all currently active holograms?", "Hologram Removal", list("Yes", "No")) == "Yes")
		for(var/hologram as anything in projections)
			qdel(hologram)
	return CLICK_ACTION_SUCCESS

/// Can we place a hologram at the target location?
/obj/item/wargame_projector/proc/check_can_place_hologram(atom/target, mob/user, team)
	if(!check_allowed_items(target, not_inside = TRUE))
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf(TRUE))
		return FALSE
	if(LAZYLEN(projections) >= max_signs)
		balloon_alert(user, "max capacity!")
		return FALSE
	return TRUE

/// Spawn a hologram with pixel offset based on where the user clicked
/obj/item/wargame_projector/proc/create_hologram(atom/target, mob/user, list/modifiers)
	var/obj/target_holosign = new holosign_type(get_turf(target), src)

	var/click_x
	var/click_y

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		click_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
		click_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)

	target_holosign.pixel_x = click_x
	target_holosign.pixel_y = click_y

	target_holosign.color = holosign_color

	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)

/obj/item/wargame_projector/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/structure/wargame_hologram))
		qdel(interacting_with)
		return ITEM_INTERACT_SUCCESS
	if(!check_can_place_hologram(interacting_with, user, 1))
		return NONE
	create_hologram(interacting_with, user, modifiers)
	return ITEM_INTERACT_SUCCESS

/obj/item/wargame_projector/Destroy()
	QDEL_LAZYLIST(projections)
	. = ..()

/// Actual projector types, split between the 'categories' of things they can project

/obj/item/wargame_projector/ships
	name = "holographic unit projector"
	desc = "A handy-dandy holographic projector developed by the Port Authority Naval Command for playing wargames with, this one creates markers for 'units'."
	max_signs = 30
	holosign_color = COLOR_BLUE_LIGHT
	holosign_type = /obj/structure/wargame_hologram/ship_marker
	holosign_options = list(
		/obj/structure/wargame_hologram/unidentified,
		/obj/structure/wargame_hologram/missile_warning,
		/obj/structure/wargame_hologram/strike_craft,
		/obj/structure/wargame_hologram/strike_craft_util,
		/obj/structure/wargame_hologram/strike_craft/wing,
		/obj/structure/wargame_hologram/ship_marker,
		/obj/structure/wargame_hologram/ship_marker/medium,
		/obj/structure/wargame_hologram/ship_marker/large,
		/obj/structure/wargame_hologram/ship_marker/large/alternate,
		/obj/structure/wargame_hologram/probe,
		/obj/structure/wargame_hologram/stationary_structure,
		/obj/structure/wargame_hologram/stationary_structure/platform,
	)

/obj/item/wargame_projector/ships/red
	holosign_color = COLOR_RED_LIGHT

/obj/item/wargame_projector/terrain
	name = "holographic terrain projector"
	desc = "A handy-dandy holographic projector developed by the Port Authority Naval Command for playing wargames with, this one creates markers for space 'terrain'."
	max_signs = 30
	holosign_color = COLOR_GRAY
	holosign_type = /obj/structure/wargame_hologram/asteroid
	// Some things, like stations, probes, and unidentified contacts, can be in the terrain one just because I can see situations where that's desired
	holosign_options = list(
		/obj/structure/wargame_hologram/unidentified,
		/obj/structure/wargame_hologram/dust,
		/obj/structure/wargame_hologram/asteroid,
		/obj/structure/wargame_hologram/asteroid/large,
		/obj/structure/wargame_hologram/asteroid/cluster,
		/obj/structure/wargame_hologram/planet,
		/obj/structure/wargame_hologram/probe,
		/obj/structure/wargame_hologram/stationary_structure,
		/obj/structure/wargame_hologram/stationary_structure/platform,
	)
