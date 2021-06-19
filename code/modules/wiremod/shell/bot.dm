/**
 * # Bot
 *
 * Immobile (but not dense) shells that can interact with world.
 */
/obj/structure/bot
	name = "bot"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_medium_box"

	density = FALSE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

/obj/structure/bot/Initialize()
	. = ..()
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/bot), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_USB_PORT, \
	)

/obj/item/circuit_component/bot
	display_name = "Bot"

	/// Called when attack_hand is called on the shell.
	var/datum/port/output/signal

/obj/item/circuit_component/bot/Initialize()
	. = ..()
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/bot/Destroy()
	signal = null
	return ..()

/obj/item/circuit_component/bot/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)

/obj/item/circuit_component/bot/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ATOM_ATTACK_HAND)

/obj/item/circuit_component/bot/proc/on_attack_hand(atom/source, mob/user)
	SIGNAL_HANDLER
	source.balloon_alert(user, "pushed button")
	playsound(source, get_sfx("terminal_type"), 25, FALSE)
	signal.set_output(COMPONENT_SIGNAL)
