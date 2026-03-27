/obj/item/skillchip/bci
	name = "brain-computer interface"
	desc = "An programmable skillchip that can be placed in a user's head to control circuits using their brain."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "bci"
	w_class = WEIGHT_CLASS_TINY
	/// Our internal circuit, if any
	var/obj/item/integrated_circuit/circuit
	/// Mob we currently have our signals registered on, i.e. the thing we're in. Hopefully.
	var/datum/weakref/controlled_mob
	/// Our internal circuit's main component
	var/obj/item/circuit_component/bci_core/bci_component

/obj/item/skillchip/bci/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(action_comp_registered))
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(action_comp_unregistered))

	circuit = new(src)
	circuit.add_component(new /obj/item/circuit_component/equipment_action(null, "One"))

	bci_component = new()

	AddComponent(/datum/component/shell, list(
		bci_component,
	), SHELL_CAPACITY_SMALL, starting_circuit = circuit)

/obj/item/skillchip/bci/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	var/mob/living/owner = holding_brain.owner
	if (!owner)
		owner = holding_brain.brainmob
		if(!owner)
			return ..()
		// Otherwise say_dead will be called.
		// It's intentional that a circuit for a dead person does not speak from the shell.
	if ((holding_brain.owner.stat == DEAD))
		if(!(holding_brain.brainmob?.health > HEALTH_THRESHOLD_DEAD))
			return

	forced = "circuit speech"
	return owner.say(arglist(args))

/obj/item/skillchip/bci/on_activate(mob/living/carbon/user, silent)
	. = ..()
	bci_component.on_skillchip_activated(holding_brain)

/obj/item/skillchip/bci/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	bci_component.on_skillchip_deactivated(holding_brain)

/obj/item/skillchip/bci/proc/action_comp_registered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	LAZYADD(actions, new/datum/action/innate/circuit_equipment_action(src, action_comp))

/obj/item/skillchip/bci/proc/action_comp_unregistered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/circuit_equipment_action/action = action_comp.granted_to[REF(src)]
	if(!istype(action))
		return
	LAZYREMOVE(actions, action)
	QDEL_LIST_ASSOC_VAL(action_comp.granted_to)

/obj/item/circuit_component/bci_core
	display_name = "BCI Core"
	desc = "Controls the core operations of the BCI."

	/// A reference to the action button to look at charge/get info
	var/datum/action/innate/bci_charge_action/charge_action

	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/show_charge_meter

	var/datum/port/output/user_port

	var/obj/item/skillchip/bci/bci

/obj/item/circuit_component/bci_core/populate_ports()

	message = add_input_port("Message", PORT_TYPE_STRING, trigger = null)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	show_charge_meter = add_input_port("Show Charge Meter", PORT_TYPE_BOOLEAN, trigger = PROC_REF(update_charge_action))

	user_port = add_output_port("User", PORT_TYPE_USER)

/obj/item/circuit_component/bci_core/Destroy()
	QDEL_NULL(charge_action)
	return ..()

/obj/item/circuit_component/bci_core/proc/update_charge_action()
	CIRCUIT_TRIGGER
	if (show_charge_meter.value)
		if (charge_action)
			return
		charge_action = new(src)
		if (bci.holding_brain?.owner)
			charge_action.Grant(bci.holding_brain.owner)
		bci.actions += charge_action
	else
		if (!charge_action)
			return
		if (bci.holding_brain?.owner)
			charge_action.Remove(bci.holding_brain.owner)
		bci.actions -= charge_action
		QDEL_NULL(charge_action)

/obj/item/circuit_component/bci_core/register_shell(atom/movable/shell)
	bci = shell

	show_charge_meter.set_value(TRUE)

/obj/item/circuit_component/bci_core/unregister_shell(atom/movable/shell)
	bci = shell

	if (charge_action)
		if (bci.holding_brain?.owner)
			charge_action.Remove(bci.holding_brain.owner)
		bci.actions -= charge_action
		QDEL_NULL(charge_action)


