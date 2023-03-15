/**
 * # Terminal
 *
 * Shell that can let someone input text.
 */
/obj/structure/terminal
	name = "terminal"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_large_terminal"

	density = FALSE
	light_range = FALSE
	var/obj/item/circuit_component/terminal/terminal_component = null

/obj/structure/terminal/Initialize(mapload)
	. = ..()
	terminal_component = new /obj/item/circuit_component/terminal
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(terminal_component), \
		capacity = SHELL_CAPACITY_LARGE, \
	)


/obj/structure/terminal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	terminal_component.get_input(user)

/obj/item/circuit_component/terminal
	display_name = "Terminal"
	display_desc = "Allows someone to input a text string."

	/// Returns the text inputted.
	var/datum/port/output/input_text
	/// Called when text is entered.
	var/datum/port/output/signal

/obj/item/circuit_component/terminal/Initialize(mapload)
	. = ..()
	input_text = add_output_port("Text", PORT_TYPE_STRING)
	signal = add_output_port("Triggered", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/terminal/Destroy()
	signal = null
	return ..()

/obj/item/circuit_component/terminal/proc/get_input(mob/user)
	var/message = stripped_input(user, "Terminal Input:", "Terminal")
	input_text.set_output(message)
	signal.set_output(COMPONENT_SIGNAL)

