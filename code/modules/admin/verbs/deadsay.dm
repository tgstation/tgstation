/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay"
	set hidden = 1
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!mob)
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_talk(mob,"[key_name(src)] : [msg]",LOGDSAY)

	if (!msg)
		return
	var/static/nicknames = world.file2list("[global.config.directory]/admin_nicknames.txt")
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>ADMIN([src.holder.fakekey ? pick(nicknames) : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	deadchat_broadcast(rendered)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
