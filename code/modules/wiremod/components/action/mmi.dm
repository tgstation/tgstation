#define MMI_MESSAGE_COOLDOWN (0.1 SECONDS)

/datum/action/innate/mmi_comp_disconnect
	name = "Disconnect from remote circuit"
	desc = "Stop controlling an integrated circuit"
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/mmi_comp_disconnect/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/circuit_component/mmi/mmi_comp = target
	mmi_comp.remove_occupant()

/**
 * # Man-Machine Interface Component
 *
 * Allows an MMI to be inserted into a shell, allowing it to be linked up. Requires a shell.
 */
/obj/item/circuit_component/mmi
	display_name = "Man-Machine Interface"
	desc = "A component that allows an MMI or B.O.R.I.S. module to be inserted into the shell, allowing a brain or artificial intelligence to output signals."
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

	/// The current MMI/posibrain
	var/obj/item/mmi/brain

	/// The current B.O.R.I.S. module
	var/obj/item/borg/upgrade/ai/boris

	/// The brainmob or AI currently controlling to the circuit
	var/mob/living/occupant

	/// The action used to allow a connected AI to disconnect
	var/datum/action/innate/mmi_comp_disconnect/disconnect_action

	/// Maximum length of the message that can be sent to the MMI
	var/max_length = 300

	/// Cooldown for when the next message can be sent to the MMI.
	COOLDOWN_DECLARE(message_cooldown)

/obj/item/circuit_component/mmi/Initialize(mapload)
	. = ..()
	disconnect_action = new(src)

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
	remove_occupant_item()
	QDEL_NULL(disconnect_action)
	return ..()

/obj/item/circuit_component/mmi/input_received(datum/port/input/port)

	if(!brain && !boris)
		return

	if(COMPONENT_TRIGGERED_BY(eject, port))
		remove_occupant_item()
	if(COMPONENT_TRIGGERED_BY(send, port))
		if(!message.value || !COOLDOWN_FINISHED(src, message_cooldown))
			return

		var/msg_str = copytext(html_encode(message.value), 1, max_length)

		if(!occupant)
			return

		if(isAI(occupant))
			to_chat(occupant, "[span_boldnotice("Message from remote circuit: ")][span_notice(msg_str)]")
		else
			to_chat(occupant, "[span_bold("You hear a message: ")][msg_str]")
		COOLDOWN_START(src, message_cooldown, MMI_MESSAGE_COOLDOWN)


/obj/item/circuit_component/mmi/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(handle_interaction))
	RegisterSignal(shell, COMSIG_ATOM_ATTACK_AI, PROC_REF(shell_attack_ai))

/obj/item/circuit_component/mmi/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_CLICK))
	remove_occupant_item()
	return ..()

/obj/item/circuit_component/mmi/proc/handle_interaction(atom/movable/shell, mob/living/user, obj/item/item)
	SIGNAL_HANDLER
	var/obj/item/mmi/target_mmi
	var/mob/living/new_occupant
	var/obj/item/borg/upgrade/ai/target_boris
	if(istype(item, /obj/item/mmi))
		target_mmi = item
		if(!target_mmi.brainmob)
			shell.balloon_alert(user, "no consciousness detected!")
			return ITEM_INTERACT_FAILURE
		new_occupant = target_mmi.brainmob
	else if(istype(item, /obj/item/borg/upgrade/ai))
		target_boris = item
	else
		return
	var/datum/component/shell/shell_comp = shell.GetComponent(/datum/component/shell)
	if(shell_comp.locked)
		shell.balloon_alert(user, "locked!")
		return ITEM_INTERACT_FAILURE
	if(brain || boris)
		shell.balloon_alert(user, "already has brain!")
		return ITEM_INTERACT_FAILURE
	if(!user.transferItemToLoc(item, src))
		return ITEM_INTERACT_FAILURE
	if(target_mmi)
		brain = target_mmi
		set_occupant(new_occupant)
	if(target_boris)
		boris = target_boris
	RegisterSignal(item, COMSIG_QDELETING, PROC_REF(remove_occupant_item))
	RegisterSignal(item, COMSIG_MOVABLE_MOVED, PROC_REF(occupant_item_moved))


