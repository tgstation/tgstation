/obj/item/organ/cyberimp/bci
	name = "brain-computer interface"
	desc = "An implant that can be placed in a user's head to control circuits using their brain."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "bci"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/bci/Initialize()
	. = ..()

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bci_action("One"),
		new /obj/item/circuit_component/bci_action("Two"),
		new /obj/item/circuit_component/bci_action("Three"),
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/bci
	display_name = "Brain-Computer Interface"
	display_desc = "Used to receive inputs for the brain-computer interface. User is presented with three buttons."

/obj/item/circuit_component/bci_action
	display_name = "Brain-Computer Interface Action"
	display_desc = "Represents an action the user can take when implanted with the brain-computer interface."

	/// The name to use for the button
	var/datum/port/input/button_name

	/// Called when the user presses the button
	var/datum/port/output/signal

	/// A reference to the action button itself
	var/datum/action/innate/bci_action

/obj/item/circuit_component/bci_action/Initialize(mapload, default_icon)
	. = ..()

	if (!isnull(default_icon))
		set_option(default_icon)

	button_name = add_input_port("Name", PORT_TYPE_STRING)

	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/bci_action/Destroy()
	button_name = null
	signal = null

	QDEL_NULL(bci_action)

	return ..()

/obj/item/circuit_component/bci_action/populate_options()
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

	options = action_options

/obj/item/circuit_component/bci_action/register_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell
	if (!istype(bci))
		CRASH("BCI action button was placed inside [shell] ([shell.type]), not a BCI")

	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, .proc/on_organ_implanted)
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/obj/item/circuit_component/bci_action/unregister_shell(atom/movable/shell)
	QDEL_NULL(bci_action)

	UnregisterSignal(shell, list(
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/bci_action/input_received(datum/port/input/port)
	. = ..()

	if (.)
		return

	if (!isnull(bci_action))
		update_action()

/obj/item/circuit_component/bci_action/proc/update_action()
	bci_action.name = button_name.input_value
	bci_action.button_icon_state = "nanite_[replacetextEx(lowertext(current_option), " ", "_")]"

/obj/item/circuit_component/bci_action/proc/on_organ_implanted(datum/source, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	bci_action = new
	update_action()
	bci_action.Grant(receiver)

/obj/item/circuit_component/bci_action/proc/on_organ_removed(datum/source, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	QDEL_NULL(bci_action)

/datum/action/innate/bci_action
	name = "Action"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "nanite_power"

	var/obj/item/circuit_component/bci_action/circuit_component

/datum/action/innate/bci_action/New(obj/item/circuit_component/bci_action/circuit_component)
	..()

	src.circuit_component = circuit_component

/datum/action/innate/bci_action/Destroy()
	circuit_component.bci_action = null
	circuit_component = null

	return ..()

/datum/action/innate/bci_action/Activate()
	to_chat(world, "Activate")
	circuit_component.signal.set_output(COMPONENT_SIGNAL)
