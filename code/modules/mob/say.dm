/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	usr.say(message)

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	usr.emote("me",1,message)

/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if(original_name) //Original name is only used in ghost chat! It is not to be edited by anything!
		name = src.original_name
		if( original_name != real_name )
			alt_name = " (died as [src.real_name])"

	message = src.say_quote(message)
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat == 2 || (M.client && M.client.holder && M.client.deadchat)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			if(M.client && !M.client.STFU_ghosts) //Admin shut-off for ghosts chatter
				M.show_message(rendered, 2)

/mob/proc/say_understands(var/mob/other)
	if(!other)
		return 1
	if (src.stat == 2)
		return 1
	else if (istype(other, src.type))
		return 1
	else if(other.universal_speak || src.universal_speak)
		return 1
	else if(isAI(src) && ispAI(other))
		return 1
	return 0

/mob/proc/say_quote(var/text)
	var/ending = copytext(text, length(text))
	if (src.disease_symptoms & DISEASE_HOARSE)
		return "rasps, \"[text]\"";
	if (src.stuttering)
		return "stammers, \"[text]\"";
	if (src.slurring)
		return "slurrs, \"[text]\"";
	if (src.getBrainLoss() >= 60)
		return "gibbers, \"[text]\"";
	if (ending == "?")
		return "asks, \"[text]\"";
	else if (ending == "!")
		return "exclaims, \"[text]\"";

	return "says, \"[text]\"";

/mob/proc/emote(var/act)
	return

/mob/proc/say_test(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"