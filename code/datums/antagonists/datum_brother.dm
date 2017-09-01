/datum/antagonist/brother
	name = "Brother"
	var/special_role = "blood brother"
	var/list/objectives_given = list()
	var/datum/brother_team/team

/datum/antagonist/brother/New(datum/mind/new_owner, datum/brother_team/T)
	team = T
	..()

/datum/antagonist/brother/on_gain()
	SSticker.mode.brothers += owner
	owner.special_role = special_role
	forge_brother_objectives()
	finalize_brother()
	..()

/datum/antagonist/brother/on_removal()
	SSticker.mode.brothers -= owner
	for(var/O in objectives_given)
		owner.objectives -= O
	objectives_given = list()
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()

/datum/antagonist/brother/proc/add_objective(var/datum/objective/O)
	O.update_explanation_text()
	owner.objectives += O
	objectives_given += O

/datum/antagonist/brother/proc/forge_brother_objectives()
	//If one of our brothers already has objectives, just copy his rather than create new ones.
	for(var/datum/mind/M in team.members)
		if(M != owner && M.has_antag_datum(ANTAG_DATUM_BROTHER))
			var/datum/antagonist/brother/brother_datum = M.has_antag_datum(ANTAG_DATUM_BROTHER)
			if(brother_datum.objectives_given.len)
				objectives_given = brother_datum.objectives_given.Copy()
				owner.objectives += brother_datum.objectives_given
				return

	var/is_hijacker = prob(10)
	var/objective_count = is_hijacker //Hijacking counts towards number of objectives
	for(var/i = objective_count, i < config.brother_objectives_amount, i++)
		forge_single_objective()

	if(is_hijacker && objective_count <= config.brother_objectives_amount) //Don't assign hijack if it would exceed the number of objectives set in config.brother_objectives_amount
		if(!(locate(/datum/objective/hijack) in owner.objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.conspirators = team.members
			add_objective(hijack_objective)
			return

	if(!(locate(/datum/objective/escape) in owner.objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.conspirators = team.members
		add_objective(escape_objective)

/datum/antagonist/brother/proc/forge_single_objective() //Returns how many objectives are added
	. = 1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.conspirators = team.members
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.conspirators = team.members
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.conspirators = team.members
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.conspirators = team.members
		steal_objective.find_target()
		add_objective(steal_objective)

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team.meeting_area)
		return
	to_chat(owner.current, "<B>Your designated meeting area:</B> [team.meeting_area]")
	owner.store_memory("<b>Meeting Area</b>: [team.meeting_area]")

/datum/antagonist/brother/greet()
	var/brother_text = ""
	var/list/brothers = team.members - owner
	for(var/i = 1 to brothers.len)
		var/datum/mind/M = brothers[i]
		brother_text += M.name
		if(i == brothers.len - 1)
			brother_text += " and "
		else if(i != brothers.len)
			brother_text += ", "
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role] of [brother_text].</font></B>")
	to_chat(owner.current, "The Syndicate only accepts those who have proven themself. Prove yourself and prove your brothers by completing your objectives together!")
	owner.announce_objectives()
	give_meeting_area()

/datum/antagonist/brother/proc/finalize_brother()
	SSticker.mode.update_brother_icons_added(owner)