/obj/item/circuit_component/bci_core/input_received(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(send_message_signal, port))
		return

	var/sent_message = trim(message.value)
	if (!sent_message)
		return

	var/mob/living/owner = bci.holding_brain?.owner
	if (isnull(owner) || owner.stat == DEAD)
		owner = bci.holding_brain?.brainmob
		if(isnull(owner))
			return

	to_chat(owner, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/bci_core/proc/on_skillchip_activated(obj/item/organ/brain/holding_brain)
	update_charge_action()

	var/owner = holding_brain.owner
	if(!owner)
		owner = holding_brain.brainmob
		RegisterSignal(holding_brain, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	else
		RegisterSignal(holding_brain, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

	set_up_new_mob(owner)

/obj/item/circuit_component/bci_core/proc/on_skillchip_deactivated(obj/item/organ/brain/holding_brain)
	user_port.set_output(null)
	UnregisterSignal(bci.controlled_mob?.resolve(), list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_LIVING_ELECTROCUTE_ACT,
	))
	UnregisterSignal(holding_brain, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))


/obj/item/circuit_component/bci_core/proc/on_organ_implanted(obj/item/organ/brain/holding_brain, mob/living/carbon/new_owner)
	SIGNAL_HANDLER
	set_up_new_mob(new_owner)

/obj/item/circuit_component/bci_core/proc/on_organ_removed(obj/item/organ/brain/holding_brain, mob/living/carbon/old_owner)
	SIGNAL_HANDLER
	set_up_new_mob(holding_brain.brainmob)

///Set up a new mob for us, and cleans up the old mob.
/obj/item/circuit_component/bci_core/proc/set_up_new_mob(mob/newguy)
	if(bci.controlled_mob)
		UnregisterSignal(bci.controlled_mob.resolve(), list(
			COMSIG_ATOM_EXAMINE,
			COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
			COMSIG_LIVING_ELECTROCUTE_ACT,
		))
	bci.controlled_mob = WEAKREF(newguy)
	user_port.set_output(newguy)
	RegisterSignal(newguy, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(newguy, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(newguy, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/circuit_component/bci_core/proc/on_borg_charge(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return

	charge_cell.Invoke(parent.cell, seconds_per_tick)

/obj/item/circuit_component/bci_core/proc/on_electrocute(datum/source, shock_damage, shock_source, siemens_coefficient, flags)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return

	if (flags & SHOCK_ILLUSION)
		return

	parent.cell.give(shock_damage * 2)
	to_chat(source, span_notice("You absorb some of the shock into your [parent.name]!"))

/obj/item/circuit_component/bci_core/proc/on_examine(datum/source, mob/mob, list/examine_text)
	SIGNAL_HANDLER

	if (isobserver(mob))
		examine_text += span_notice("[source.p_They()] [source.p_have()] <a href='byond://?src=[REF(src)];open_bci=1'>\a [parent] implanted in [source.p_them()]</a>.")

/obj/item/circuit_component/bci_core/Topic(href, list/href_list)
	..()

	if (!isobserver(usr))
		return

	if (href_list["open_bci"])
		parent.attack_ghost(usr)

/datum/action/innate/bci_charge_action
	name = "Check BCI Charge"
	check_flags = NONE
	button_icon = 'icons/obj/machines/cell_charger.dmi'
	button_icon_state = "cell"

	var/obj/item/circuit_component/bci_core/circuit_component

/datum/action/innate/bci_charge_action/New(obj/item/circuit_component/bci_core/circuit_component)
	..()

	src.circuit_component = circuit_component

	build_all_button_icons()

	START_PROCESSING(SSobj, src)

/datum/action/innate/bci_charge_action/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext_x = 2
	button.maptext_y = 0
	return button

/datum/action/innate/bci_charge_action/Destroy()
	circuit_component.charge_action = null
	circuit_component = null

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/action/innate/bci_charge_action/Trigger(mob/clicker, trigger_flags)
	var/obj/item/stock_parts/power_store/cell/cell = circuit_component.parent.cell

	if (isnull(cell))
		to_chat(owner, span_boldwarning("[circuit_component.parent] has no power cell."))
	else
		to_chat(owner, span_info("[circuit_component.parent]'s [cell.name] has <b>[cell.percent()]%</b> charge left."))
		to_chat(owner, span_info("You can recharge it by using a cyborg recharging station."))

/datum/action/innate/bci_charge_action/process(seconds_per_tick)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/innate/bci_charge_action/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/obj/item/stock_parts/power_store/cell/cell = circuit_component.parent.cell
	button.maptext = cell ? MAPTEXT("[cell.percent()]%") : ""
