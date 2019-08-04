// Contains cult communion, guide
/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"

/datum/action/innate/cult/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return
	cultist_commune(usr, input)

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	user.whisper("O bidai nabora se'sma!", language = /datum/language/common)
	var/title = "Acolyte"
	var/span = "cult italic"
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/cult/master))
		span = "cultlarge"
		title = "Master"
	else if(!ishuman(user))
		title = "Construct"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(iscultist(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")
	user.log_talk(message, LOG_SAY, tag="cult")

/datum/action/innate/cult/mastervote
	name = "Assert Leadership"
	button_icon_state = "cultvote"

/datum/action/innate/cult/mastervote/IsAvailable()
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C || C.cult_team.cult_vote_called || !ishuman(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/mastervote/Activate()
	var/choice = alert(owner, "The mantle of leadership is heavy. Success in this role requires an expert level of communication and experience. Are you sure?",, "Yes", "No")
	if(choice == "Yes" && IsAvailable())
		var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
		pollCultists(owner,C.cult_team)

/proc/pollCultists(var/mob/living/Nominee,datum/team/cult/team) //Cult Master Poll
	if(world.time < CULT_POLL_WAIT)
		to_chat(Nominee, "It would be premature to select a leader while everyone is still settling in, try again in [DisplayTimeText(CULT_POLL_WAIT-world.time)].")
		return
	team.cult_vote_called = TRUE //somebody's trying to be a master, make sure we don't let anyone else try
	team.message_all_cultists("<span class='cultlarge'>Acolyte [Nominee] has asserted that [Nominee.p_theyre()] worthy of leading the cult. A vote will be called shortly.</span>")
	for(var/datum/mind/B in team.members)
		if(B.current)
			B.current.update_action_buttons_icon()
	sleep(100)
	var/list/asked_cultists = list()
	for(var/datum/mind/B in team.members)
		if(B.current && B.current != Nominee && !B.current.incapacitated())
			SEND_SOUND(B.current, 'sound/magic/exit_blood.ogg')
			asked_cultists += B.current
	var/list/yes_voters = pollCandidates("[Nominee] seeks to lead your cult, do you support [Nominee.p_them()]?", poll_time = 300, group = asked_cultists)
	if(QDELETED(Nominee) || Nominee.incapacitated())
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,"<span class='cultlarge'>[Nominee] has died in the process of attempting to win the cult's support!</span>")
		return FALSE
	if(!Nominee.mind)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,"<span class='cultlarge'>[Nominee] has gone catatonic in the process of attempting to win the cult's support!</span>")
		return FALSE
	if(LAZYLEN(yes_voters) <= LAZYLEN(asked_cultists) * 0.5)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current, "<span class='cultlarge'>[Nominee] could not win the cult's support and shall continue to serve as an acolyte.</span>")
		return FALSE
	team.cult_master = Nominee
	SSticker.mode.remove_cultist(Nominee.mind, TRUE)
	Nominee.mind.add_antag_datum(/datum/antagonist/cult/master)
	team.message_all_cultists("<span class='cultlarge'>[Nominee] has won the cult's support and is now their master. Follow [Nominee.p_their()] orders to the best of your ability!</span>")
	for(var/datum/mind/B in team.members)
		if(B.current)
			for(var/datum/action/innate/cult/mastervote/vote in B.current.actions)
				vote.Remove(B.current)
	return TRUE

/datum/action/innate/cult/master/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(/datum/antagonist/cult/master) || GLOB.cult_narsie)
		return 0
	return ..()
