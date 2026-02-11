/obj/item/implant/circuit
	name = "circuit implant"
	actions_types = null

	implant_info = "Functions as a shell for integrated circuits. Activation conditions and effects are defined by the installed circuit."

	implant_lore = "The Subdermal Circuit Housing is a common implant design manufactured primarily by DIY electronics enthusiasts. \
	Similar in concept to Brain-Computer Interfaces, these devices accept an integrated circuit, and support components that allow the \
	user to trigger other installed components. What it gains in the ability to be implanted in non-humanoid hosts, it loses in physical \
	capacity and support for various neural interfacing capabilities."

/obj/item/implant/circuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(/obj/item/circuit_component/implant_core), SHELL_CAPACITY_TINY)
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(action_comp_registered))
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(action_comp_unregistered))
	RegisterSignal(src, COMSIG_IMPLANT_OTHER, PROC_REF(on_new_implant))

/obj/item/implant/circuit/proc/action_comp_registered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	LAZYADD(actions, new/datum/action/innate/circuit_equipment_action(src, action_comp))

/obj/item/implant/circuit/proc/action_comp_unregistered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/circuit_equipment_action/action = action_comp.granted_to[REF(src)]
	if(!istype(action))
		return
	LAZYREMOVE(actions, action)
	QDEL_LIST_ASSOC_VAL(action_comp.granted_to)

/obj/item/implant/circuit/proc/on_new_implant(obj/item/implant/source, list/arguments, obj/item/implant/other_implant)
	if(!istype(other_implant, /obj/item/implant/circuit))
		return
	var/mob/living/user = arguments[2]
	var/force = arguments[4]
	if(!force)
		source.balloon_alert(user, "duplicate implant present!")
		return COMPONENT_STOP_IMPLANTING

/obj/item/implant/circuit/ui_host(mob/user)
	if(istype(loc, /obj/item/implantcase))
		return loc
	return ..()

/obj/item/circuit_component/implant_core
	display_name = "Implant Core"
	desc = "Controls the core operations of the implant."

	/// A reference to the action button to look at charge/get info
	var/datum/action/innate/implant_charge_action/charge_action

	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/show_charge_meter

	var/datum/port/output/user_port

	var/obj/item/implant/implant

/obj/item/circuit_component/implant_core/populate_ports()

	message = add_input_port("Message", PORT_TYPE_STRING, trigger = null)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	show_charge_meter = add_input_port("Show Charge Meter", PORT_TYPE_NUMBER, trigger = PROC_REF(update_charge_action))

	user_port = add_output_port("User", PORT_TYPE_USER)

/obj/item/circuit_component/implant_core/Destroy()
	QDEL_NULL(charge_action)
	return ..()

/obj/item/circuit_component/implant_core/proc/update_charge_action()
	CIRCUIT_TRIGGER
	if (show_charge_meter.value)
		if (charge_action)
			return
		charge_action = new(src)
		if (implant.imp_in)
			charge_action.Grant(implant.imp_in)
		implant.actions += charge_action
	else
		if (!charge_action)
			return
		if (implant.imp_in)
			charge_action.Remove(implant.imp_in)
		implant.actions -= charge_action
		QDEL_NULL(charge_action)

/obj/item/circuit_component/implant_core/register_shell(atom/movable/shell)
	implant = shell

	show_charge_meter.set_value(TRUE)

	RegisterSignal(shell, COMSIG_IMPLANT_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(shell, COMSIG_IMPLANT_REMOVED, PROC_REF(on_removed))

/obj/item/circuit_component/implant_core/unregister_shell(atom/movable/shell)
	implant = null

	if (charge_action)
		if (implant.imp_in)
			charge_action.Remove(implant.imp_in)
		implant.actions -= charge_action
		QDEL_NULL(charge_action)

	UnregisterSignal(shell, list(
		COMSIG_IMPLANT_IMPLANTED,
		COMSIG_IMPLANT_REMOVED,
	))

/obj/item/circuit_component/implant_core/proc/on_implanted(datum/source, mob/living/owner)
	SIGNAL_HANDLER

	update_charge_action()

	user_port.set_output(owner)

	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/circuit_component/implant_core/proc/on_removed(datum/source, mob/living/owner)
	SIGNAL_HANDLER

	user_port.set_output(null)

	UnregisterSignal(owner, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_LIVING_ELECTROCUTE_ACT,
	))

/obj/item/circuit_component/implant_core/input_received(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(send_message_signal, port))
		return

	var/sent_message = trim(message.value)
	if (!sent_message)
		return

	if (isnull(implant.imp_in))
		return

	if (implant.imp_in.stat == DEAD)
		return

	to_chat(implant.imp_in, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/implant_core/proc/on_borg_charge(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return

	charge_cell.Invoke(parent.cell, seconds_per_tick)

/obj/item/circuit_component/implant_core/proc/on_electrocute(datum/source, shock_damage, shock_source, siemens_coefficient, flags)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return

	if (flags & SHOCK_ILLUSION)
		return

	parent.cell.give(shock_damage * 2)
	to_chat(source, span_notice("You absorb some of the shock into your [parent.name]!"))

/obj/item/circuit_component/implant_core/proc/on_examine(datum/source, mob/mob, list/examine_text)
	SIGNAL_HANDLER

	if (isobserver(mob))
		examine_text += span_notice("[source.p_They()] [source.p_have()] <a href='byond://?src=[REF(src)];open_implant=1'>\a [parent] implanted in [source.p_them()]</a>.")

/obj/item/circuit_component/implant_core/Topic(href, list/href_list)
	..()

	if (!isobserver(usr))
		return

	if (href_list["open_implant"])
		parent.attack_ghost(usr)

/datum/action/innate/implant_charge_action
	name = "Check Implant Charge"
	check_flags = NONE
	button_icon = 'icons/obj/machines/cell_charger.dmi'
	button_icon_state = "cell"

	var/obj/item/circuit_component/implant_core/circuit_component

/datum/action/innate/implant_charge_action/New(obj/item/circuit_component/implant_core/circuit_component)
	..()

	src.circuit_component = circuit_component

	build_all_button_icons()

	START_PROCESSING(SSobj, src)

/datum/action/innate/implant_charge_action/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext_x = 2
	button.maptext_y = 0
	return button

/datum/action/innate/implant_charge_action/Destroy()
	circuit_component.charge_action = null
	circuit_component = null

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/action/innate/implant_charge_action/Trigger(mob/clicker, trigger_flags)
	var/obj/item/stock_parts/power_store/cell/cell = circuit_component.parent.cell

	if (isnull(cell))
		to_chat(owner, span_boldwarning("[circuit_component.parent] has no power cell."))
	else
		to_chat(owner, span_info("[circuit_component.parent]'s [cell.name] has <b>[cell.percent()]%</b> charge left."))
		to_chat(owner, span_info("You can recharge it by using a cyborg recharging station."))

/datum/action/innate/implant_charge_action/process(seconds_per_tick)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/innate/implant_charge_action/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/obj/item/stock_parts/power_store/cell/cell = circuit_component.parent.cell
	button.maptext = cell ? MAPTEXT("[cell.percent()]%") : ""

/obj/item/implantcase/circuit
	name = "implant case - 'Circuit'"
	desc = "A glass case containing a circuit implant shell."
	imp_type = /obj/item/implant/circuit
