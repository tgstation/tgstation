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
		new /obj/item/circuit_component/bci_charge_listener,
		new /obj/item/circuit_component/bci_action("One"),
		new /obj/item/circuit_component/bci_action("Two"),
		new /obj/item/circuit_component/bci_action("Three"),
	), SHELL_CAPACITY_SMALL)

/obj/item/organ/cyberimp/bci/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	if (owner)
		// Otherwise say_dead will be called.
		// It's intentional that a circuit for a dead person does not speak from the shell.
		if (owner.stat == DEAD)
			return

		owner.say(message, forced = "circuit speech")
	else
		return ..()

/obj/item/circuit_component/bci
	display_name = "Brain-Computer Interface"
	display_desc = "Used to receive inputs for the brain-computer interface. User is presented with three buttons."

/obj/item/circuit_component/bci_action
	display_name = "BCI Action"
	display_desc = "Represents an action the user can take when implanted with the brain-computer interface."

	/// The name to use for the button
	var/datum/port/input/button_name

	/// Called when the user presses the button
	var/datum/port/output/signal

	/// A reference to the action button itself
	var/datum/action/innate/bci_action/bci_action

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

	bci_action = new(src)
	update_action()

	bci.actions += list(bci_action)

/obj/item/circuit_component/bci_action/unregister_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell
	if (!istype(bci))
		CRASH("BCI action button was unregistered for [shell] ([shell.type]), not a BCI")

	bci.actions -= bci_action
	QDEL_NULL(bci_action)

/obj/item/circuit_component/bci_action/input_received(datum/port/input/port)
	. = ..()

	if (.)
		return

	if (!isnull(bci_action))
		update_action()

/obj/item/circuit_component/bci_action/proc/update_action()
	bci_action.name = button_name.input_value
	bci_action.button_icon_state = "nanite_[replacetextEx(lowertext(current_option), " ", "_")]"

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
	circuit_component.signal.set_output(COMPONENT_SIGNAL)

/// Listens for when the user is going to be charging their battery.
/// Does not expose any inputs or outputs.
/obj/item/circuit_component/bci_charge_listener
	circuit_flags = CIRCUIT_FLAG_HIDDEN

	/// A reference to the action button to look at charge/get info
	var/datum/action/innate/bci_charge_action/charge_action

/obj/item/circuit_component/bci_charge_listener/Destroy()
	QDEL_NULL(charge_action)

	return ..()

/obj/item/circuit_component/bci_charge_listener/register_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell
	if (!istype(bci))
		CRASH("BCI charge listener was placed inside [shell] ([shell.type]), not a BCI")

	charge_action = new(src)
	bci.actions += list(charge_action)

	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, .proc/on_organ_implanted)
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/obj/item/circuit_component/bci_charge_listener/unregister_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell
	if (!istype(bci))
		CRASH("BCI charge listener was unregistered for [shell] ([shell.type]), not a BCI")

	bci.actions -= charge_action
	QDEL_NULL(charge_action)

	UnregisterSignal(shell, list(
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/bci_charge_listener/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/on_borg_charge)
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_electrocute)

/obj/item/circuit_component/bci_charge_listener/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	UnregisterSignal(owner, list(
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_LIVING_ELECTROCUTE_ACT,
	))

/obj/item/circuit_component/bci_charge_listener/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return

	parent.cell.give(amount)

/obj/item/circuit_component/bci_charge_listener/proc/on_electrocute(datum/source, shock_damage, siemens_coefficient, flags)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return

	if (flags & SHOCK_ILLUSION)
		return

	parent.cell.give(shock_damage * 2)
	to_chat(source, span_notice("You absorb some of the shock into your [parent.name]!"))

/datum/action/innate/bci_charge_action
	check_flags = NONE
	icon_icon = 'icons/obj/power.dmi'
	button_icon_state = "cell"

	var/obj/item/circuit_component/bci_charge_listener/circuit_component

/datum/action/innate/bci_charge_action/New(obj/item/circuit_component/bci_charge_listener/circuit_component)
	..()

	src.circuit_component = circuit_component

	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12
	update_maptext()

	START_PROCESSING(SSobj, src)

/datum/action/innate/bci_charge_action/Destroy()
	circuit_component.charge_action = null
	circuit_component = null

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/action/innate/bci_charge_action/Trigger()
	var/obj/item/stock_parts/cell/cell = circuit_component.parent.cell

	if (isnull(cell))
		to_chat(owner, span_boldwarning("[circuit_component.parent] has no power cell."))
	else
		to_chat(owner, span_info("[circuit_component.parent]'s [cell.name] has <b>[cell.percent()]%</b> charge left."))
		to_chat(owner, span_info("You can recharge it by using a cyborg recharging station."))

/datum/action/innate/bci_charge_action/process(delta_time)
	update_maptext()

/datum/action/innate/bci_charge_action/proc/update_maptext()
	var/obj/item/stock_parts/cell/cell = circuit_component.parent.cell
	button.maptext = cell ? MAPTEXT("[cell.percent()]%") : ""
