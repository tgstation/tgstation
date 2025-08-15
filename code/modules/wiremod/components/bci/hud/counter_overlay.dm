/**
 * # Counter Overlay Component
 *
 * Shows an counter overlay.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/counter_overlay
	display_name = "Counter Overlay"
	desc = "A component that shows a three-digit counter. Requires a BCI shell."
	category = "BCI"

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/input/counter_number

	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y

	var/datum/port/input/signal_update

	var/obj/item/organ/cyberimp/bci/bci
	var/list/numbers = list()
	var/datum/weakref/counter_appearance

/obj/item/circuit_component/counter_overlay/populate_ports()
	counter_number = add_input_port("Displayed Number", PORT_TYPE_NUMBER)

	signal_update = add_input_port("Update Overlay", PORT_TYPE_SIGNAL)

	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)

/obj/item/circuit_component/counter_overlay/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell
		RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/counter_overlay/unregister_shell(atom/movable/shell)
	bci = null
	for(var/datum/weakref/number in numbers)
		var/datum/atom_hud/number_overlay = number?.resolve()
		QDEL_NULL(number_overlay)
	numbers = list()

	var/datum/atom_hud/overlay = counter_appearance?.resolve()
	QDEL_NULL(overlay)
	UnregisterSignal(shell, COMSIG_ORGAN_REMOVED)

/obj/item/circuit_component/counter_overlay/input_received(datum/port/input/port)
	if(!bci)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client)
		return

	for(var/datum/weakref/number in numbers)
		var/datum/atom_hud/number_overlay = number?.resolve()
		QDEL_NULL(number_overlay)
	numbers = list()

	var/datum/atom_hud/overlay = counter_appearance?.resolve()
	QDEL_NULL(overlay)

	var/image/counter = image(icon = 'icons/hud/screen_bci.dmi', icon_state = "hud_numbers", loc = owner, layer = RIPPLE_LAYER)
	SET_PLANE_EXPLICIT(counter, ABOVE_LIGHTING_PLANE, owner)

	if(image_pixel_x.value != null)
		counter.pixel_w = image_pixel_x.value
	if(image_pixel_y.value != null)
		counter.pixel_z = image_pixel_y.value

	var/datum/atom_hud/alternate_appearance/basic/one_person/alt_appearance = owner.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"counter_overlay_[REF(src)]",
		counter,
		null,
		owner,
	)
	alt_appearance.show_to(owner)

	counter_appearance = WEAKREF(alt_appearance)

	var/cleared_number = clamp(round(counter_number.value), 0, 999)

	for(var/i = 1 to 3)
		var/cur_num = round(cleared_number / (10 ** (3 - i))) % 10
		var/image/number = image(icon = 'icons/hud/screen_bci.dmi', icon_state = "hud_number_[cur_num]", loc = owner, layer = RIPPLE_LAYER)
		SET_PLANE_EXPLICIT(number, ABOVE_LIGHTING_PLANE, owner)

		if(image_pixel_x.value != null)
			number.pixel_w = image_pixel_x.value + (i - 1) * 9
		else
			number.pixel_w = (i - 1) * 9

		if(image_pixel_y.value != null)
			number.pixel_z = image_pixel_y.value

		var/datum/atom_hud/alternate_appearance/basic/one_person/number_alt_appearance = owner.add_alt_appearance(
			/datum/atom_hud/alternate_appearance/basic/one_person,
			"counter_overlay_[REF(src)]_[i]",
			number,
			null,
			owner,
		)
		number_alt_appearance.show_to(owner)

		numbers += WEAKREF(number_alt_appearance)

/obj/item/circuit_component/counter_overlay/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	for(var/datum/weakref/number in numbers)
		var/datum/atom_hud/number_overlay = number?.resolve()
		QDEL_NULL(number_overlay)
	numbers = list()

	var/datum/atom_hud/overlay = counter_appearance?.resolve()
	overlay.hide_from(owner)
	QDEL_NULL(overlay)

/obj/item/circuit_component/counter_overlay/Destroy()
	for(var/datum/weakref/number in numbers)
		var/datum/atom_hud/number_overlay = number?.resolve()
		QDEL_NULL(number_overlay)
	numbers = list()

	var/datum/atom_hud/overlay = counter_appearance?.resolve()
	QDEL_NULL(overlay)
	return ..()
