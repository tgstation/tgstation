/**
 * # Mind Linker
 *
 * A component that handles linking multiple player's minds
 * into one network which allows them to talk directly to one another.
 * Like telepathy but for multiple people at once!
 */
/datum/component/mind_linker
	/// The name of our network, displayed to all users.
	var/network_name = "Mind Link"
	/// The color of the network when talking in chat
	var/chat_color
	/// A list of all signals that will call qdel() on our component if triggered. Optional.
	var/list/signals_which_destroy_us
	/// A callback invoked after an unlink is done. Optional.
	var/datum/callback/post_unlink_callback
	/// The icon file given to the speech action handed out.
	var/speech_action_icon = 'icons/mob/actions/actions_slime.dmi'
	/// The icon state applied to the speech action handed out.
	var/speech_action_icon_state = "link_speech"
	/// The icon background for the speech action handed out.
	var/speech_action_background_icon_state = "bg_alien"
	/// The border icon state for the speech action handed out.
	var/speech_action_overlay_state = "bg_alien_border"
	/// The master's speech action. The owner of the link shouldn't lose this as long as the link remains.
	VAR_FINAL/datum/action/innate/linked_speech/master_speech
	/// An assoc list of [mob/living]s to [datum/action/innate/linked_speech]s. All the mobs that are linked to our network.
	VAR_FINAL/list/mob/living/linked_mobs = list()

/datum/component/mind_linker/Initialize(
	// Customization related settings
	network_name = "Mind Link",
	chat_color = "#008CA2",
	speech_action_icon = 'icons/mob/actions/actions_slime.dmi',
	speech_action_icon_state = "link_speech",
	speech_action_background_icon_state = "bg_alien",
	speech_action_overlay_state = "bg_alien_border",
	// Optional
	signals_which_destroy_us,
	datum/callback/post_unlink_callback,
)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent

	src.network_name = network_name
	src.chat_color = chat_color
	src.speech_action_icon = speech_action_icon
	src.speech_action_icon_state = speech_action_icon_state
	src.speech_action_background_icon_state = speech_action_background_icon_state

	if(islist(signals_which_destroy_us))
		src.signals_which_destroy_us = signals_which_destroy_us
	if(post_unlink_callback)
		src.post_unlink_callback = post_unlink_callback

	master_speech = new(src)
	master_speech.Grant(owner)

/datum/component/mind_linker/Destroy(force, silent)
	for(var/mob/living/remaining_mob as anything in linked_mobs)
		unlink_mob(remaining_mob)
	linked_mobs.Cut()
	QDEL_NULL(master_speech)
	post_unlink_callback = null
	return ..()

/datum/component/mind_linker/RegisterWithParent()
	if(signals_which_destroy_us)
		RegisterSignals(parent, signals_which_destroy_us, PROC_REF(destroy_link))

/datum/component/mind_linker/UnregisterFromParent()
	if(signals_which_destroy_us)
		UnregisterSignal(parent, signals_which_destroy_us)

/**
 * Attempts to link [to_link] to our network, giving them a speech action.
 *
 * Returns TRUE if successful, FALSE otherwise
 */
/datum/component/mind_linker/proc/link_mob(mob/living/to_link)
	if(QDELETED(to_link) || to_link.stat == DEAD)
		return FALSE
	if(linked_mobs[to_link])
		return FALSE

	var/mob/living/owner = parent
	if(to_link == owner)
		return FALSE

	var/datum/action/innate/linked_speech/new_link = new(src)
	new_link.Grant(to_link)

	linked_mobs[to_link] = new_link
	RegisterSignals(to_link, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(sig_unlink_mob))

	return TRUE

/datum/component/mind_linker/proc/sig_unlink_mob(mob/living/to_unlink)
	SIGNAL_HANDLER

	unlink_mob(to_unlink)

/**
 * Unlinks [to_unlink] from our network, deleting their speech action
 * and cleaning up anything involved.
 *
 * Also invokes post_unlink_callback, if supplied.
 */
/datum/component/mind_linker/proc/unlink_mob(mob/living/to_unlink)
	if(!linked_mobs[to_unlink])
		return FALSE

	post_unlink_callback?.Invoke(to_unlink)

	UnregisterSignal(to_unlink, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))

	var/datum/action/innate/linked_speech/old_link = linked_mobs[to_unlink]
	linked_mobs -= to_unlink
	qdel(old_link)
	return TRUE

/**
 *  Signal proc sent from any signals given to us initialize.
 *  Destroys our component and unlinks everyone.
 */
/datum/component/mind_linker/proc/destroy_link(datum/source)
	SIGNAL_HANDLER

	if(isliving(source))
		var/mob/living/owner = source
		to_chat(owner, span_boldwarning("Your [network_name] breaks!"))

	qdel(src)

