/mob/living/voices/say_understands(var/other)
	if (src.current_host && !istype(src.current_host, /mob/living/voices/))
		return src.current_host.say_understands(other) // you can understand what you host can, you're sharing a brain
	else
		return 1 // A voice with no host or a voice as host? Let it understand anything

/mob/living/voices/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	log_say("Voice [src.name]/[src.key] inside [src.current_host]: [message]")
	var/tdisplay = "<i><font color=#643200><b>[capitalize(src.real_name)]:</b> [message]</font></i>"

	for(var/mob/M in mob_list)		//speak to your host, and dead guys
		if ( (M==src.current_host) || (istype(M, /mob/dead/observer)) )
			M <<  tdisplay

	for (var/mob/living/voices/P in src.current_host)	// also speak to all voices in your current host
		P << tdisplay
	return