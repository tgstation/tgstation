/client/proc/aooc(msg as text)
	set category = "OOC"
	set name = "AOOC"
	set desc = "Antagonist OOC"

	if(!check_rights(R_ADMIN))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	msg = emoji_parse(msg)

	var/display_name = src.key
	if(holder && holder.fakekey)
		display_name = holder.fakekey

	for(var/X in GLOB.mob_list)
		var/mob/M = X
		if((M.mind && M.mind.special_role && M.client) || (M.client && check_rights_for(M, R_ADMIN)))
			to_chat(M, "<font color='#960018'><span class='ooc'><span class='prefix'>ANTAG OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")

	log_ooc("(ANTAG) [key] : [msg]")