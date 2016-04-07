//Speech verbs.
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return
	usr.say(message)

/mob/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	usr.emote("me",1,message)

/mob/proc/say_dead(var/message)
	var/name = real_name
	var/alt_name = ""

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"


	var/K

	if(key)
		K = src.key

	message = src.say_quote(message, get_spans())
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"

	for(var/mob/M in player_list)
		var/adminoverride = 0
		if(M.client && M.client.holder && (M.client.prefs.chat_toggles & CHAT_DEAD))
			adminoverride = 1
		if(istype(M, /mob/new_player) && !adminoverride)
			continue
		if(M.stat != DEAD && !adminoverride)
			continue
		if(K && M.client && K in M.client.prefs.ignoring)
			continue
		if(istype(M, /mob/dead/observer))
			M << "<a href=?src=\ref[M];follow=\ref[src]>(F)</a> [rendered]"
		else
			M << "[rendered]"

/mob/proc/emote(var/act)
	return

/mob/proc/hivecheck()
	return 0

/mob/proc/lingcheck()
	return 0
