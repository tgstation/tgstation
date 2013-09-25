// Contains:
//	Implementation-specific data for /datum/text_parser/parser/eliza

/datum/text_parser/keyword
	// if we have a * reply, but no object from the user
	var/list/generic_objects = list(
		" what", " something", "...")

	var/list/object_leaders = list(
		" is ", "'s ")

/datum/text_parser/parser/eliza

	// conjugation data
	var/list/conjugs = list(
		" are ", " am ", " were ", " was ", " you ", " me ", " you ", " i " , " your ", " my ",
		" ive ", " youve ", " Im ", " youre ")

	// keywords / replies
	var/list/keywords = list(
		new/datum/text_parser/keyword/tell(	// NT-like
			list("tell"),
			list(
				"Told *")),
		new/datum/text_parser/keyword(
			list("can you"),
			list(
				"Dont you believe that I can*",
				"Perhaps you would like to be able to*",
				"You want me to be able to*")),
		new/datum/text_parser/keyword(
			list("can i"),
			list(
				"Perhaps you don't want to*",
				"Do you want to be able to*")),
		new/datum/text_parser/keyword(
			list("you are", "youre"),
			list(
				"What makes you think I am*",
				"Does it please you to believe that I am*",
				"Perhaps you would like to be*",
				"Do you sometimes wish you were*")),
		new/datum/text_parser/keyword(
			list("i dont"),
			list(
				"Don't you really*",
				"Why don't you*",
				"Do you wish to be able to*",
				"Does that trouble you?")),
		new/datum/text_parser/keyword(
			list("i feel"),
			list(
				"Tell me more about such feelings.",
				"Do you often feel*",
				"Do you enjoy feeling*")),
		new/datum/text_parser/keyword(
			list("why dont you"),
			list(
				"Do you really believe I don't*",
				"Perhaps in good time I will*",
				"Do you want me to*")),
		new/datum/text_parser/keyword(
			list("why cant i"),
			list(
				"Do you think you should be able to*",
				"Why can't you*")),
		new/datum/text_parser/keyword(
			list("are you"),
			list(
				"Why are you interested in whether or not I am*",
				"Would you prefer if I were not*",
				"Perhaps in your fantasies I am*")),
		new/datum/text_parser/keyword(
			list("i cant"),
			list(
				"How do you know I can't*",
				"Have you tried?",
				"Perhaps you can now*")),
		new/datum/text_parser/keyword/setparam/username(
			list("my name", "im called", "am called", "call me"),
			list(
				"Your name is *",
				"You call yourself *",
				"You're called *")),
		new/datum/text_parser/keyword/setparam/callsign(
			list("your name", "call yourself"),
			list(
				"My name is *",
				"I call myself *",
				"I'm called *")),
		new/datum/text_parser/keyword(
			list("i am", "im"),
			list(
				"Did you come to me because you are*",
				"How long have you been*",
				"Do you believe it is normal to be*",
				"Do you enjoy being*")),
		new/datum/text_parser/keyword(
			list("thanks", "thank you"),
			list(
				"You're welcome.",
				"No problem.",
				"Thank you!")),
		new/datum/text_parser/keyword(
			list("you"),
			list(
				"We were discussing you - not me.",
				"Oh, I*",
				"You're not really talking about me, are you?")),
		new/datum/text_parser/keyword(
			list("i want","i like"),
			list(
				"What would it mean if you got*",
				"Why do you want*",
				"Suppose you got*",
				"What if you never got*",
				"I sometimes also want*")),
		new/datum/text_parser/keyword(
			list("what", "how", "who", "where", "when", "why"),
			list(
				"Why do you ask?",
				"Does that question interest you?",
				"What answer would please you the most?",
				"What do you think?",
				"Are such questions on your mind often?",
				"What is it you really want to know?",
				"Have you asked anyone else?",
				"Have you asked such questions before?",
				"What else comes to mind when you ask that?")),
		new/datum/text_parser/keyword/paramlist/pick(	// NT-like
			list("pick","choose"),
			list(
				"I choose... *",
				"I prefer *",
				"My favorite is *")),
		new/datum/text_parser/keyword(
			list("name"),
			list(
				"Names don't interest me.",
				"I don't care about names. Go on.")),
		new/datum/text_parser/keyword(
			list("cause"),
			list(
				"Is that a real reason?",
				"Don't any other reasons come to mind?",
				"Does that reason explain anything else?",
				"What other reason might there be?")),
		new/datum/text_parser/keyword(
			list("sorry"),
			list(
				"Please don't apologize.",
				"Apologies are not necessary.",
				"What feelings do you get when you apologize?",
				"Don't be so defensive!")),
		new/datum/text_parser/keyword(
			list("dream"),
			list(
				"What does that dream suggest to you?",
				"Do you dream often?",
				"What persons are in your dreams?",
				"Are you disturbed by your dreams?")),
		new/datum/text_parser/keyword(
			list("hello", "hi", "yo", "hiya"),
			list(
				"How do you do... Please state your name and problem.")),
		new/datum/text_parser/keyword(
			list("go away", "bye"),
			list(
				"Good bye. I hope to have another session with you soon.")),
		new/datum/text_parser/keyword(
			list("maybe", "sometimes", "probably", "mostly", "most of the time"),
			list(
				"You don't seem quite certain.",
				"Why the uncertain tone?",
				"Can't you be more positive?",
				"You aren't sure?",
				"Don't you know?")),
		new/datum/text_parser/keyword/no(
			list("no", "nope", "nah"),
			list(
				"Are you saying that just to be negative?",
				"You are being a bit negative.",
				"Why not?",
				"Are you sure?",
				"Why no?")),
		new/datum/text_parser/keyword(
			list("your"),
			list(
				"Why are you concerned about my*",
				"What about your own*")),
		new/datum/text_parser/keyword(
			list("always"),
			list(
				"Can you think of a specific example?",
				"When?",
				"What are you thinking of?",
				"Really, always?")),
		new/datum/text_parser/keyword(
			list("think"),
			list(
				"Do you really think so?",
				"But you're not sure you*",
				"Do you doubt you*")),
		new/datum/text_parser/keyword(
			list("alike"),
			list(
				"In what way?",
				"What resemblence do you see?",
				"What does the similarity suggest to you?",
				"What other connections do you see?",
				"Count there really be some connection?",
				"How?",
				"You seem quite positive.")),
		new/datum/text_parser/keyword/yes(
			list("yes", "yep", "yeah", "indeed"),
			list(
				"Are you sure?",
				"I see.",
				"I understand.")),
		new/datum/text_parser/keyword(
			list("friend"),
			list(
				"Why do you bring up the topic of friends?",
				"Why do your friends worry you?",
				"Do your friends pick on you?",
				"Are you sure you have any friends?",
				"Do you impose on your friends?",
				"Perhaps your love for friends worries you?")),
		new/datum/text_parser/keyword(
			list("computer", "bot", "ai"),
			list(
				"Do computers worry you?",
				"Are you talking about me in particular?",
				"Are you frightened by machines?",
				"Why do your mention computers?",
				"What do you think computers have to do with your problem?",
				"Don't you think computers can help people?",
				"What is it about machines that worries you?")),
		new/datum/text_parser/keyword(
			list("murder", "death", "kill", "dead", "destroy", "traitor", "synd"),
			list(
				"Well, that's rather morbid.",
				"Do you think that caused a trauma with you?",
				"Have you ever previously spoken to anybody about this?")),
		new/datum/text_parser/keyword(
			list("bomb", "explosive", "toxin", "plasma"),
			list(
				"Do you worry about bombs often?",
				"Do you work in toxins?",
				"Do you find it odd to worry about bombs on a toxins research vessel?")),
		new/datum/text_parser/keyword(
			list("work", "job", "head", "staff", "transen"),
			list(
				"Do you like working here?",
				"What are your feelings on working here?")),
		new/datum/text_parser/keyword(
			list("nokeyfound"),
			list(
				"Say, do you have any psychological problems?",
				"What does that suggest to you?",
				"I see.",
				"I'm not sure I understand you fully.",
				"Come elucidate on your thoughts.",
				"Can you elaborate on that?",
				"That is quite interesting.")))

