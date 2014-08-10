/mob/dead/observer/say_understands(var/other)
	return 1

/mob/dead/observer/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "\red You cannot talk in deadchat (muted)."
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)
	
/mob/dead/observer/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "[pick("moans", "gripes", "grumps", "murmurs", "mumbles", "bleats")], \"[text]\"";
	else if (ending == "!")
		return "[pick("screams", "screeches", "howls")], \"[text]\"";

	return "[pick("whines", "cries", "spooks", "complains", "drones", "mutters")], \"[text]\"";


/mob/dead/observer/emote(var/act, var/type, var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(act != "me")
		return

	log_emote("Ghost/[src.key] : [message]")

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "\red You cannot emote in deadchat (muted)."
			return

		if(src.client.handle_spam_prevention(message, MUTE_DEADCHAT))
			return

	. = src.emote_dead(message)

/*
	for (var/mob/M in hearers(null, null))
		if (!M.stat)
			if(M.job == "Chaplain")
				if (prob (49))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(get_turf(src), pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					if(prob(30))
						playsound(get_turf(src), pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
			else
				if (prob(50))
					return
				else if (prob (95))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(get_turf(src), pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					playsound(get_turf(src), pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
*/
