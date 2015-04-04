/mob/living/carbon/human/whisper(message as text)
	if(!IsVocal())
		return

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	if(stat == DEAD)
		return


	message = trim(strip_html_properly(message))
	if(!can_speak(message))
		return

	message = "[message]"

	if (src.client)
		if (src.client.prefs.muted & MUTE_IC)
			src << "<span class='danger'>You cannot whisper (muted).</span>"
			return

	var/alt_name = get_alt_name()

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
		var/message_len = length(message)
		message = copytext(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
		message = Ellipsis(message, 10, 1)
		whispers = "whispers in their final breath"
		said_last_words = src.stat
	message = treat_message(message)

	var/listeners = get_hearers_in_view(1, src) | observers

	var/eavesdroppers = get_hearers_in_view(2, src) - listeners

	var/watchers = hearers(5, src) - listeners - eavesdroppers

	var/rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"<i>[message]</i>\"</span></span>"

	for (var/atom/movable/listener in listeners)
		if (listener)
			listener.Hear(rendered, src, languages, message)

	listeners = null

	message = stars(message)

	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"<i>[message]</i>\"</span></span>"

	for (var/atom/movable/eavesdropper in eavesdroppers)
		if (eavesdropper)
			eavesdropper.Hear(rendered, src, languages, message)

	eavesdroppers = null

	rendered = "<span class='game say'><span class='name'>[src.name]</span> [whispers] something.</span>"

	for (var/mob/watcher in watchers)
		if (watcher)
			watcher.show_message(rendered, 2)

	watchers = null

	if (said_last_words) // dying words
		succumb(1)
