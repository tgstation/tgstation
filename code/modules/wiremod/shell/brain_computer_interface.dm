/obj/item/organ/cyberimp/bci
	name = "brain-computer interface"
	desc = "An implant that can be placed in a user's head to control circuits using their brain."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "bci"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/bci/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(action_comp_registered))
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(action_comp_unregistered))

	var/obj/item/integrated_circuit/circuit = new(src)
	circuit.add_component(new /obj/item/circuit_component/equipment_action(null, "One"))

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bci_core,
	), SHELL_CAPACITY_SMALL, starting_circuit = circuit)

/obj/item/organ/cyberimp/bci/say(
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
	if (owner)
		// Otherwise say_dead will be called.
		// It's intentional that a circuit for a dead person does not speak from the shell.
		if (owner.stat == DEAD)
			return

		forced = "circuit speech"
		return owner.say(arglist(args))

	return ..()

/obj/item/organ/cyberimp/bci/proc/action_comp_registered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	LAZYADD(actions, new/datum/action/innate/bci_action(src, action_comp))

/obj/item/organ/cyberimp/bci/proc/action_comp_unregistered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/bci_action/action = action_comp.granted_to[REF(src)]
	if(!istype(action))
		return
	LAZYREMOVE(actions, action)
	QDEL_LIST_ASSOC_VAL(action_comp.granted_to)

/datum/action/innate/bci_action
	name = "Action"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "bci_power"

	var/obj/item/organ/cyberimp/bci/bci
	var/obj/item/circuit_component/equipment_action/circuit_component

/datum/action/innate/bci_action/New(obj/item/organ/cyberimp/bci/_bci, obj/item/circuit_component/equipment_action/circuit_component)
	..()
	bci = _bci
	circuit_component.granted_to[REF(_bci)] = src
	src.circuit_component = circuit_component

/datum/action/innate/bci_action/Destroy()
	circuit_component.granted_to -= REF(bci)
	circuit_component = null

	return ..()

/datum/action/innate/bci_action/Activate()
	circuit_component.user.set_output(owner)
	circuit_component.signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/bci_core
	display_name = "BCI Core"
	desc = "Controls the core operations of the BCI."

	/// A reference to the action button to look at charge/get info
	var/datum/action/innate/bci_charge_action/charge_action

	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/show_charge_meter

	var/datum/port/output/user_port

	var/obj/item/organ/cyberimp/bci/bci

/obj/item/circuit_component/bci_core/populate_ports()

	message = add_input_port("Message", PORT_TYPE_STRING, trigger = null)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	show_charge_meter = add_input_port("Show Charge Meter", PORT_TYPE_NUMBER, trigger = PROC_REF(update_charge_action))

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
		if (bci.owner)
			charge_action.Grant(bci.owner)
		bci.actions += charge_action
	else
		if (!charge_action)
			return
		if (bci.owner)
			charge_action.Remove(bci.owner)
		bci.actions -= charge_action
		QDEL_NULL(charge_action)

/obj/item/circuit_component/bci_core/register_shell(atom/movable/shell)
	bci = shell

	show_charge_meter.set_value(TRUE)

	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/bci_core/unregister_shell(atom/movable/shell)
	bci = shell

	if (charge_action)
		if (bci.owner)
			charge_action.Remove(bci.owner)
		bci.actions -= charge_action
		QDEL_NULL(charge_action)

	UnregisterSignal(shell, list(
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/bci_core/input_received(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(send_message_signal, port))
		return

	var/sent_message = trim(message.value)
	if (!sent_message)
		return

	if (isnull(bci.owner))
		return

	if (bci.owner.stat == DEAD)
		return

	to_chat(bci.owner, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/bci_core/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	update_charge_action()

	user_port.set_output(owner)

	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/circuit_component/bci_core/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	user_port.set_output(null)

	UnregisterSignal(owner, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_LIVING_ELECTROCUTE_ACT,
	))

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

/datum/action/innate/bci_charge_action/Trigger(trigger_flags)
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

/obj/machinery/bci_implanter
	name = "brain-computer interface manipulation chamber"
	desc = "A machine that, when given a brain-computer interface, will implant it into an occupant. Otherwise, will remove any brain-computer interfaces they already have."
	circuit = /obj/item/circuitboard/machine/bci_implanter
	icon = 'icons/obj/machines/bci_implanter.dmi'
	icon_state = "bci_implanter"
	base_icon_state = "bci_implanter"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	density = TRUE
	obj_flags = BLOCKS_CONSTRUCTION // Becomes undense when the door is open

	var/busy = FALSE
	var/busy_icon_state
	var/locked = FALSE

	var/obj/item/organ/cyberimp/bci/bci_to_implant

	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/bci_implanter/Initialize(mapload)
	. = ..()
	occupant_typecache = typecacheof(/mob/living/carbon)

/obj/machinery/bci_implanter/on_deconstruction(disassembled)
	drop_stored_bci()

/obj/machinery/bci_implanter/Destroy()
	qdel(bci_to_implant)
	return ..()

/obj/machinery/bci_implanter/examine(mob/user)
	. = ..()
	if (isnull(bci_to_implant))
		. += span_notice("There is no BCI inserted.")
	else
		. += span_notice("Right-click to remove current BCI.")

/obj/machinery/bci_implanter/proc/set_busy(status, working_icon)
	busy = status
	busy_icon_state = working_icon
	update_appearance()

/obj/machinery/bci_implanter/update_icon_state()
	if (occupant)
		icon_state = busy ? busy_icon_state : "[base_icon_state]_occupied"
		return ..()
	icon_state = "[base_icon_state][state_open ? "_open" : null]"
	return ..()

/obj/machinery/bci_implanter/update_overlays()
	var/list/overlays = ..()

	if ((machine_stat & MAINT) || panel_open)
		overlays += "maint"
		return overlays

	if (machine_stat & (NOPOWER|BROKEN))
		return overlays

	if (busy || locked)
		overlays += "red"
		if (locked)
			overlays += "bolted"
		return overlays

	overlays += "green"

	return overlays

/obj/machinery/bci_implanter/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if (. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .

	if(!user.Adjacent(src))
		return

	if (locked)
		balloon_alert(user, "it's locked!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if (isnull(bci_to_implant))
		balloon_alert(user, "no bci inserted!")
	else
		user.put_in_hands(bci_to_implant)
		balloon_alert(user, "ejected bci")

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/bci_implanter/attackby(obj/item/weapon, mob/user, params)
	var/obj/item/organ/cyberimp/bci/new_bci = weapon
	if (istype(new_bci))
		if (!(locate(/obj/item/integrated_circuit) in new_bci))
			balloon_alert(user, "bci has no circuit!")
			return

		var/obj/item/organ/cyberimp/bci/previous_bci_to_implant = bci_to_implant

		user.transferItemToLoc(weapon, src)
		bci_to_implant = weapon

		if (isnull(previous_bci_to_implant))
			balloon_alert(user, "inserted bci")
		else
			balloon_alert(user, "swapped bci")
			user.put_in_hands(previous_bci_to_implant)

		return

	return ..()

/obj/machinery/bci_implanter/attackby_secondary(obj/item/weapon, mob/user, params)
	if (!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
		update_appearance()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if (default_pry_open(weapon, close_after_pry = FALSE, open_density = FALSE, closed_density = TRUE))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if (default_deconstruction_crowbar(weapon))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/bci_implanter/proc/start_process()
	if (machine_stat & (NOPOWER|BROKEN))
		return
	if ((machine_stat & MAINT) || panel_open)
		return
	if (!occupant || busy)
		return

	update_use_power(ACTIVE_POWER_USE)

	var/locked_state = locked
	locked = TRUE

	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_process), locked_state), 3 SECONDS)

/obj/machinery/bci_implanter/proc/complete_process(locked_state)
	update_use_power(IDLE_POWER_USE)
	locked = locked_state
	set_busy(FALSE)

	var/mob/living/carbon/carbon_occupant = occupant
	if (!istype(carbon_occupant))
		return

	playsound(loc, 'sound/machines/ping.ogg', 30, FALSE)

	var/obj/item/organ/cyberimp/bci/bci_organ = carbon_occupant.get_organ_by_type(/obj/item/organ/cyberimp/bci)

	if (bci_organ)
		bci_organ.Remove(carbon_occupant)

		if (isnull(bci_to_implant))
			say("Occupant's previous brain-computer interface has been transferred to internal storage unit.")
			carbon_occupant.transferItemToLoc(bci_organ, src)
			bci_to_implant = bci_organ
		else
			say("Occupant's previous brain-computer interface has been ejected.")
			bci_organ.forceMove(drop_location())
	else if (!isnull(bci_to_implant))
		say("Occupant has been injected with [bci_to_implant].")
		bci_to_implant.Insert(carbon_occupant)

/obj/machinery/bci_implanter/open_machine(drop = TRUE, density_to_set = FALSE)
	if(state_open)
		return FALSE

	..()

	return TRUE

/obj/machinery/bci_implanter/close_machine(mob/living/carbon/user, density_to_set = TRUE)
	if(!state_open)
		return FALSE

	..()

	var/mob/living/carbon/carbon_occupant = occupant
	if (istype(occupant))
		var/obj/item/organ/cyberimp/bci/bci_organ = carbon_occupant.get_organ_by_type(/obj/item/organ/cyberimp/bci)
		if (isnull(bci_organ) && isnull(bci_to_implant))
			say("No brain-computer interface inserted, and occupant does not have one. Insert a BCI to implant one.")
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
			return FALSE

	addtimer(CALLBACK(src, PROC_REF(start_process)), 1 SECONDS)
	return TRUE

/obj/machinery/bci_implanter/relaymove(mob/living/user, direction)
	var/message

	if (locked)
		message = "it won't budge!"
	else if (user.stat != CONSCIOUS)
		message = "you don't have the energy!"

	if (!isnull(message))
		if (COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
			balloon_alert(user, message)

		return

	open_machine()

/obj/machinery/bci_implanter/interact(mob/user)
	if (state_open)
		close_machine(null, user)
		return
	else if (locked)
		balloon_alert(user, "it's locked!")
		return

	open_machine()

/obj/machinery/bci_implanter/proc/drop_stored_bci()
	if (isnull(bci_to_implant))
		return
	bci_to_implant.forceMove(drop_location())

/obj/machinery/bci_implanter/dump_inventory_contents(list/subset)
	// Prevents opening the machine dropping the BCI.
	// "dump_contents()" still drops the BCI.
	return ..(contents - bci_to_implant)

/obj/machinery/bci_implanter/Exited(atom/movable/gone, direction)
	if (gone == bci_to_implant)
		bci_to_implant = null
	return ..()

/obj/item/circuitboard/machine/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/bci_implanter
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/servo = 1,
	)
