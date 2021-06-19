/**
 * # pAI Component
 *
 * Allows a pAI to be inserted into a shell, allowing it to be linked up. Requires a shell.
 */
/obj/item/circuit_component/pai
	display_name = "pAI"

	/// The message to send to the pAI in the shell.
	var/datum/port/input/message
	/// Sends the current pAI a message
	var/datum/port/input/send
	/// Ejects the current pAI
	var/datum/port/input/eject

	/// Called when the pAI tries moving north
	var/datum/port/output/north
	/// Called when the pAI tries moving east
	var/datum/port/output/east
	/// Called when the pAI tries moving south
	var/datum/port/output/south
	/// Called when the pAI tries moving west
	var/datum/port/output/west

	/// Returns what the pAI last clicked on.
	var/datum/port/output/clicked_atom
	/// Called when the pAI clicks.
	var/datum/port/output/attack
	/// Called when the pAI right clicks.
	var/datum/port/output/secondary_attack

	/// The current pAI card
	var/obj/item/paicard/paicard

	/// Maximum length of the message that can be sent to the pAI
	var/max_length = 300

/obj/item/circuit_component/pai/Initialize()
	. = ..()
	message = add_input_port("Message", PORT_TYPE_STRING)
	send = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	eject = add_input_port("Eject", PORT_TYPE_SIGNAL)

	north = add_output_port("North", PORT_TYPE_SIGNAL)
	east = add_output_port("East", PORT_TYPE_SIGNAL)
	south = add_output_port("South", PORT_TYPE_SIGNAL)
	west = add_output_port("West", PORT_TYPE_SIGNAL)

	attack = add_output_port("Attack", PORT_TYPE_SIGNAL)
	secondary_attack = add_output_port("Secondary Attack", PORT_TYPE_SIGNAL)
	clicked_atom = add_output_port("Target Entity", PORT_TYPE_ATOM)

/obj/item/circuit_component/pai/Destroy()
	remove_current_pai()
	message = null
	send = null
	eject = null
	north = null
	east = null
	south = null
	west = null
	attack = null
	secondary_attack = null
	clicked_atom = null
	return ..()

/obj/item/circuit_component/pai/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!paicard)
		return

	if(COMPONENT_TRIGGERED_BY(eject, port))
		remove_current_pai()
	if(COMPONENT_TRIGGERED_BY(send, port))
		if(!message.input_value)
			return

		var/msg_str = copytext(html_encode(message.input_value), 1, max_length)

		var/mob/living/target = paicard.pai
		if(!target)
			return

		to_chat(target, "[span_bold("You hear a message in your ear: ")][msg_str]")


/obj/item/circuit_component/pai/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_PARENT_ATTACKBY, .proc/handle_attack_by)

/obj/item/circuit_component/pai/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PARENT_ATTACKBY)
	remove_current_pai()
	return ..()

/obj/item/circuit_component/pai/proc/handle_attack_by(atom/movable/shell, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(istype(item, /obj/item/paicard))
		add_pai(item)

/obj/item/circuit_component/pai/proc/add_pai(obj/item/paicard/to_add)
	remove_current_pai()

	to_add.forceMove(src)
	if(to_add.pai)
		update_pai_mob(to_add, null, to_add.pai)
	paicard = to_add
	RegisterSignal(to_add, COMSIG_PARENT_QDELETING, .proc/remove_current_pai)
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, .proc/pai_moved)

/obj/item/circuit_component/pai/proc/pai_moved(atom/movable/pai)
	if(pai.loc != src)
		remove_current_pai()

/obj/item/circuit_component/pai/proc/remove_current_pai()
	SIGNAL_HANDLER
	if(!paicard)
		return

	if(paicard.pai)
		update_pai_mob(paicard, paicard.pai)
	UnregisterSignal(paicard, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_MOVABLE_MOVED
	))
	if(paicard.loc == src)
		paicard.forceMove(drop_location())
	paicard = null

/obj/item/circuit_component/pai/proc/update_pai_mob(datum/source, mob/living/old_pai, mob/living/new_pai)
	SIGNAL_HANDLER
	if(old_pai)
		old_pai.remote_control = null
		UnregisterSignal(old_pai, COMSIG_MOB_CLICKON)
	if(new_pai)
		new_pai.remote_control = src
		RegisterSignal(new_pai, COMSIG_MOB_CLICKON, .proc/handle_pai_attack)

/obj/item/circuit_component/pai/relaymove(mob/living/user, direct)
	if(user != paicard.pai)
		return ..()

	if(direct & NORTH)
		north.set_output(COMPONENT_SIGNAL)
	if(direct & WEST)
		west.set_output(COMPONENT_SIGNAL)
	if(direct & EAST)
		east.set_output(COMPONENT_SIGNAL)
	if(direct & SOUTH)
		south.set_output(COMPONENT_SIGNAL)

	return TRUE

/obj/item/circuit_component/pai/proc/handle_pai_attack(mob/living/source, atom/target, list/mods)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(mods)
	if(modifiers[RIGHT_CLICK])
		clicked_atom.set_output(target)
		secondary_attack.set_output(COMPONENT_SIGNAL)
		. = COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[LEFT_CLICK] && !modifiers[SHIFT_CLICK] && !modifiers[ALT_CLICK] && !modifiers[CTRL_CLICK])
		clicked_atom.set_output(target)
		attack.set_output(COMPONENT_SIGNAL)
		. = COMSIG_MOB_CANCEL_CLICKON

/obj/item/circuit_component/pai/add_to(obj/item/integrated_circuit/add_to)
	. = ..()
	if(HAS_TRAIT(add_to, TRAIT_COMPONENT_PAI))
		return FALSE
	ADD_TRAIT(add_to, TRAIT_COMPONENT_PAI, src)

/obj/item/circuit_component/pai/removed_from(obj/item/integrated_circuit/removed_from)
	REMOVE_TRAIT(removed_from, TRAIT_COMPONENT_PAI, src)
	remove_current_pai()
	return ..()
