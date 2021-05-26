/**
 * # Compact Remote
 *
 * A handheld device with several buttons.
 * In game, this translates to having different signals for normal usage, alt-clicking, and ctrl-clicking when in your hand.
 */
/obj/item/controller
	name = "controller"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_small_calc"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

/obj/item/controller/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/controller()
	), SHELL_CAPACITY_MEDIUM)

/obj/item/circuit_component/controller
	display_name = "Controller"

	/// The three separate buttons that are called in attack_hand on the shell.
	var/datum/port/output/signal
	var/datum/port/output/alt
	var/datum/port/output/right

/obj/item/circuit_component/controller/Initialize()
	. = ..()
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)
	alt = add_output_port("Alternate Signal", PORT_TYPE_SIGNAL)
	right = add_output_port("Extra Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/controller/Destroy()
	signal = null
	alt = null
	right = null
	return ..()

/obj/item/circuit_component/controller/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, .proc/send_trigger)
	RegisterSignal(shell, COMSIG_CLICK_ALT, .proc/send_alternate_signal)
	RegisterSignal(shell, COMSIG_CLICK_RIGHT, .proc/send_right_signal)

/obj/item/circuit_component/controller/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_CLICK_RIGHT,
		COMSIG_CLICK_ALT,
	))

/**
 * Called when the shell item is used in hand, including right click.
 */
/obj/item/circuit_component/controller/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(source))
		return
	source.balloon_alert(user, "clicked primary button")
	playsound(source, get_sfx("terminal_type"), 25, FALSE)
	signal.set_output(COMPONENT_SIGNAL)

/**
 * Called when the shell item is alt-clicked
 */
/obj/item/circuit_component/controller/proc/send_alternate_signal(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(source))
		return
	source.balloon_alert(user, "clicked alternate button")
	playsound(source, get_sfx("terminal_type"), 25, FALSE)
	alt.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/controller/proc/send_right_signal(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(source))
		return
	source.balloon_alert(user, "clicked extra button")
	playsound(source, get_sfx("terminal_type"), 25, FALSE)
	right.set_output(COMPONENT_SIGNAL)
