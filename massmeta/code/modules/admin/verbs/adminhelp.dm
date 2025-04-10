/datum/admin_help/ClosureLinks(ref_src)
	. = ..()
	. += " (<A HREF='?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=skillissue'>SKILL</A>)"

//Resolve ticket with skill issue message
/datum/admin_help/proc/SkillIssue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as a skill issue! -</b></font><br>"
	msg += "<font color='red'>Your issue has been determined by an administrator to be an issue of skill and does NOT require administrator intervention at this time. For further resolution you should pursue skill related options, such as improving at the game.</font>"

	if(initiator)
		to_chat(initiator, msg, confidential = TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "skill_issue")
	msg = "Ticket [TicketHref("#[id]")] marked as skill issue by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Marked as skill issue by [key_name]", player_message = "Marked as skill issue!")
	SSblackbox.LogAhelp(id, "Skill Issue", "Marked as skill issue by [usr.key]", null,  usr.ckey)
	Resolve(silent = TRUE)

//Forwarded action from admin/Topic
/datum/admin_help/Action(action)
	..()
	switch(action)
		if("skillissue")
			SkillIssue()