/obj/item/circuit_component/mmi/proc/occupant_item_moved(atom/movable/occupant_item)
	SIGNAL_HANDLER

	if(occupant_item.loc != src)
		remove_occupant_item(occupant_item)

/obj/item/circuit_component/mmi/proc/remove_occupant_item(obj/item/removing)
	SIGNAL_HANDLER
	removing ||= brain || boris
	if(!removing)
		return
	if(istype(removing, /obj/item/mmi))
		brain = null
	if(istype(removing, /obj/item/borg/upgrade/ai))
		boris = null
	remove_occupant()

	UnregisterSignal(removing, list(
		COMSIG_QDELETING,
		COMSIG_MOVABLE_MOVED
	))
	if(removing.loc == src)
		removing.forceMove(drop_location())


/obj/item/circuit_component/mmi/proc/shell_attack_ai(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	if(!boris)
		return
	if(!isAI(user))
		return
	var/mob/living/silicon/ai/ai = user
	if(!ai.can_perform_action(source, ALLOW_SILICON_REACH))
		return
	if(occupant)
		if(occupant != user)
			source.balloon_alert(user, "occupied!")
		return
	INVOKE_ASYNC(src, PROC_REF(try_ai_connect), user, source)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/circuit_component/mmi/proc/try_ai_connect(mob/living/silicon/ai/user, atom/movable/shell)
	var/confirmation = tgui_alert(user, "Connect to [shell]?", buttons = list("Yes", "No"))
	if(confirmation != "Yes")
		return
	if(QDELETED(src) || QDELETED(user) || QDELETED(shell) || !parent?.shell || !user.can_interact_with(shell) || !boris)
		return
	if(occupant)
		if(occupant != user)
			shell.balloon_alert(user, "occupied!")
		return
	set_occupant(user)

/obj/item/circuit_component/mmi/proc/set_occupant(mob/living/new_occupant)
	new_occupant.remote_control = src
	RegisterSignal(new_occupant, COMSIG_MOB_CLICKON, PROC_REF(handle_occupant_attack))
	RegisterSignal(new_occupant, COMSIG_QDELETING, PROC_REF(remove_occupant))
	if(isAI(new_occupant))
		var/mob/living/silicon/ai = new_occupant
		ai.reset_perspective(src)
		// Perspective gets reset whenever multicam is ended.
		RegisterSignal(ai, COMSIG_MOB_RESET_PERSPECTIVE, PROC_REF(remove_occupant))
		// There are probably some more immediate signals to hook on to in order to trigger disconnects,
		// but I'm feeling lazy as of the time I'm coding this and a LIVING_LIFE handler should work fine.
		RegisterSignal(ai, COMSIG_LIVING_LIFE, PROC_REF(on_ai_life))
		disconnect_action.Grant(ai)
		to_chat(ai, span_notice("Established connection with remote circuit."))
	occupant = new_occupant

/obj/item/circuit_component/mmi/proc/on_ai_life(mob/living/silicon/ai/ai)
	SIGNAL_HANDLER
	if(!istype(ai))
		return
	if(ai.control_disabled || !ai.can_interact_with(parent.shell))
		remove_occupant()

/obj/item/circuit_component/mmi/proc/remove_occupant()
	SIGNAL_HANDLER
	if(!occupant)
		return
	if(isAI(occupant))
		var/mob/living/silicon/ai/ai = occupant
		if(!ai.eyeobj)
			ai.create_eye()
		disconnect_action.Remove(ai)
		UnregisterSignal(ai, list(COMSIG_MOB_RESET_PERSPECTIVE, COMSIG_LIVING_LIFE))
		ai.reset_perspective(null)
		to_chat(ai, span_notice("Disconnected from remote circuit."))
	occupant.remote_control = null
	UnregisterSignal(occupant, list(COMSIG_MOB_CLICKON, COMSIG_QDELETING))
	occupant = null

/obj/item/circuit_component/mmi/relaymove(mob/living/user, direct)
	if(user != occupant)
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

/obj/item/circuit_component/mmi/proc/handle_occupant_attack(mob/living/source, atom/target, list/modifiers, list/attack_modifiers)
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
	remove_occupant_item()
	return ..()

#undef MMI_MESSAGE_COOLDOWN
