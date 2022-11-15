/**
 * # Man-Machine Interface Component
 *
 * Allows an MMI to be inserted into a shell, allowing it to be linked up. Requires a shell.
 */
/obj/item/circuit_component/mmi
	display_name = "Man-Machine Interface"
	desc = "A component that allows MMI to enter shells to send output signals."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_REFUSE_MODULE

	/// The message to send to the MMI in the shell.
	var/datum/port/input/message
	/// Sends the current MMI a message
	var/datum/port/input/send
	/// Ejects the current MMI
	var/datum/port/input/eject

	/// Called when the MMI tries moving north
	var/datum/port/output/north
	/// Called when the MMI tries moving east
	var/datum/port/output/east
	/// Called when the MMI tries moving south
	var/datum/port/output/south
	/// Called when the MMI tries moving west
	var/datum/port/output/west

	/// Returns what the MMI last clicked on.
	var/datum/port/output/clicked_atom
	/// Called when the MMI clicks.
	var/datum/port/output/attack
	/// Called when the MMI right clicks.
	var/datum/port/output/secondary_attack

	/// The current MMI card
	var/obj/item/mmi/brain

	/// Maximum length of the message that can be sent to the MMI
	var/max_length = 300

/obj/item/circuit_component/mmi/populate_ports()
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

/obj/item/circuit_component/mmi/Destroy()
	remove_current_brain()
	return ..()

/obj/item/circuit_component/mmi/input_received(datum/port/input/port)

	if(!brain)
		return

	if(COMPONENT_TRIGGERED_BY(eject, port))
		remove_current_brain()
	if(COMPONENT_TRIGGERED_BY(send, port))
		if(!message.value)
			return

		var/msg_str = copytext(html_encode(message.value), 1, max_length)

		var/mob/living/target = brain.brainmob
		if(!target)
			return

		to_chat(target, "[span_bold("You hear a message in your ear: ")][msg_str]")


/obj/item/circuit_component/mmi/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_PARENT_ATTACKBY, PROC_REF(handle_attack_by))

/obj/item/circuit_component/mmi/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PARENT_ATTACKBY)
	remove_current_brain()
	return ..()

/obj/item/circuit_component/mmi/proc/handle_attack_by(atom/movable/shell, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(istype(item, /obj/item/mmi))
		var/obj/item/mmi/target_mmi = item
		if(!target_mmi.brainmob)
			return
		add_mmi(item)
		return COMPONENT_NO_AFTERATTACK

/obj/item/circuit_component/mmi/proc/add_mmi(obj/item/mmi/to_add)
	remove_current_brain()

	to_add.forceMove(src)
	if(to_add.brainmob)
		update_mmi_mob(to_add, null, to_add.brainmob)
	brain = to_add
	RegisterSignal(to_add, COMSIG_PARENT_QDELETING, PROC_REF(remove_current_brain))
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, PROC_REF(mmi_moved))

/obj/item/circuit_component/mmi/proc/mmi_moved(atom/movable/mmi)
	SIGNAL_HANDLER

	if(mmi.loc != src)
		remove_current_brain()

/obj/item/circuit_component/mmi/proc/remove_current_brain()
	SIGNAL_HANDLER
	if(!brain)
		return

	if(brain.brainmob)
		update_mmi_mob(brain, brain.brainmob)
	UnregisterSignal(brain, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_MOVABLE_MOVED
	))
	if(brain.loc == src)
		brain.forceMove(drop_location())
	brain = null

/obj/item/circuit_component/mmi/proc/update_mmi_mob(datum/source, mob/living/old_mmi, mob/living/new_mmi)
	SIGNAL_HANDLER
	if(old_mmi)
		old_mmi.remote_control = null
		UnregisterSignal(old_mmi, COMSIG_MOB_CLICKON)
	if(new_mmi)
		new_mmi.remote_control = src
		RegisterSignal(new_mmi, COMSIG_MOB_CLICKON, PROC_REF(handle_mmi_attack))

/obj/item/circuit_component/mmi/relaymove(mob/living/user, direct)
	if(user != brain.brainmob)
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

/obj/item/circuit_component/mmi/proc/handle_mmi_attack(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(modifiers[RIGHT_CLICK])
		clicked_atom.set_output(target)
		secondary_attack.set_output(COMPONENT_SIGNAL)
		. = COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[LEFT_CLICK] && !modifiers[SHIFT_CLICK] && !modifiers[ALT_CLICK] && !modifiers[CTRL_CLICK])
		clicked_atom.set_output(target)
		attack.set_output(COMPONENT_SIGNAL)
		. = COMSIG_MOB_CANCEL_CLICKON

/obj/item/circuit_component/mmi/add_to(obj/item/integrated_circuit/add_to)
	. = ..()
	if(HAS_TRAIT(add_to, TRAIT_COMPONENT_MMI))
		return FALSE
	ADD_TRAIT(add_to, TRAIT_COMPONENT_MMI, REF(src))

/obj/item/circuit_component/mmi/removed_from(obj/item/integrated_circuit/removed_from)
	REMOVE_TRAIT(removed_from, TRAIT_COMPONENT_MMI, REF(src))
	remove_current_brain()
	return ..()
