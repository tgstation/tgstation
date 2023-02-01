/obj/item/keyboard_shell
	name = "Keyboard Shell"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_small_keyboard"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

/obj/item/keyboard_shell/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/keyboard_shell()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/keyboard_shell
	display_name = "Keyboard Shell"
	desc = "A handheld shell that allows the user to input a string. Use the shell in hand to open the input panel."

	/// Called when the input window is closed
	var/datum/port/output/signal
	/// Entity who used the shell
	var/datum/port/output/entity
	/// The string, entity typed and submitted
	var/datum/port/output/output

/obj/item/circuit_component/keyboard_shell/populate_ports()
	entity = add_output_port("User", PORT_TYPE_ATOM)
	output = add_output_port("Message", PORT_TYPE_STRING)
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/keyboard_shell/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, PROC_REF(send_trigger))

/obj/item/circuit_component/keyboard_shell/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_ATTACK_SELF)
	return ..()

/obj/item/circuit_component/keyboard_shell/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(use_keyboard), user)

/obj/item/circuit_component/keyboard_shell/proc/use_keyboard(mob/user)
	if(HAS_TRAIT(user, TRAIT_ILLITERATE))
		to_chat(user, span_warning("You start mashing keys at random!"))
		return

	var/message = tgui_input_text(user, "Input your text", "Keyboard")
	entity.set_output(user)
	output.set_output(message)
	signal.set_output(COMPONENT_SIGNAL)


