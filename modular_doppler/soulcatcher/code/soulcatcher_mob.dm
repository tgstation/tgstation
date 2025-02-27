/mob/living/soulcatcher_soul
	/// What does our soul look like?
	var/soul_desc = "It's a soul."
	/// What are the ooc notes for the soul?
	var/ooc_notes = ""

	/// Assuming we died inside of the round? What is our previous body?
	var/datum/weakref/previous_body
	/// What is the weakref of the soulcatcher room are we currently in?
	var/datum/weakref/current_room

	/// Is the soul able to see things in the outside world?
	var/outside_sight = TRUE
	/// Is the soul able to hear things from the outside world?
	var/outside_hearing = TRUE
	/// Is the soul able to "see" things from inside of the soulcatcher?
	var/internal_sight = TRUE
	/// Is the soul able to "hear" things from inside of the soulcatcher?
	var/internal_hearing = TRUE
	/// Is the soul able to emote inside the soulcatcher room?
	var/able_to_emote = TRUE
	/// Is the soul able to speak inside the soulcatcher room?
	var/able_to_speak = TRUE
	/// Is the soul able to change their own name?
	var/able_to_rename = TRUE
	/// Is the soul able to speak as the object it is inside?
	var/able_to_speak_as_container = TRUE
	/// Is the soul able to emote as the object it is inside?
	var/able_to_emote_as_container = TRUE
	/// Are emote's and Say's done through the container the mob is in?
	var/communicating_externally = FALSE

	/// Is the soul able to leave the soulcatcher?
	var/able_to_leave = TRUE
	/// Did the soul live within the round? This is checked if we want to transfer the soul to another body.
	var/round_participant = FALSE
	/// Does the body need scanned?
	var/body_scan_needed = FALSE

/mob/living/soulcatcher_soul/Initialize(mapload)
	. = ..()
	if(!outside_sight)
		become_blind(NO_EYES)

	if(!outside_hearing)
		ADD_TRAIT(src, TRAIT_DEAF, INNATE_TRAIT)

	var/datum/action/innate/leave_soulcatcher/leave_action = new(src)
	leave_action.Grant(src)

	var/datum/action/innate/soulcatcher_user/soulcatcher_action = new(src)
	soulcatcher_action.Grant(src)
	var/datum/component/soulcatcher_user/user_component = AddComponent(/datum/component/soulcatcher_user)
	soulcatcher_action.soulcatcher_user_component = WEAKREF(user_component)

/// Toggles whether or not the soul inside the soulcatcher can see the outside world. Returns the state of the `outside_sight` variable.
/mob/living/soulcatcher_soul/proc/toggle_sight()
	outside_sight = !outside_sight
	if(outside_sight)
		cure_blind(NO_EYES)
	else
		become_blind(NO_EYES)

	return outside_sight

/// Toggles whether or not the soul inside the soulcatcher can see the outside world. Returns the state of the `outside_hearing` variable.
/mob/living/soulcatcher_soul/proc/toggle_hearing()
	outside_hearing = !outside_hearing
	if(outside_hearing)
		REMOVE_TRAIT(src, TRAIT_DEAF, INNATE_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_DEAF, INNATE_TRAIT)

	return outside_hearing

/// Changes the soul's name based off `new_name`. Returns `TRUE` if the name has been changed, otherwise returns `FALSE`.
/mob/living/soulcatcher_soul/proc/change_name(new_name)
	if(!new_name || (round_participant && body_scan_needed))
		return FALSE

	name = new_name
	return TRUE

/// Attempts to reset the soul's name to its name in prefs. Returns `TRUE` if the name is reset, otherwise returns `FALSE`.
/mob/living/soulcatcher_soul/proc/reset_name()
	if(!mind?.name || change_name(mind.name))
		return FALSE

	return TRUE

