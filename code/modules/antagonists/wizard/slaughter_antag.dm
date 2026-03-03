/datum/antagonist/slaughter
	name = "\improper Slaughter Demon"
	roundend_category = "demons"
	show_name_in_check_antagonists = TRUE
	ui_name = "AntagInfoDemon"
	pref_flag = ROLE_ALIEN
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_WIZARDS
	var/fluff = "You're a Demon of Wrath, often dragged into reality by wizards to terrorize their enemies."
	var/objective_verb = "Kill"
	var/datum/mind/summoner
	/// consume count for statistics
	var/consume_count = 0

/datum/antagonist/slaughter/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/slaughter/greet()
	. = ..()
	owner.announce_objectives()
	to_chat(owner, span_warning("You have a powerful alt-attack that slams people backwards that you can activate by right-clicking your target!"))

/datum/antagonist/slaughter/forge_objectives()
	if(summoner)
		var/datum/objective/assassinate/new_objective = new /datum/objective/assassinate
		new_objective.owner = owner
		new_objective.target = summoner
		new_objective.explanation_text = "[objective_verb] [summoner.name], the one who summoned you."
		objectives += new_objective
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = owner
	new_objective2.no_failure = TRUE
	new_objective2.explanation_text = "[objective_verb] everyone[summoner ? " else while you're at it":""]."
	objectives += new_objective2

/datum/antagonist/slaughter/ui_static_data(mob/user)
	var/list/data = list()
	data["fluff"] = fluff
	data["objectives"] = get_objectives()
	data["explain_attack"] = TRUE
	return data

/datum/antagonist/slaughter/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("Antagonist datum without owner")

	report += printplayer(owner)

	if(objectives.len)
		report += printobjectives(objectives)

	if(consume_count > 0)
		report += span_greentext("The [name] consumed a total of [consume_count] bodies!")
	else
		report += span_redtext("The [name] did not consume anyone! Shame!!")

	if(isnull(owner.current) || owner.current.stat == DEAD) //demons delete on death but if someone makes like a subtype that doesnt we also check for stat
		report += "<span class='redtext big'>The [name] was vanquished!</span>"
	else
		report += "<span class='greentext big'>The [name] survived!</span>"

	return report.Join("<br>")

/datum/antagonist/slaughter/laughter
	name = "Laughter demon"
	objective_verb = "Hug and tickle"
	fluff = "You're a Demon of Envy, sometimes dragged into reality by wizards as a way to cause wanton chaos."
