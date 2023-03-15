/**
 * # Compact Remote
 *
 * A handheld device with one big button.
 */
/obj/item/clothing/glasses/circuit_goggles
	name = "circuit goggles"
	icon = 'monkestation/icons/obj/wiremod.dmi'
	icon_state = "circuit_goggles"
	item_state = "electronic"
	glass_colour_type = /datum/client_colour/glass_colour/green
	actions_types = list(/datum/action/item_action/use_circuit_goggles)
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

/obj/item/clothing/glasses/circuit_goggles/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/circuit_goggles()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/circuit_goggles
	display_name = "Circuit Goggles"
	display_desc = "Used to receive inputs from the circuit goggles shell. Wear the shell and examine something to use it."

	/// Called when examining something is called on the shell.
	var/datum/port/output/user
	var/datum/port/output/target
	var/datum/port/output/trigger

/obj/item/circuit_component/circuit_goggles/Initialize(mapload)
	. = ..()
	user = add_output_port("User", PORT_TYPE_ATOM)
	target = add_output_port("Target", PORT_TYPE_ATOM)
	trigger = add_output_port("Triggered", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/circuit_goggles/Destroy()
	user = null
	target = null
	trigger = null
	return ..()

/obj/item/circuit_component/circuit_goggles/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_CIRCUIT_GOGGLES_USED, .proc/send_trigger)

/obj/item/circuit_component/circuit_goggles/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_CIRCUIT_GOGGLES_USED)

/obj/item/circuit_component/circuit_goggles/proc/send_trigger(atom/source, mob/returned_target, mob/wearer)
	SIGNAL_HANDLER
	user.set_output(wearer)
	target.set_output(returned_target)
	trigger.set_output(COMPONENT_SIGNAL)