/// Subtype of mind linker (I know) which is more active rather than passive,
/// which involves the master linking people manually rather than people being added automatically.
/datum/component/mind_linker/active_linking
	/// The message sent to someone when linked up.
	var/link_message
	/// The message sent to someone when unlinked.
	var/unlink_message
	/// The master's linking action, which allows them to link people to the network.
	VAR_FINAL/datum/action/linker_action

/datum/component/mind_linker/active_linking/Initialize(
	// Customization related settings
	network_name = "Mind Link",
	chat_color = "#008CA2",
	speech_action_icon = 'icons/mob/actions/actions_slime.dmi',
	speech_action_icon_state = "link_speech",
	speech_action_background_icon_state = "bg_alien",
	speech_action_overlay_state = "bg_alien_border",
	// Optional
	signals_which_destroy_us,
	datum/callback/post_unlink_callback,
	// Optional for this subtype
	link_message,
	unlink_message,
	// Required for this subtype
	linker_action_path,
)

	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/mob/living/owner = parent
	src.link_message = link_message || "You are now connected to [owner.real_name]'s [network_name]."
	src.unlink_message = unlink_message || "You are no longer connected to [owner.real_name]'s [network_name]."

	if(ispath(linker_action_path))
		linker_action = new linker_action_path(src)
		linker_action.Grant(owner)
	else
		stack_trace("[type] was created without a valid linker_action_path. No one will be able to link to it.")

	to_chat(owner, span_boldnotice("You establish a [network_name], allowing you to link minds to communicate telepathically."))

/datum/component/mind_linker/active_linking/Destroy()
	QDEL_NULL(linker_action)
	return ..()

/datum/component/mind_linker/active_linking/link_mob(mob/living/to_link)
	if(HAS_TRAIT(to_link, TRAIT_MINDSHIELD)) // Mindshield implant - no dice
		return FALSE
	if(to_link.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		return FALSE

	. = ..()
	if(!.)
		return

	RegisterSignal(to_link, COMSIG_MINDSHIELD_IMPLANTED, PROC_REF(sig_unlink_mob))
	var/mob/living/owner = parent
	to_chat(to_link, span_notice(link_message))
	to_chat(owner, span_notice("You connect [to_link]'s mind to your [network_name]."))
	for(var/mob/living/other_link as anything in linked_mobs)
		to_chat(other_link, span_notice("You feel a new presence within [owner.real_name]'s [network_name]."))

/datum/component/mind_linker/active_linking/unlink_mob(mob/living/to_unlink)
	. = ..()
	if(!.)
		return

	UnregisterSignal(to_unlink, COMSIG_MINDSHIELD_IMPLANTED)
	var/mob/living/owner = parent
	to_chat(to_unlink, span_warning(unlink_message))
	to_chat(owner, span_warning("You feel someone disconnect from your [network_name]."))
	for(var/mob/living/other_link as anything in linked_mobs)
		to_chat(other_link, span_warning("You feel a pressence disappear from [owner.real_name]'s [network_name]."))

// Used in mind linker to talk to everyone in the network.
/datum/action/innate/linked_speech
	name = "Mind Link Speech"
	desc = "Send a psychic message to everyone connected to your Link."
	button_icon_state = "link_speech"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/linked_speech/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)
		return

	var/datum/component/mind_linker/linker = Target
	name = "[linker.network_name] Speech"
	desc = "Send a psychic message to everyone connected to your [linker.network_name]."
	button_icon = linker.speech_action_icon
	button_icon_state = linker.speech_action_icon_state
	background_icon_state = linker.speech_action_background_icon_state

/datum/action/innate/linked_speech/IsAvailable(feedback = FALSE)
	return ..() && (owner.stat != DEAD)

/datum/action/innate/linked_speech/Activate()

	var/datum/component/mind_linker/linker = target
	var/mob/living/linker_parent = linker.parent

	var/message = tgui_input_text(owner, "Enter a message to transmit.", "[linker.network_name] Telepathy")
	if(!message || QDELETED(src) || QDELETED(owner) || owner.stat == DEAD)
		return

	if(QDELETED(linker))
		to_chat(owner, span_warning("The link seems to have been severed."))
		return

	var/formatted_message = "<i><font color=[linker.chat_color]>\[[linker_parent.real_name]'s [linker.network_name]\] <b>[owner]:</b> [message]</font></i>"
	log_directed_talk(owner, linker_parent, message, LOG_SAY, "mind link ([linker.network_name])")

	var/list/all_who_can_hear = assoc_to_keys(linker.linked_mobs) + linker_parent

	for(var/mob/living/recipient as anything in all_who_can_hear)
		to_chat(recipient, formatted_message)

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		to_chat(recipient, "[FOLLOW_LINK(recipient, owner)] [formatted_message]")