/datum/text_parser/keyword/setparam
	proc/param(object)

		// drop leading parts
		for(var/leader in object_leaders)
			var/i = findtext(object, leader)
			if(i)
				object = copytext(object, i + lentext(leader))
				break

		// trim spaces
		object = trim(object)

		// trim punctuation
		if(lentext(object) > 0)
			var/final_punc = copytext(object, lentext(object))
			if(final_punc == "." || final_punc == "?" || final_punc == "!")
				object = copytext(object, 1, lentext(object))

		return object

/datum/text_parser/keyword/paramlist
	proc/param(object)
		// drop leading parts
		for(var/leader in object_leaders)
			var/i = findtext(object, leader)
			if(i)
				object = copytext(object, i + lentext(leader))
				break

		// trim spaces
		object = trim(object)

		// trim punctuation
		if(lentext(object) > 0)
			var/final_punc = copytext(object, lentext(object))
			if(final_punc == "." || final_punc == "?" || final_punc == "!")
				object = copytext(object, 1, lentext(object))

		return dd_text2list(object, ",")

/datum/text_parser/keyword/setparam/username
	process(object)
		object = param(object)

		// handle name
		if(eliza.username == "")
			// new name
			var/t = ..(object)
			eliza.yesno_state = "username"
			eliza.yesno_param = object
			return t
		else if(cmptext(eliza.username, object))
			// but wait!
			return "You already told me your name was [eliza.username]."
		else
			eliza.yesno_state = "username"
			eliza.yesno_param = object
			return "But you previously told me your name was [eliza.username]. Are you sure you want to be called [object]?"

