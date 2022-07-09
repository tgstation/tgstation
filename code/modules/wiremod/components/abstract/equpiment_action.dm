/obj/item/circuit_component/equipment_action
	display_name = "Abstract Equipment Action"
	desc = "You shouldn't be seeing this."

	/// The icon of the button
	var/datum/port/input/option/icon_options

	/// The name to use for the button
	var/datum/port/input/button_name

	/// Called when the user presses the button
	var/datum/port/output/signal

/obj/item/circuit_component/equipment_action/Initialize(mapload, default_icon)
	. = ..()

	if (!isnull(default_icon))
		icon_options.set_input(default_icon)

	button_name = add_input_port("Name", PORT_TYPE_STRING)

	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/equipment_action/populate_options()
	var/static/action_options = list(
		"Blank",

		"One",
		"Two",
		"Three",
		"Four",
		"Five",

		"Blood",
		"Bomb",
		"Brain",
		"Brain Damage",
		"Cross",
		"Electricity",
		"Exclamation",
		"Heart",
		"Id",
		"Info",
		"Injection",
		"Magnetism",
		"Minus",
		"Network",
		"Plus",
		"Power",
		"Question",
		"Radioactive",
		"Reaction",
		"Repair",
		"Say",
		"Scan",
		"Shield",
		"Skull",
		"Sleep",
		"Wireless",
	)

	icon_options = add_option_port("Icon", action_options)

/obj/item/circuit_component/equipment_action/proc/update_action()
	return