/// Checks if the mob wants to leave the soulcatcher. If they do and are able to leave, they are booted out.
/mob/living/soulcatcher_soul/verb/leave_soulcatcher()
	set name = "Leave Soulcatcher"
	set category = "IC"

	if(!able_to_leave)
		to_chat(src, span_warning("You are unable to leave the soulcatcher."))
		return FALSE

	if(tgui_alert(src, "Are you sure you wish to leave the soulcatcher? IF you had a body, this will return you to your body", "Soulcatcher", list("Yes", "No")) != "Yes")
		return FALSE

	if(tgui_alert(src, "Are you really sure about this?", "Soulcatcher", list("Yes", "No")) != "Yes")
		return FALSE

	return_to_body()
	qdel(src)

/mob/living/soulcatcher_soul/ghost()
	. = ..()
	return_to_body()
	qdel(src)

/mob/living/soulcatcher_soul/say(
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
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	if((!able_to_speak && !communicating_externally) || (!able_to_speak_as_container && communicating_externally))
		to_chat(src, span_warning("You are unable to speak!"))
		return FALSE

	var/datum/soulcatcher_room/room = current_room.resolve()
	if(!room)
		return FALSE

	room.send_message(message, src, FALSE)
	return TRUE

/mob/living/soulcatcher_soul/me_verb(message as text|null)
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return FALSE

	if((!able_to_emote && !communicating_externally) || (!able_to_emote_as_container && communicating_externally))
		to_chat(src, span_warning("You are unable to emote!"))
		return FALSE

	var/datum/soulcatcher_room/room = current_room.resolve()
	if(!room)
		return FALSE

	room.send_message(message, src, TRUE)
	return TRUE

/mob/living/soulcatcher_soul/subtle()
	set hidden = TRUE
	return FALSE

/*/mob/living/soulcatcher_soul/subtler()
	set hidden = TRUE
	return FALSE*/

/mob/living/soulcatcher_soul/whisper_verb()
	set hidden = TRUE
	return FALSE

/*/mob/living/soulcatcher_soul/container_emote()
	set hidden = TRUE
	return FALSE*/

/mob/living/soulcatcher_soul/resist()
	set hidden = TRUE
	return FALSE

/// Assuming we have a previous body a present mind on our soul, we are going to transfer the mind back to the old body.
/mob/living/soulcatcher_soul/proc/return_to_body()
	if(!previous_body || !mind)
		return FALSE

	var/mob/target_body = previous_body.resolve()
	if(!target_body)
		return FALSE

	mind.transfer_to(target_body)
	SEND_SIGNAL(target_body, COMSIG_SOULCATCHER_CHECK_SOUL, FALSE)

	if(target_body.stat != DEAD)
		target_body.grab_ghost(TRUE)

/mob/living/soulcatcher_soul/Destroy()
	log_message("[key_name(src)] has exited a soulcatcher.", LOG_GAME)
	if(current_room)
		var/datum/soulcatcher_room/room = current_room.resolve()
		if(room)
			room.current_souls -= src

		current_room = null

	return ..()

/datum/emote/living
	mob_type_blacklist_typecache = list(/mob/living/brain, /mob/living/soulcatcher_soul)

/datum/action/innate/leave_soulcatcher
	name = "Leave Soulcatcher"
	background_icon = 'modular_doppler/soulcatcher/icons/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'modular_doppler/soulcatcher/icons/actions_nif.dmi'
	button_icon_state = "soulcatcher_exit"

/datum/action/innate/leave_soulcatcher/Activate()
	. = ..()
	var/mob/living/soulcatcher_soul/parent_soul = owner
	if(!parent_soul)
		return FALSE

	parent_soul.leave_soulcatcher()

/datum/action/innate/soulcatcher_user
	name = "Soulcatcher"
	background_icon = 'modular_doppler/soulcatcher/icons/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'modular_doppler/soulcatcher/icons/actions_nif.dmi'
	button_icon_state = "soulcatcher"
	/// What soulcatcher user component are we bringing up the menu for?
	var/datum/weakref/soulcatcher_user_component

/datum/action/innate/soulcatcher_user/Activate()
	. = ..()
	var/datum/component/soulcatcher_user/user_component = soulcatcher_user_component.resolve()
	if(!user_component)
		return FALSE

	user_component.ui_interact(owner)

/obj/item/soulcatcher_holder
	name = "Soul Holder"
	desc = "You probably shouldn't be seeing this..."
