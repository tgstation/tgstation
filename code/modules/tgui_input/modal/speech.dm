/**
 * Alters text when players are injured.
 * Adds text, trims left and right side
 *
 * Arguments:
 *  payload - a string list containing entry & channel
 * Returns:
 *  string - the altered entry
 */
/datum/tgui_modal/proc/alter_entry(payload)
	var/entry = payload["entry"]
	/// No OOC leaks
	if(payload["channel"] == OOC_CHAN || payload["channel"] == ME_CHAN)
		return pick(hurt_phrases)
	/// Sanitizes radio prefixes so users can't game the system (mostly)
	entry = remove_prefixes(entry)
	if(!entry)
		return pick(hurt_phrases)
	/// Random trimming for larger sentences
	if(length(entry) > 50)
		entry = trim(entry, rand(40, 50))
	else
		/// Otherwise limit trim to just last letter
		if(length(entry) > 1)
			entry = trim(entry, length(entry))
	return entry + "-" + pick(hurt_phrases)

/**
 * Delegates the speech to the proper channel.
 *
 * Arguments:
 * 	entry - the text to broadcast
 * 	channel - the channel to broadcast in
 * Returns:
 *  boolean - on success or failure
 */
/datum/tgui_modal/proc/delegate_speech(entry, channel)
	if(!client)
		return FALSE
	if(channel == OOC_CHAN)
		client.ooc(entry)
		return TRUE
	if(!client.mob)
		return FALSE
	switch(channel)
		if(RADIO_CHAN)
			entry = remove_prefixes(entry)
			if(entry)
				entry = ";" + entry
				client.mob.say_verb(entry)
			return TRUE
		if(ME_CHAN)
			client.mob.me_verb(entry)
			return TRUE
		if(SAY_CHAN)
			client.mob.say_verb(entry)
			return TRUE
	return FALSE

/**
 * Force say handler.
 * Sends a message to the modal window to send its current value.
 */
/datum/tgui_modal/proc/force_say()
	window.send_message("force")

/**
 * Makes the player force say what's in their current input box.
 */
/mob/living/carbon/human/proc/force_say()
	if(!client || !mind || !client.tgui_modal)
		return FALSE
	client.tgui_modal.force_say()
	client.mob.typing_indicator = FALSE
	if(client?.typing_indicators)
		log_speech_indicators("[key_name(client)] FORCED to stop typing, indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] FORCED to stop typing, indicators DISABLED.")

/**
 * Sanitizes text from radio and emote prefixes
 *
 * Arguments:
 * 	entry - the text to sanitize
 * Returns:
 * 	string || boolean FALSE if the entry is empty
 */
/datum/tgui_modal/proc/remove_prefixes(entry)
	if(length(entry) < 2)
		return FALSE
	/// Start removing any type of radio prefix
	while(copytext_char(entry, 1, 2) == ";" \
		|| copytext_char(entry, 1, 2) == ":" \
		|| copytext_char(entry, 1, 2) == "*")
		/// Ensure we're not clipping the only letter
		if(length(entry) < 2)
			return FALSE
		/// Sanitize standard departmental chat
		if(copytext_char(entry, 1, 2) == ":" \
			&& length(entry) > 3 \
			&& copytext_char(entry, 3, 4) == " ")
			entry = copytext(entry, 4)
		else
			entry = copytext(entry, 2)
	return entry
