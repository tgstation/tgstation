/mob/living/carbon/human/whisper(message as text)
	if(!IsVocal())
		return
#ifdef SAY_DEBUG
	var/oldmsg = message
#endif
	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(isDead())
		return

	if(silent)
		to_chat(src, "<span class='warning'>You can't speak while silenced.</span>")
		return

	var/datum/speech/speech = create_speech(message)
	speech.language = parse_language(speech.message)
	speech.mode = SPEECH_MODE_WHISPER
	speech.message_classes.Add("whisper")

	if(istype(speech.language))
		speech.message = copytext(speech.message,2+length(speech.language.key))
	else
		if(!isnull(speech.language))
			//var/oldmsg = message
			var/n = speech.language
			speech.message = copytext(speech.message,1+length(n))
			say_testing(src, "We tried to speak a language we don't have length = [length(n)], oldmsg = [oldmsg] parsed message = [speech.message]")
			speech.language = null
		speech.language = get_default_language()

	speech.message = trim(speech.message)
	if(!can_speak(message))
		return

	speech.message = "[message]"

	if (src.client)
		if (src.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot whisper (muted).</span>")
			return

	//var/alt_name = get_alt_name()

	var/whispers = "whispers"
	var/critical = InCritical()

	// We are unconscious but not in critical, so don't allow them to whisper.
	if(stat == UNCONSCIOUS && (!critical || said_last_words))
		return

	log_whisper("[key_name(src)] ([formatLocation(src)]): [message]")

	// If whispering your last words, limit the whisper based on how close you are to death.
	if(critical && !said_last_words)
		var/health_diff = round(-config.health_threshold_dead + health)
		// If we cut our message short, abruptly end it with a-..
		var/message_len = length(speech.message)
		speech.message = copytext(speech.message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
		speech.message = Ellipsis(speech.message, 10, 1)
		speech.mode= SPEECH_MODE_FINAL
		whispers = "whispers with their final breath"
		said_last_words = src.stat
	treat_speech(speech)

	var/listeners = get_hearers_in_view(1, src) | observers

	var/eavesdroppers = get_hearers_in_view(2, src) - listeners

	var/watchers = hearers(5, src) - listeners - eavesdroppers


	//"<span class='game say'><span class='name'>[GetVoice()]</span> (as [alt_name]) [whispers], <span class='message'>\"<i>[message]</i>\"</span></span>"
	var/rendered = render_speech(speech)

	for (var/atom/movable/listener in listeners)
		if (listener)
			listener.Hear(speech, rendered)

	listeners = null

	speech.message = stars(speech.message)

	//rendered = "<span class='game say'><span class='name'>[GetVoice()]</span> (as [alt_name]) [whispers], <span class='message'>\"<i>[message]</i>\"</span></span>"
	rendered = render_speech(speech)

	for (var/atom/movable/eavesdropper in eavesdroppers)
		if (eavesdropper)
			eavesdropper.Hear(speech, rendered)

	eavesdroppers = null

	rendered = "<span class='game say'><span class='name'>[src.name]</span> [whispers] something.</span>"

	for (var/mob/watcher in watchers)
		if (watcher)
			watcher.show_message(rendered, 2)

	watchers = null

	if (said_last_words) // dying words
		succumb(1)

	returnToPool(speech)
