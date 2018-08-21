/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay"
	set hidden = 1
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!src.mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='danger'>You cannot send DSAY messages (muted).</span>")
		return

	if (src.handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	mob.log_talk(msg, LOG_DSAY)

	if (!msg)
		return
	var/static/nicknames = world.file2list("[global.config.directory]/admin_nicknames.txt")

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[uppertext(holder.rank)]([src.holder.fakekey ? pick(nicknames) : src.key])</span> says, <span class='message'>\"[emoji_parse(msg)]\"</span></span>"

	for (var/mob/M in GLOB.player_list)
		if(isnewplayer(M))
			continue
		if (M.stat == DEAD || (M.client && M.client.holder && (M.client.prefs.chat_toggles & CHAT_DEAD))) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			to_chat(M, rendered)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dead_say()
	var/msg = input(src, null, "dsay \"text\"") as text
	dsay(msg)
