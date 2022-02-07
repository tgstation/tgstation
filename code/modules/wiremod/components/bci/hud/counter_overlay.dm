/**
 * # Counter Overlay Component
 *
 * Shows an counter overlay.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/counter_overlay
	display_name = "Counter Overlay"
	desc = "A component that shows an three digit counter. Requires a BCI shell."
	category = "BCI"

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/input/counter_number

	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y

	var/datum/port/input/signal_update

	var/obj/item/organ/cyberimp/bci/bci
	var/list/numbers = list()
	var/counter_appearance

/obj/item/circuit_component/counter_overlay/populate_ports()
	counter_number = add_input_port("Displayed Number", PORT_TYPE_NUMBER)

	signal_update = add_input_port("Update Overlay", PORT_TYPE_SIGNAL)

	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)

/obj/item/circuit_component/counter_overlay/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell
		RegisterSignal(shell, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/obj/item/circuit_component/counter_overlay/unregister_shell(atom/movable/shell)
	bci = null
	QDEL_NULL(counter_appearance)
	for(var/number in numbers)
		QDEL_NULL(number)
	UnregisterSignal(shell, COMSIG_ORGAN_REMOVED)

/obj/item/circuit_component/counter_overlay/input_received(datum/port/input/port)
	if(!bci)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client)
		return

	for(var/number in numbers)
		QDEL_NULL(number)
	numbers = list()

	QDEL_NULL(counter_appearance)
	var/image/counter = image(icon = 'icons/hud/screen_bci.dmi', icon_state = "hud_numbers", loc = owner)
	if(image_pixel_x.value)
		counter.pixel_x = image_pixel_x.value
	if(image_pixel_y.value)
		counter.pixel_y = image_pixel_y.value

	counter_appearance = WEAKREF(owner.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"counter_overlay_[REF(src)]",
		counter,
		owner,
	))

	var/cleared_number = clamp(round(counter_number.value), 0, 999)

	for(var/i = 1 to 3)
		var/cur_num = round(cleared_number / (10 ** (3 - i))) % 10
		var/image/number = image(icon = 'icons/hud/screen_bci.dmi', icon_state = "hud_number_[cur_num]", loc = owner)

		if(image_pixel_x.value)
			number.pixel_x = image_pixel_x.value + (i - 1) * 9
		if(image_pixel_y.value)
			number.pixel_y = image_pixel_y.value

		numbers.Add(WEAKREF(owner.add_alt_appearance(
			/datum/atom_hud/alternate_appearance/basic/one_person,
			"counter_overlay_[REF(src)]_[i]",
			number,
			owner,
		)))

/obj/item/circuit_component/counter_overlay/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	QDEL_NULL(counter_appearance)
	for(var/number in numbers)
		QDEL_NULL(number)

/obj/item/circuit_component/counter_overlay/Destroy()
	QDEL_NULL(counter_appearance)
	for(var/number in numbers)
		QDEL_NULL(number)
	return ..()
