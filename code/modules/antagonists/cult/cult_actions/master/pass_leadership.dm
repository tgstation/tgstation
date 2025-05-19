/datum/action/innate/cult/master/pass_role
	name = "Pass the Mantle"
	desc = "Pass the Master role onto another willing cultist. This can only be done once!"
	button_icon_state = "cultvote"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED

/datum/action/innate/cult/master/pass_role/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return
	var/datum/antagonist/cult/mind_cult_datum = owner.mind.has_antag_datum(/datum/antagonist/cult)
	if(!mind_cult_datum || mind_cult_datum.cult_team.leader_passed_on)
		return FALSE

/datum/action/innate/cult/master/pass_role/Activate()
	var/list/choices = list()
	var/datum/antagonist/cult/owner_datum = owner.mind.has_antag_datum(/datum/antagonist/cult)
	for(var/datum/mind/team_member as anything in owner_datum.cult_team.members)
		if(!team_member.current || !ishuman(team_member.current) || team_member.current == owner || team_member.current.stat == DEAD)
			continue

		choices[team_member.current.real_name] = team_member

	var/new_master = tgui_input_list(owner, "Select another cult member to pass the cult's Master role onto.", "Pass the Mantle", choices)
	if (!new_master || !IsAvailable())
		return

	var/confirmation = tgui_alert(owner, "Are you sure that you want to make [new_master] the new Master? This can only be done once!", "Pass the Mantle", list("Yes", "No"))
	if (confirmation != "Yes" || !IsAvailable())
		return

	var/datum/mind/master_mind = choices[new_master]
	var/mob/living/carbon/human/master = master_mind.current
	if (!master || master.stat == DEAD || !master.client)
		to_chat(owner, span_cult("[new_master] can no longer take on the role of a Master."))
		return

	var/datum/antagonist/cult/target_datum = master_mind.has_antag_datum(/datum/antagonist/cult)
	if(!target_datum || owner_datum.cult_team != target_datum?.cult_team)
		to_chat(owner, span_cult("[new_master] can no longer take on the role of a Master."))
		return

	SEND_SOUND(master, sound('sound/effects/magic.ogg', volume = 33))
	confirmation = tgui_alert(master, "[owner.real_name] is offering their role as the cult's Master to you! Do you wish to accept it?", "Take the Mantle", list("Yes", "No"))

	if (confirmation != "Yes")
		to_chat(owner, span_cult("[new_master] has declined your offer."))
		return

	if (!IsAvailable() || !master_mind.has_antag_datum(/datum/antagonist/cult) || !master.client)
		to_chat(owner, span_cult("[new_master] can no longer take on the role of a Master."))
		return

	target_datum.cult_team.leader_passed_on = TRUE
	owner_datum.demote_from_leader()
	target_datum.make_cult_leader()

