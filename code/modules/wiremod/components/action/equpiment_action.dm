/obj/item/circuit_component/equipment_action
	display_name = "Equipment Action"
	desc = "Represents an action the user can take when using supported shells."
	required_shells = list(/obj/item/organ/cyberimp/bci, /obj/item/mod/module/circuit)

	/// The icon of the button
	var/datum/port/input/option/icon_options

	/// The name to use for the button
	var/datum/port/input/button_name

	/// The mob who activated their granted action
	var/datum/port/output/user

	/// Called when the user presses the button
	var/datum/port/output/signal

	/// An assoc list of datum REF()s, linked to the actions granted.
	var/list/granted_to = list()

/obj/item/circuit_component/equipment_action/Initialize(mapload, default_icon)
	. = ..()

	if (!isnull(default_icon))
		icon_options.set_input(default_icon)

	button_name = add_input_port("Name", PORT_TYPE_STRING)

	user = add_output_port("User", PORT_TYPE_USER)
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/equipment_action/Destroy()
	QDEL_LIST_ASSOC_VAL(granted_to)
	return ..()

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

/obj/item/circuit_component/equipment_action/register_shell(atom/movable/shell)
	. = ..()
	SEND_SIGNAL(shell, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, src)

/obj/item/circuit_component/equipment_action/unregister_shell(atom/movable/shell)
	. = ..()
	SEND_SIGNAL(shell, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, src)

/obj/item/circuit_component/equipment_action/input_received(datum/port/input/port)
	if (length(granted_to))
		update_actions()

/obj/item/circuit_component/equipment_action/proc/update_actions()
	for(var/ref in granted_to)
		var/datum/action/granted_action = granted_to[ref]
		granted_action.name = button_name.value || "Action"
		granted_action.button_icon_state = "bci_[replacetextEx(LOWER_TEXT(icon_options.value), " ", "_")]"
