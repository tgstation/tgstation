/// Used to apply certain speech patterns
/// Can be used on organs, wearables, mutations and mobs
/datum/component/speechmod
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Assoc list for strings/regexes and their replacements. Should be lowercase, as case will be automatically changed
	var/list/replacements = list()
	/// String added to the end of the message
	var/end_string = ""
	/// Chance for the end string to be applied
	var/end_string_chance = 100
	/// Current target for modification
	var/mob/targeted
	/// Slot tags in which this item works when equipped
	var/slots
	/// If set to true, turns all text to uppercase
	var/uppercase = FALSE
	/// Any additional checks that we should do before applying the speech modification
	var/datum/callback/should_modify_speech = null

/datum/component/speechmod/Initialize(replacements = list(), end_string = "", end_string_chance = 100, slots, uppercase = FALSE, should_modify_speech)
	if (!ismob(parent) && !isitem(parent) && !istype(parent, /datum/mutation/human))
		return COMPONENT_INCOMPATIBLE

	src.replacements = replacements
	src.end_string = end_string
	src.end_string_chance = end_string_chance
	src.slots = slots
	src.uppercase = uppercase
	src.should_modify_speech = should_modify_speech

	if (istype(parent, /datum/mutation/human))
		RegisterSignal(parent, COMSIG_MUTATION_GAINED, PROC_REF(on_mutation_gained))
		RegisterSignal(parent, COMSIG_MUTATION_LOST, PROC_REF(on_mutation_lost))
		return

	var/atom/owner = parent

	if (istype(parent, /datum/status_effect))
		var/datum/status_effect/effect = parent
		targeted = effect.owner
		RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		return

	if (ismob(parent))
		targeted = parent
		RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		return

	if (ismob(owner.loc))
		targeted = owner.loc
		RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_unequipped))
	RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

/datum/component/speechmod/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] == "*")
		return
	if(SEND_SIGNAL(source, COMSIG_TRY_MODIFY_SPEECH) & PREVENT_MODIFY_SPEECH)
		return
	if(!isnull(should_modify_speech) && !should_modify_speech.Invoke(source, speech_args))
		return

	for (var/to_replace in replacements)
		var/replacement = replacements[to_replace]
		// Values can be lists to be picked randomly from
		if (islist(replacement))
			replacement = pick(replacement)

		message = replacetextEx(message, to_replace, replacement)
	message = trim(message)
	if (prob(end_string_chance))
		message += islist(end_string) ? pick(end_string) : end_string
	speech_args[SPEECH_MESSAGE] = trim(message)

	if (uppercase)
		return COMPONENT_UPPERCASE_SPEECH

/datum/component/speechmod/proc/on_equipped(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER

	if (!isnull(slots) && !(slot & slots))
		if (!isnull(targeted))
			UnregisterSignal(targeted, COMSIG_MOB_SAY)
			targeted = null
		return

	if (targeted == user)
		return

	targeted = user
	RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/speechmod/proc/on_unequipped(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if (isnull(targeted))
		return
	UnregisterSignal(targeted, COMSIG_MOB_SAY)
	targeted = null

/datum/component/speechmod/proc/on_implanted(datum/source, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	if (targeted == receiver)
		return

	targeted = receiver
	RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/speechmod/proc/on_removed(datum/source, mob/living/carbon/former_owner)
	SIGNAL_HANDLER

	if (isnull(targeted))
		return
	UnregisterSignal(targeted, COMSIG_MOB_SAY)
	targeted = null

/datum/component/speechmod/proc/on_mutation_gained(datum/source, mob/living/carbon/human/owner)
	SIGNAL_HANDLER

	if (targeted == owner)
		return

	targeted = owner
	RegisterSignal(targeted, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/component/speechmod/proc/on_mutation_lost(datum/source, mob/living/carbon/human/owner)
	SIGNAL_HANDLER

	if (isnull(targeted))
		return
	UnregisterSignal(targeted, COMSIG_MOB_SAY)
	targeted = null

/datum/component/speechmod/Destroy()
	should_modify_speech = null
	return ..()