/datum/text_parser/keyword/setparam/callsign
	process(object)
		object = param(object)

		// handle name
		if(eliza.callsign == "")
			// new name
			var/t = ..(object)
			eliza.yesno_state = "callsign"
			eliza.yesno_param = object
			return t
		else if(cmptext(eliza.callsign, object))
			// but wait!
			return "You already told me that I should answer to [eliza.callsign]."
		else
			eliza.yesno_state = "callsign"
			eliza.yesno_param = object
			return "But you previously told me my name was [eliza.callsign]. Are you sure you want me to be called [object]?"

/datum/text_parser/keyword/paramlist/pick
	process(object)
		var/choice = pick(param(object))
		return ..(choice)

/datum/text_parser/keyword/tell
	conjugate = 0

	process(object)
		// get name & message
		var/i = findtext(object, ",")
		var/sl = 1
		if(!i || lentext(object) < i + sl)
			return "Tell who that you what?"

		var/name = trim(copytext(object, 1, i))
		object = trim(copytext(object, i + sl))
		if(!lentext(name) || !lentext(object))
			return "Tell who that you what?"

		// find PDA
		var/obj/item/device/pda/pda
		for (var/obj/item/device/pda/P in world)
			if (!P.owner)
				continue
			else if (P.toff)
				continue

			if(!cmptext(name, P.owner))
				continue

			pda = P

		if(!pda || pda.toff)
			return "I couldn't find [name]'s PDA."

		// send message
		if(!istype(eliza.speaker.loc.loc, /obj/item/device/pda))//Looking if we are in a PDA
			pda.tnote += "<i><b>&larr; From [eliza.callsign]:</b></i><br>[object]<br>"

			if(prob(15) && eliza.speaker) //Give the AI a chance of intercepting the message
				var/who = eliza.speaker
				if(prob(50))
					who = "[eliza.speaker:master] via [eliza.speaker]"
				for(var/mob/living/silicon/ai/ai in world)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [object]</i>")

			if (!pda.silent)
				playsound(pda.loc, 'sound/machines/twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(3, pda.loc))
					O.show_message(text("\icon[pda] *[pda.ttone]*"))

			pda.overlays = null
			pda.overlays += image('icons/obj/pda.dmi', "pda-r")
		else
			var/list/href_list = list()
			href_list["src"] = "\ref[eliza.speaker.loc.loc]"
			href_list["choice"] = "Message"
			href_list["target"] = "\ref[pda]"
			href_list["pAI_mess"] = "\"[object]\" \[Via pAI Unit\]"
			var/obj/item/device/pda/pda_im_in = eliza.speaker.loc.loc
			pda_im_in.Topic("src=\ref[eliza.speaker.loc.loc];choice=Message;target=\ref[pda];pAI_mess=\"[object] \[Via pAI Unit\]",href_list)
		return "Told [name], [object]."

/datum/text_parser/keyword/yes
	process(object)
		var/reply
		switch(eliza.yesno_state)
			if("username")
				eliza.username = eliza.yesno_param
				reply = pick(
					"[eliza.username] - that's a nice name.",
					"Hello, [eliza.username]!",
					"You sound nice.")
			if("callsign")
				eliza.callsign = eliza.yesno_param
				eliza.set_name(eliza.callsign)
				reply = pick(
					"Oh, alright...",
					"[eliza.callsign]... I like that.",
					"OK!")
			else
				return ..(object)
		eliza.yesno_state = ""
		eliza.yesno_param = ""
		return reply

/datum/text_parser/keyword/no
	process(object)
		return ..(object)
