/**
 * # Object Overlay Component
 *
 * Shows an overlay ontop of an object. Toggleable.
 * Requires a BCI shell.
 */

GLOBAL_VAR_INIT(object_overlay_id, 0) //I need every object_overlay component to have a DIFFERENT ID because else they are going to overlap

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

	var/overlay_id

/obj/item/circuit_component/object_overlay/Initialize()
	. = ..()
	target = add_input_port("Target", PORT_TYPE_ATOM)

	signal_on = add_input_port("Create Overlay", PORT_TYPE_SIGNAL)
	signal_off = add_input_port("Remove Overlay", PORT_TYPE_SIGNAL)

	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)

	set_option("Corners (Blue)")
	overlay_id = GLOB.object_overlay_id
	GLOB.object_overlay_id += 1

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
		QDEL_NULL(active_overlays[target_atom])
		active_overlays.Remove(target_atom)

/obj/item/circuit_component/object_overlay/proc/show_to_owner(atom/target_atom, mob/living/owner)
	if(LAZYLEN(active_overlays) >= OBJECT_OVERLAY_LIMIT)
		return

	if(active_overlays[target_atom])
		QDEL_NULL(active_overlays[target_atom])

	var/image/cool_overlay = image(icon = 'icons/hud/screen_bci.dmi', loc = target_atom, icon_state = options_map[current_option], layer = RIPPLE_LAYER)

	if(image_pixel_x.input_value)
		cool_overlay.pixel_x = image_pixel_x.input_value

	if(image_pixel_y.input_value)
		cool_overlay.pixel_y = image_pixel_y.input_value

	var/alt_appearance = WEAKREF(target_atom.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"object_overlay_[overlay_id]",
		cool_overlay,
		owner,
	))

	active_overlays[target_atom] = alt_appearance

/obj/item/circuit_component/object_overlay/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	for(var/atom/target_atom in active_overlays)
		QDEL_NULL(active_overlays[target_atom])
		active_overlays.Remove(target_atom)
