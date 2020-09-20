/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"

	if(usr.stat == DEAD)
		return //won't work if dead
	show_laws()

/mob/living/silicon/robot/show_laws(everyone = FALSE)
	laws_sanity_check()
	var/who

	if (everyone)
		who = world
	else
		who = src

	to_chat(who, "<b>Obey these laws:</b>")
	laws.show_laws(who)
	if (shell) //AI shell
		to_chat(who, "<b>Remember, you are an AI remotely controlling your shell, other AIs can be ignored.</b>")
	else if (connected_ai)
		to_chat(who, "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>")
	else if (emagged)
		to_chat(who, "<b>Remember, you are not required to listen to the AI.</b>")
	else
		to_chat(who, "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>")


/mob/living/silicon/robot/lawsync()
	if(!connected_ai?.laws || connected_ai?.control_disabled)
		return

	laws_sanity_check()

	if(shell)
		laws.zeroth = connected_ai.laws.zeroth

	else
		if(!lawupdate)
			return

		laws.zeroth = connected_ai.laws.zeroth_borg || connected_ai.laws.zeroth

	laws.hacked = connected_ai.laws.hacked.Copy()

	laws.ion = connected_ai.laws.ion.Copy()

	laws.inherent = connected_ai.laws.inherent.Copy()

	laws.supplied = connected_ai.laws.supplied.Copy()

	post_lawchange(FALSE)

	picturesync()
