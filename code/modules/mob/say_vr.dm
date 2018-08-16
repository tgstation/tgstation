//////////////////////////////////////////////////////
////////////////////SUBTLE COMMAND////////////////////
//////////////////////////////////////////////////////
/mob
	var/flavor_text = "" //tired of fucking double checking this

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		usr << "No."
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		src << "<h2 class='alert'>OOC Warning:</h2>"
		src << "<span class='alert'>Your flavor text is likely out of date! <a href='?src=[REF(src)];flavor_change=1'>Change</a></span>"

/mob/proc/print_flavor_text()
	if(flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(lentext(msg) <= 40)
			return "<span class='notice'>[msg]</span>"
		else
			return "<span class='notice'>[copytext(msg, 1, 37)]... <a href='?src=[REF(src)];flavor_more=1'>More...</span></a>"

/mob/proc/get_top_level_mob()
	if(istype(src.loc,/mob)&&src.loc!=src)
		var/mob/M=src.loc
		return M.get_top_level_mob()
	return src

proc/get_top_level_mob(var/mob/S)
	if(istype(S.loc,/mob)&&S.loc!=S)
		var/mob/M=S.loc
		return M.get_top_level_mob()
	return S




///////////////// EMOTE CODE
// Maybe making this as an emote is less messy?
// It was - ktccd
/datum/emote/living/subtle
	key = "subtle"
	key_third_person = "subtle"
	message = null
	mob_type_blacklist_typecache = list(/mob/living/brain)


/datum/emote/living/subtle/proc/check_invalid(mob/user, input)
	. = TRUE
	if(copytext(input,1,5) == "says")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,9) == "exclaims")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,6) == "yells")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,5) == "asks")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else
		. = FALSE

/datum/emote/living/subtle/run_emote(mob/user, params, type_override = null)
	if(jobban_isbanned(user, "emote"))
		to_chat(user, "You cannot send subtle emotes (banned).")
		return FALSE
	else if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, "You cannot send IC messages (muted).")
		return FALSE
	else if(!params)
		var/subtle_emote = copytext(sanitize(input("Choose an emote to display.") as message|null), 1, MAX_MESSAGE_LEN)
		if(subtle_emote && !check_invalid(user, subtle_emote))
			var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
			switch(type)
				if("Visible")
					emote_type = EMOTE_VISIBLE
				if("Hearable")
					emote_type = EMOTE_AUDIBLE
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
			message = subtle_emote
		else
			return FALSE
	else
		message = params
		if(type_override)
			emote_type = type_override
	. = TRUE
	if(!can_run_emote(user))
		return FALSE

	user.log_message(message, INDIVIDUAL_EMOTE_LOG)
	message = "<b>[user]</b> " + "<i>[message]</i>"

	for(var/mob/M in GLOB.dead_mob_list)
		if(!M.client || isnewplayer(M))
			continue
		var/T = get_turf(src)
		if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
			M.show_message(message)

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(message=message,hearing_distance=1)
	else
		user.visible_message(message=message,self_message=message,vision_distance=1)
	log_emote("[key_name(user)] : [message]")

	message = null
	emote_type = EMOTE_VISIBLE

///////////////// VERB CODE
/mob/living/verb/subtle()
	set name = "Subtle"
	set category = "IC"
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return
	usr.emote("subtle")
