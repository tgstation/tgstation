/**
 * # Scanner
 *
 * A handheld device that lets you flash it over people.
 */
/obj/item/wiremod_scanner
	name = "scanner"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_small"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

/obj/item/wiremod_scanner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/wiremod_scanner()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/wiremod_scanner
	display_name = "Scanner"
	desc = "Used to receive scanned entities from the scanner."

	/// Called when afterattack is called on the shell.
	var/datum/port/output/signal

	/// The attacker
	var/datum/port/output/attacker

	/// The entity being attacked
	var/datum/port/output/attacking



/obj/item/circuit_component/wiremod_scanner/populate_ports()
	attacker = add_output_port("Scanner", PORT_TYPE_ATOM)
	attacking = add_output_port("Scanned Entity", PORT_TYPE_ATOM)
	signal = add_output_port("Scanned", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/wiremod_scanner/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_AFTERATTACK, .proc/handle_afterattack)

/obj/item/circuit_component/wiremod_scanner/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_AFTERATTACK)

/**
 * Called when the shell item attacks something
 */
/obj/item/circuit_component/wiremod_scanner/proc/handle_afterattack(atom/source, atom/target, mob/user, proximity_flag)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	source.balloon_alert(user, "scanned object")
	playsound(source, get_sfx("terminal_type"), 25, FALSE)
	attacker.set_output(user)
	attacking.set_output(target)
	signal.set_output(COMPONENT_SIGNAL)

