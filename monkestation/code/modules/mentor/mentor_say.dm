/client/proc/get_mentor_say()
	var/msg = input(src, null, "msay \"text\"") as text|null
	cmd_mentor_say(msg)

/client/proc/cmd_mentor_say(msg as text)
	set category = "Mentor"
	set name = "Msay"
	set hidden = TRUE
	if(!is_mentor())
		return

	msg = emoji_parse(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	log_mentor("MSAY: [key_name(src)] : [msg]")
	msg = keywords_lookup(msg)
	if(check_rights_for(src, R_ADMIN))
		msg = "[span_mentorsay("[span_prefix("MENTOR:")] <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(mob)]: <font color'#8A2BE2'><span class='message linkify'>[msg]")]</span></font>"
	else
		msg = "[span_mentorsay("[span_prefix("MENTOR:")] <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(mob)]: <font color='#E236D8'><span class='message linkify'>[msg]")]</span></font>"
	var/list/send_to = list()
	send_to |= GLOB.mentors
	send_to |= GLOB.admins
	to_chat(send_to,
		type = MESSAGE_TYPE_MENTORCHAT,
		html = msg,
		confidential = TRUE)

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Msay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
