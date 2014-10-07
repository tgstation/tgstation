/mob/living/carbon/human/whisper(message as text)
	if(!IsVocal())
		return

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	if(stat == DEAD)
		return


	message = trim(copytext(strip_html_simple(message), 1, MAX_MESSAGE_LEN))
	if(!can_speak(message))
		return

	message = "<i>[message]</i>"
	log_whisper("[src.name]/[src.key] : [message]")

	if (src.client)
		if (src.client.prefs.muted & MUTE_IC)
			src << "<span class='danger'>You cannot whisper (muted).</span>"
			return

	log_whisper("[src.name]/[src.key] : [message]")

	var/alt_name = get_alt_name()

	var/whispers = "whispers"
	var/critical = InCritical()

	// We are unconscious but not in critical, so don't allow them to whisper.
	if(stat == UNCONSCIOUS && !critical)
		return

	// If whispering your last words, limit the whisper based on how close you are to death.
	if(critical)
		var/health_diff = round(-config.health_threshold_dead + health)
		// If we cut our message short, abruptly end it with a-..
		var/message_len = length(message)
		message = copytext(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
		message = Ellipsis(message, 10, 1)
		whispers = "whispers in their final breath"

	message = treat_message(message)

	var/list/listening_dead = list()
	for(var/mob/M in player_list)
		if(M.stat == DEAD && ((M.client.prefs.toggles & CHAT_GHOSTWHISPER) || (get_dist(M, src) <= 7)))
			listening_dead |= M

	var/list/listening = get_hear(1, src)
	listening |= listening_dead
	var/list/eavesdropping = hearers(2, src)
	eavesdropping -= listening
	var/list/watching  = hearers(5, src)
	watching  -= listening
	watching  -= eavesdropping

	var/rendered

	rendered = "<span class='game say'><span class='name'>[src.name]</span> [whispers] something.</span>"
	for(var/mob/M in watching)
		M.show_message(rendered, 2)

	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"[message]\"</span></span>"

	for(var/mob/M in listening)
		M.Hear(rendered, src, languages, message)

	message = stars(message)
	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"[message]\"</span></span>"
	for(var/mob/M in eavesdropping)
		M.Hear(rendered, src, languages, message)

	if(critical) //Dying words.
		succumb(1)
