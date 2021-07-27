/**
 * # Object Overlay Component
 *
 * Shows an overlay ontop of an object. Toggleable.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/object_overlay
	display_name = "Object Overlay"
	display_desc = "A component that shows an overlay ontop of an object. Requires a BCI shell."

	required_shells = list(/obj/item/organ/cyberimp/bci)

	/// Target atom
	var/datum/port/input/target

	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y

	/// On/Off signals
	var/datum/port/input/signal_on
	var/datum/port/input/signal_off

	var/obj/item/organ/cyberimp/bci/bci
	var/list/active_overlays = list()
	var/list/atom_locs = list()
	var/list/options_map

/obj/item/circuit_component/object_overlay/Initialize()
	. = ..()
	target = add_input_port("Target", PORT_TYPE_ATOM)

	signal_on = add_input_port("Create Overlay", PORT_TYPE_SIGNAL)
	signal_off = add_input_port("Remove Overlay", PORT_TYPE_SIGNAL)

	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)

	set_option("Corners (Blue)")

/obj/item/circuit_component/object_overlay/populate_options()
	var/static/component_options = list(
		"Corners (Blue)",
		"Corners (Red)",
		"Circle (Blue)",
		"Circle (Red)",
		"Small Corners (Blue)",
		"Small Corners (Red)",
		"Triangle (Blue)",
		"Triangle (Red)",
		"HUD mark (Blue)",
		"HUD mark (Red)"
	)
	options = component_options

	var/static/options_to_icons = list(
		"Corners (Blue)" = "hud_corners",
		"Corners (Red)" = "hud_corners_red",
		"Circle (Blue)" = "hud_circle",
		"Circle (Red)" = "hud_circle_red",
		"Small Corners (Blue)" = "hud_corners_small",
		"Small Corners (Red)" = "hud_corners_small_red",
		"Triangle (Blue)" = "hud_triangle",
		"Triangle (Red)" = "hud_triangle_red",
		"HUD mark (Blue)" = "hud_mark",
		"HUD mark (Red)" = "hud_mark_red"
	)
	options_map = options_to_icons

/obj/item/circuit_component/object_overlay/register_shell(atom/movable/shell)
	bci = shell
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/obj/item/circuit_component/object_overlay/unregister_shell(atom/movable/shell)
	bci = null
	UnregisterSignal(shell, COMSIG_ORGAN_REMOVED)

/obj/item/circuit_component/object_overlay/input_received(datum/port/input/port)
	. = ..()

	if(. || !bci)
		return

	var/mob/living/owner = bci.owner
	var/atom/target_atom = target.input_value

	if(!owner || !istype(owner) || !owner.client || !target_atom)
		return

	if(COMPONENT_TRIGGERED_BY(signal_on, port))
		show_to_owner(target_atom, owner)

	if(COMPONENT_TRIGGERED_BY(signal_off, port) && (target_atom in active_overlays))
		owner.client.images.Remove(active_overlays[target_atom])
		active_overlays.Remove(target_atom)

/obj/item/circuit_component/object_overlay/proc/show_to_owner(atom/target_atom, mob/living/owner)
	if(active_overlays[target_atom])
		owner.client.images.Remove(active_overlays[target_atom])

	var/image/I = image(icon = 'icons/hud/screen_bci.dmi', loc = target_atom, icon_state = options_map[current_option], layer = RIPPLE_LAYER)

	if(image_pixel_x.input_value)
		I.pixel_x = image_pixel_x.input_value

	if(image_pixel_y.input_value)
		I.pixel_y = image_pixel_y.input_value

	active_overlays[target_atom] = I
	owner.client.images |= I

/obj/item/circuit_component/object_overlay/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	for(var/atom/target_atom in active_overlays)
		owner.client.images.Remove(active_overlays[target_atom])
		active_overlays.Remove(target_atom)

/**
 * # Bar Overlay Component
 *
 * Basically an advanced verion of object overlay component that shows a horizontal/vertical bar.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/object_overlay/bar
	display_name = "Bar Overlay"
	display_desc = "A component that shows a bar overlay ontop of an object. Requires a BCI shell. Requires a 0-100 number to work propperly."

	var/datum/port/input/bar_number

/obj/item/circuit_component/object_overlay/bar/Initialize()
	. = ..()
	bar_number = add_input_port("Number", PORT_TYPE_ATOM)

	set_option("Vertical")

/obj/item/circuit_component/object_overlay/bar/populate_options()
	var/static/component_options_bar = list(
		"Horizontal",
		"Vertical"
	)
	options = component_options_bar

	var/static/options_to_icons_bar = list(
		"Horizontal" = "barhoriz",
		"Vertical" = "barvert"
	)
	options_map = options_to_icons_bar

/obj/item/circuit_component/object_overlay/bar/show_to_owner(atom/target_atom, mob/living/owner)
	if(active_overlays[target_atom])
		owner.client.images.Remove(active_overlays[target_atom])

	var/number_clear = clamp(bar_number.input_value, 0, 100)
	if(current_option == "Horizontal")
		number_clear = round(number_clear / 6.25) * 6.25
	else if(current_option == "Vertical")
		number_clear = round(number_clear / 10) * 10
	var/image/I = image(icon = 'icons/hud/screen_bci.dmi', loc = target_atom, icon_state = "[options_map[current_option]][number_clear]", layer = RIPPLE_LAYER)

	if(image_pixel_x.input_value)
		I.pixel_x = image_pixel_x.input_value

	if(image_pixel_y.input_value)
		I.pixel_y = image_pixel_y.input_value

	active_overlays[target_atom] = I
	owner.client.images |= I
