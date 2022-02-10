/**
 * # Mind Linker
 *
 * A component that handles linking multiple player's minds
 * into one network which allows them to talk directly to one another.
 * Like telepathy but for multiple people at once!
 *
 * This component only handles managing the link network and text.
 * Adding people to the network itself (in game wise) requires
 * a separate action or spell that you must add for it to function.
 */
/datum/component/mind_linker
	/// The name of our network, displayed to all users.
	var/network_name = "Mind Link"
	/// The color of the network when talking in chat
	var/chat_color
	/// The message sent to someone when linked up.
	var/link_message
	/// The message sent to someone when unlinked.
	var/unlink_message
	/// A callback invoked before a user can message with speak_action.
	/// Optional, return TRUE or FALSE from it to allow or stop someone from talking over the network.
	var/datum/callback/can_message_callback
	/// A callback invoked after an unlink is done. Optional.
	var/datum/callback/post_unlink_callback
	/// The icon file given to the speech action handed out.
	var/speech_action_icon = 'icons/mob/actions/actions_slime.dmi'
	/// The icon state applied to the speech action handed out.
	var/speech_action_icon_state = "link_speech"
	/// The icon background for the speech action handed out.
	var/speech_action_background_icon_state = "bg_alien"
	/// An assoc list of [mob/living]s to [datum/action/innate/linked_speech]s. All the mobs that are linked to our network.
	var/list/mob/living/linked_mobs = list()

/datum/component/mind_linker/Initialize(
	network_name = "Mind Link",
	chat_color = "#008CA2",
	link_message,
	unlink_message,
	datum/callback/can_message_callback,
	datum/callback/post_unlink_callback,
	speech_action_icon = 'icons/mob/actions/actions_slime.dmi',
	speech_action_icon_state = "link_speech",
	speech_action_background_icon_state = "bg_alien",
	)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent

	src.network_name = network_name
	src.chat_color = chat_color
	src.link_message = link_message || "You are now connected to [owner.real_name]'s [network_name]."
	src.unlink_message = unlink_message || "You are no longer connected to [owner.real_name]'s [network_name]."
	if(can_message_callback)
		src.can_message_callback = can_message_callback
	if(post_unlink_callback)
		src.post_unlink_callback = post_unlink_callback

	src.speech_action_icon = speech_action_icon
	src.speech_action_icon_state = speech_action_icon_state
	src.speech_action_background_icon_state = speech_action_background_icon_state

	link_mob(owner)

/datum/component/mind_linker/Destroy(force, silent)
	for(var/remaining_mob in linked_mobs)
		unlink_mob(remaining_mob)
	linked_mobs.Cut()
	QDEL_NULL(can_message_callback)
	QDEL_NULL(post_unlink_callback)
	return ..()

/**
 * Attempts to link [to_link] to our network, giving them a speech action.
 *
 * Returns TRUE if successful, FALSE otherwise
 */
/datum/component/mind_linker/proc/link_mob(mob/living/to_link)
	if(QDELETED(to_link) || to_link.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(to_link, TRAIT_MINDSHIELD)) //mindshield implant, no dice
		return FALSE
	if(to_link.anti_magic_check(FALSE, FALSE, TRUE, 0))
		return FALSE
	if(linked_mobs[to_link])
		return FALSE

	var/mob/living/owner = parent
	to_chat(to_link, span_notice(link_message))
	to_chat(owner, span_notice("You connect [to_link]'s mind to your [network_name]."))

	for(var/mob/living/other_link as anything in linked_mobs)
		if(other_link == owner)
			continue
		to_chat(owner, span_notice("You feel a new pressence within [owner.real_name]'s [network_name]."))

	var/datum/action/innate/linked_speech/new_link = new(src)
	new_link.Grant(to_link)

	linked_mobs[to_link] = new_link
	RegisterSignal(to_link, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, COMSIG_MINDSHIELD_IMPLANTED), .proc/unlink_mob)

	return TRUE

/**
 * Unlinks [to_unlink] from our network, deleting their speech action
 * and cleaning up anything involved.
 *
 * Also invokes post_unlink_callback, if supplied.
 */
/datum/component/mind_linker/proc/unlink_mob(mob/living/to_unlink)
	SIGNAL_HANDLER

	if(!linked_mobs[to_unlink])
		return

	to_chat(to_unlink, span_warning(unlink_message))
	post_unlink_callback?.Invoke(to_unlink)

	UnregisterSignal(to_unlink, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, COMSIG_MINDSHIELD_IMPLANTED))

	var/datum/action/innate/linked_speech/old_link = linked_mobs[to_unlink]
	linked_mobs -= to_unlink
	qdel(old_link)

	var/mob/living/owner = parent

	to_chat(owner, span_warning("You feel someone disconnect from your [network_name]."))
	for(var/mob/living/other_link as anything in linked_mobs)
		if(other_link == owner)
			continue
		to_chat(owner, span_warning("You feel a pressence disappear from [owner.real_name]'s [network_name]."))

/datum/action/innate/linked_speech
	name = "Mind Link Speech"
	desc = "Send a psychic message to everyone connected to your Link."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/linked_speech/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		qdel(src)
		return

	var/datum/component/mind_linker/linker = Target
	name = "[linker.network_name] Speech"
	desc = "Send a psychic message to everyone connected to your [linker.network_name]."
	icon_icon = linker.speech_action_icon
	button_icon_state = linker.speech_action_icon_state
	background_icon_state = linker.speech_action_background_icon_state

/datum/action/innate/linked_speech/IsAvailable()
	return ..() && can_we_talk()

/datum/action/innate/linked_speech/Activate()

	var/datum/component/mind_linker/linker = target
	var/mob/living/linker_parent = linker.parent

	var/message = sanitize(tgui_input_text(owner, "Enter a message to transmit.", "[linker.network_name] Telepathy"))
	if(!message)
		return

	if(QDELETED(linker) || QDELETED(owner) || !can_we_talk())
		to_chat(owner, span_warning("The link seems to have been severed."))
		return

	var/msg = "<i><font color=[linker.chat_color]>\[[linker_parent.real_name]'s [linker.network_name]\] <b>[owner]:</b> [message]</font></i>"
	log_directed_talk(owner, linker_parent, msg, LOG_SAY, "mind link ([linker.network_name])")

	for(var/mob/living/recipient as anything in linker.linked_mobs)
		to_chat(recipient, msg)

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(recipient, owner)
		to_chat(recipient, "[link] [msg]")

/// Simple check for seeing if we can currently talk over the network.
/datum/action/innate/linked_speech/proc/can_we_talk()
	if(owner.stat == DEAD)
		return FALSE

	var/datum/component/mind_linker/linker = target
	if(!linker.linked_mobs[owner])
		return FALSE
	if(linker.can_message_callback)
		return linker.can_message_callback.Invoke()

	return TRUE
