/**
 * Alters text when players are injured.
 * Adds text, trims left and right side
 *
 * Arguments:
 *  payload - a string list containing entry & channel
 * Returns:
 *  string - the altered entry
 */
/datum/tgui_say/proc/alter_entry(payload)
	var/entry = payload["entry"]
	/// No OOC leaks
	if(!entry || payload["channel"] == OOC_CHANNEL || payload["channel"] == ME_CHANNEL)
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
/datum/tgui_say/proc/delegate_speech(entry, channel)
	switch(channel)
		if(SAY_CHANNEL)
			client.mob.say_verb(entry)
			return TRUE
		if(RADIO_CHANNEL)
			client.mob.say_verb(";" + entry)
			return TRUE
		if(ME_CHANNEL)
			client.mob.me_verb(entry)
			return TRUE
		if(OOC_CHANNEL)
			client.ooc(entry)
			return TRUE
	return FALSE

/**
 * Force say handler.
 * Sends a message to the say modal to send its current value.
 */
/datum/tgui_say/proc/force_say()
	window.send_message("force")
	stop_typing()

/**
 * Makes the player force say what's in their current input box.
 */
/mob/living/carbon/human/proc/force_say()
	if(stat != CONSCIOUS || !client?.tgui_say?.window_open)
		return FALSE
	client.tgui_say.force_say()
	if(client.typing_indicators)
		log_speech_indicators("[key_name(client)] FORCED to stop typing, indicators enabled.")
	else
		log_speech_indicators("[key_name(client)] FORCED to stop typing, indicators DISABLED.")
	SEND_SIGNAL(src, COMSIG_HUMAN_FORCESAY)

/**
 * Handles text entry and forced speech.
 *
 * Arguments:
 *  type - a string "entry" or "force" based on how this function is called
 *  payload - a string list containing entry & channel
 * Returns:
 *  boolean - success or failure
 */
/datum/tgui_say/proc/handle_entry(type, payload)
	if(!payload?["channel"] || !payload["entry"])
		CRASH("[usr] entered in a null payload to the chat window.")
	if(length(payload["entry"]) > max_length)
		CRASH("[usr] has entered more characters than allowed into a TGUI-Say")
	if(type == "entry")
		delegate_speech(payload["entry"], payload["channel"])
		return TRUE
	if(type == "force")
		var/target_channel = payload["channel"]
		if(target_channel == ME_CHANNEL || target_channel == OOC_CHANNEL)
			target_channel = SAY_CHANNEL // No ooc leaks
		delegate_speech(alter_entry(payload), target_channel)
		return TRUE
	return FALSE
