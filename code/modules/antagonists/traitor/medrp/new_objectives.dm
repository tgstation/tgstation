

/obj/effect/proc_holder/spell/self/add_objectives //If all of your objectives are done, you get two more.
	name = "Request More Objectives"
	desc = "Grants you more objectives if every objective you have right now is complete."
	still_recharging_msg = "<span class='notice'>You need to wait for awhile between objective requests.</span>"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	charge_max	= 10 MINUTES
	charge_counter = 0

/obj/effect/proc_holder/spell/self/add_objectives/cast(list/targets, mob/living/carbon/human/user)

	var/datum/antagonist/traitor/roleplay/antag_datum = user.mind.has_antag_datum(/datum/antagonist/traitor/roleplay)
	if(!antag_datum)
		to_chat(user, "<span class='warning'>You aren't evil anymore! You don't need this.</span>")
		user.mind.RemoveSpell(src)
	var/list/incomplete_objectives = list()
	for(var/o in antag_datum.objectives)
		var/datum/objective/objective = o
		if(objective.end_round_completion)
			continue //these are stuff like hijack, they cannot count as a failed objective since they are your entire round's goal
		if(!objective.check_completion())
			incomplete_objectives += objective
	if(incomplete_objectives.len)
		to_chat(user, "<span class='warning'>You cannot be granted more objectives because you still need to:</span>")
		var/list/requirements = list()
		for(var/oo in incomplete_objectives)
			var/datum/objective/bad_objective = oo
			requirements += bad_objective.explanation_text
		to_chat(user, requirements.Join("\n"))
		return
	to_chat(user, "<span class='nicegreen'>You have been granted more objectives!</span>")
	antag_datum.forge_single_human_objective()
	antag_datum.forge_single_human_objective()
	user.mind.announce_objectives()
