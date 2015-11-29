/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	if(say_disabled)
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	usr.say(message)

/mob/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"
	return
/*
/mob/proc/whisper(var/message, var/unheard=" whispers something", var/heard="whispers,", var/apply_filters=1, var/allow_lastwords=1)
	return
*/

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!usr.stat && (usr.status_flags & FAKEDEATH))
		to_chat(usr, "<span class='danger'>Doing this will give us away!</span>")
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(usr.stat == DEAD)
		usr.emote_dead(message)
	else
		usr.emote("me",usr.emote_type,message)

/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(client && !(client.prefs.toggles & CHAT_DEAD))
		to_chat(usr, "<span class='danger'>You have deadchat muted.</span>")
		return

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	message = src.say_quote("\"[html_encode(message)]\"")
	//var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"
	var/rendered2 = null//edited
	for(var/mob/M in player_list)
		rendered2 = "<span class='game deadsay'><a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a><span class='prefix'> DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"//edited
		if(istype(M, /mob/new_player) || !M.client)
			continue
		if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			to_chat(M, rendered2)//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.

		else if(M.client && M.stat == DEAD && (M.client.prefs.toggles & CHAT_DEAD))
			//M.show_message(rendered2, 2) //Takes into account blindness and such.
			to_chat(M, rendered2)
	return

/mob/proc/emote(var/act, var/type, var/message, var/auto)
	if(timestopped) return //under effects of time magick
	if(act == "me")
		return custom_emote(type, message)

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/lingcheck()
	return 0

/mob/proc/construct_chat_check(var/setting)
	return 0

/mob/proc/hivecheck()
	return 0

/mob/proc/binarycheck()
	return 0

//parses the language code (e.g. :j) from text, such as that supplied to say.
//returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language(var/message)
	if(length(message) >= 2)
		var/language_prefix = lowertext(copytext(message, 1 ,3))
		if(language_prefix in language_keys)
			var/datum/language/L = language_keys[language_prefix]
			if (can_speak_lang(L))
				return L
			else
				if(istype(L))
					say_testing(src, "Tried to speak [L.name] but don't know it, prefix length is [length(language_prefix)] before [message] after [copytext(message, 1+length(language_prefix))]")
					return language_prefix

	return null

/mob/say_understands(var/mob/other,var/datum/language/speaking = null)
	if (src.stat == 2)		//Dead
		return 1

	//Universal speak makes everything understandable, for obvious reasons.
	if(src.universal_speak || src.universal_understand)
		return 1

	//Languages are handled after.
	if (!speaking)
		if(other)
			other = other.GetSource()
		if(!other || !ismob(other))
			return 1
		if(other.universal_speak)
			return 1
		if(isAI(src) && ispAI(other))
			return 1
		if (istype(other, src.type) || istype(src, other.type))
			return 1
		return 0

	//Language check.
	for(var/datum/language/L in src.languages)
		if(speaking.name == L.name)
			return 1
	return 0
