/datum/admin_help/ClosureLinks(ref_src)
	. = ..()
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=mhelp'>MHELP</A>)"

/**
 * We're overwriting /datum/admin_help/proc/Action(action)
 * This is to add the "Mhelp" button to the admin_help's Action
 */

/datum/admin_help/Action(action)
	. = ..()
	switch(action)
		if("mhelp")
			MHelpThis()

/datum/admin_help/proc/MHelpThis(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	if(initiator)
		initiator.giveadminhelpverb()

		SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))

		to_chat(initiator, "<font color='red' size='4'><b>- MentorHelp Question! -</b></font>")
		to_chat(initiator, "<font color='red'>This question is about <b>game mechanics</b>, so should be asked in <b>Mentorhelp</b> instead. To do so, use the <b>Mentorhelp</b> verb under the <b>Mentor<b> tab on the upper right of your screen.</font>")

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "mhelp this")
	var/msg = "Ticket [TicketHref("#[id]")] told to mentorhelp by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Told to mentorhelp by [key_name].")
	Close(silent = TRUE)
