/**
 * # Item Interact Component
 *
 * Allows for interaction with an item. Drone shell only.
 */
/obj/item/circuit_component/item_interact
	display_name = "Item Interact"
	desc = "A component that can force the shell to interact with an item. Only works with drone shells. Only works on items. Must be directly next to the item."
	category = "Action"

	/// Whether to use primary attack_self or secondary attack_self
	var/datum/port/input/primary_interact
	var/datum/port/input/secondary_interact

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/item_interact/populate_ports()
	primary_interact = add_input_port("Primary Interact", PORT_TYPE_ATOM)
	secondary_interact = add_input_port("Secondary Interact", PORT_TYPE_ATOM)

/obj/item/circuit_component/item_interact/input_received(datum/port/input/port)
	do_primary()
	do_secondary()

/obj/item/circuit_component/item_interact/proc/do_primary()
	var/atom/target_atom = primary_interact.value
	if(!istype(target_atom, /obj/item))
		return
	var/obj/item/target_item = target_atom

	var/mob/shell = parent.shell
	if(!istype(shell) || get_dist(shell, target_item) > 1 || shell.z != target_item.z)
		return

	target_item.attack_self(shell)

/obj/item/circuit_component/item_interact/proc/do_secondary()
	var/atom/target_atom = secondary_interact.value
	if(!istype(target_atom, /obj/item))
		return
	var/obj/item/target_item = target_atom

	var/mob/shell = parent.shell
	if(!istype(shell) || get_dist(shell, target_item) > 1 || shell.z != target_item.z)
		return

	target_item.attack_self_secondary(shell)
