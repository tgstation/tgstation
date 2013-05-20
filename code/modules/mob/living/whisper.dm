//moved to /mob/living from /mob/living/carbon/human
/*
	 quote is the output of your mobs say_quote function for mobs that always speak in quotes like  /mob/living/silicon
	 alt_name is for times when a mob is impersonating another eg "XXXX as YYYY" since XXXX stol the others ID but does not ahve a voice changer
	 held_by is for when a derrived proc for some reasons needs to define the /mob is holding it on its own or in a different way.
	 its a lot of arguments, but argslist will make your life easier, and your code easier to read.
	 and it means we can have our core whisper in one file. if core whisper mechanics change  need to change we only need to edit one proc.

*/
proc/handle_quote(var/text,var/star)
	var/beginquote = findtext(text,"\"",1)
	var/begin = copytext(text,1,beginquote)
	var/quote = copytext(text,beginquote+1,length(text))
	if(star)
		quote = stars(quote)
	quote = "\"<i>[quote]</i>\""
	return begin + quote

/mob/living/whisper(message as text, quote as text,alt_name as text, held_by as mob)
	if(!src.can_whisper)
		usr << "\red This mob cannot whisper! Try something else!"
		return
	if(!IsVocal())
		return

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	message = trim(copytext(strip_html_simple(message), 1, MAX_MESSAGE_LEN))

	if (!message || silent)
		return

	log_whisper("[name]/[key] : [message]")

	if (client)
		if (client.prefs.muted & MUTE_IC)
			src << "\red You cannot whisper (muted)."
			return

		if (client.handle_spam_prevention(message,MUTE_IC))
			return


	if (stat == 2)
		return say_dead(message)

	if (stat)
		return
	// handle alt_name if one is passed, mainly whena  human is (as XXXX)
	if (src.name != GetVoice() && !alt_name)
		alt_name = GetVoice()

	if(alt_name)
		alt_name = "(as [alt_name])"
	else
		alt_name = ""
	// Mute disability
	if (sdisabilities & MUTE)
		return

	//removed italic var as its kinda pointless, it will only change if whisper is overriden or the base code was changed.
	var/message_range = 1
	var/w_text = ""

	//moved mask code to /mob/living/carbon/whisper.dm

	if (stuttering)
		message = stutter(message)

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)
	if(!held_by)
		held_by = get(loc,/mob/living)

	var/list/listening = hearers(message_range, src)
	if(held_by)
		listening -= held_by //for when we are already in the list. make sure we dont show twice..this is not always the case hence the needed -=
		listening += held_by
	var/list/eavesdropping = hearers(2, src)
	eavesdropping -= listening
	var/list/watching  = hearers(5, src)
	watching  -= listening
	watching  -= eavesdropping

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	var/rendered = null

	var/w_far = "whispers"  //for when the whispered message is not clearly heard or the hearer does not understand
	if(say_message)
		w_far = "quietly [say_message]" //if a specifc voice_message its set make it look unique

	if(quote)
		w_text = "quietly"
	else
		if(!voice_message)
			w_text = "whispers,"
		else
			w_text = "quietly [say_message],"

	for (var/mob/M in watching)
		if (M.say_understands(src))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> [w_far] something.</span>"
		else
			rendered = "<span class='game say'><span class='name'>[voice_name]</span> [w_far] something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message
		if(!quote)
			message_a = "\"<i>[message]</i>\""
		else
			message_a = handle_quote(quote)
		//This appears copied from carbon/living say.dm so the istype check for mob is probably not needed. Appending for src is also not needed as the game will check that automatically.
		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [w_text] <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 2)

	if (length(heard_b))
		var/message_b

		if (voice_message)
			rendered = "<span class='game say'><span class='name'>[voice_name]</span> [w_far] something.</span>"
		else
			if(!quote)
				message_b = stars(message)
				message_b = "\"<i>[message_b]</i>\""
			else
				message_b = handle_quote(quote,1)
			rendered = "<span class='game say'><span class='name'>[voice_name]</span> [w_far], <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (M.say_understands(src))
			var/message_c
			if(!quote)
				message_c = stars(message)
				message_c = "\"<i>[message_c]<\i>\""
			else
				message_c = handle_quote(quote,1)
			rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [w_far], <span class='message'>[message_c]</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[voice_name]</span> [w_far] something.</span>"
			M.show_message(rendered, 2)

	if(!quote)
		message = "\"<i>[message]</i>\""
	else
		message = handle_quote(quote)
	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [w_text], <span class='message'>[message]</span></span>"

	for (var/mob/M in dead_mob_list)
		if (!(M.client))
			continue
		if (M.stat > 1 && !(M in heard_a))
			M.show_message(rendered, 2)