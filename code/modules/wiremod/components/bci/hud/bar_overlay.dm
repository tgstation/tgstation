#define COMP_BAR_OVERLAY_VERTICAL "Vertical"
#define COMP_BAR_OVERLAY_HORIZONTAL "Horizontal"

/**
 * # Bar Overlay Component
 *
 * Basically an advanced verion of object overlay component that shows a horizontal/vertical bar.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/object_overlay/bar
	display_name = "Bar Overlay"
	desc = "Requires a BCI shell. A component that shows a bar overlay atop an object, ranging from 0 to 100."
	category = "BCI"

	var/datum/port/input/option/bar_overlay_options
	var/datum/port/input/bar_number

	var/overlay_limit = 10

/obj/item/circuit_component/object_overlay/bar/populate_ports()
	. = ..()
	bar_number = add_input_port("Number", PORT_TYPE_NUMBER)

/obj/item/circuit_component/object_overlay/bar/populate_options()
	var/static/component_options_bar = list(
		COMP_BAR_OVERLAY_VERTICAL = "barvert",
		COMP_BAR_OVERLAY_HORIZONTAL = "barhoriz"
	)
	bar_overlay_options = add_option_port("Bar Overlay Options", component_options_bar)
	options_map = component_options_bar

/obj/item/circuit_component/object_overlay/bar/show_to_owner(atom/target_atom, mob/living/owner)
	if(LAZYLEN(active_overlays) >= overlay_limit)
		return

	var/current_option = bar_overlay_options.value

	if(active_overlays[target_atom])
		QDEL_NULL(active_overlays[target_atom])

	var/number_clear = clamp(bar_number.value, 0, 100)
	if(current_option == COMP_BAR_OVERLAY_HORIZONTAL)
		number_clear = round(number_clear / 6.25) * 6.25
	else if(current_option == COMP_BAR_OVERLAY_VERTICAL)
		number_clear = round(number_clear / 10) * 10

	var/image/cool_overlay = image(icon = 'icons/hud/screen_bci.dmi', loc = target_atom, icon_state = "[options_map[current_option]][number_clear]", layer = RIPPLE_LAYER)
	SET_PLANE_EXPLICIT(cool_overlay, ABOVE_LIGHTING_PLANE, target_atom)

	if(image_pixel_x.value != null)
		cool_overlay.pixel_w = image_pixel_x.value

	if(image_pixel_y.value != null)
		cool_overlay.pixel_z = image_pixel_y.value

	var/datum/atom_hud/alternate_appearance/basic/one_person/alt_appearance = target_atom.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"bar_overlay_[REF(src)]",
		cool_overlay,
		null,
		owner,
	)
	alt_appearance.show_to(owner)

	active_overlays[target_atom] = WEAKREF(alt_appearance)

#undef COMP_BAR_OVERLAY_VERTICAL
#undef COMP_BAR_OVERLAY_HORIZONTAL
