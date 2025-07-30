/datum/antagonist/wild_slugcat
	name = "\improper Wild slugcat"
	pref_flag = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_ASHWALKERS
	suicide_cry = "meow!"
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST
	var/datum/team/wild_slugcat/wild_slugcat_team

/datum/antagonist/wild_slugcat/create_team(datum/team/wild_slugcat/wild_slugcat_team)
	if(wild_slugcat_team)
		wild_slugcat_team = wild_slugcat_team
		objectives |= wild_slugcat_team.objectives
	else
		wild_slugcat_team = new

/datum/antagonist/wild_slugcat/get_team()
	return wild_slugcat_team

/datum/antagonist/wild_slugcat/on_gain()
	. = ..()
	owner.teach_crafting_recipe(/datum/crafting_recipe/skeleton_key)
	if(FACTION_NEUTRAL in owner.current.faction)
		owner.current.faction.Remove(FACTION_NEUTRAL)

/datum/antagonist/wild_slugcat/on_removal()
	. = ..()
	if(!owner.current)
		return
	if(!(FACTION_NEUTRAL in owner.current.faction))
		owner.current.faction.Add(FACTION_NEUTRAL)

/datum/team/wild_slugcat
	name = "Wild Slugcat Tribe"
	member_name = "scug"
	///A list of "worthy" (meat-bearing) sacrifices made to the Necropolis
	var/sacrifices_made = 0

/datum/team/wild_slugcat/roundend_report()
	var/list/report = list()

	report += span_header("A wild slugcat tribe inhabited the ocean...</span><br>")
	if(length(members)) //The team is generated alongside the tendril, and it's entirely possible that nobody takes the role.
		report += "The [member_name]s were:"
		report += printplayerlist(members)

		var/datum/objective/protect_object/tribe_objective = locate(/datum/objective/protect_object) in objectives

		if(tribe_objective)
			objectives -= tribe_objective //So we don't count it in the check for other objectives.
			report += "<b>The [name] was tasked with defending the nest:</b>"
			if(tribe_objective.check_completion())
				report += span_greentext(span_header("The nest stands!<br>"))
			else
				report += span_redtext(span_header("The nest was destroyed...<br>"))

		if(length(objectives))
			report += span_header("The [name]'s other objectives were:")
			printobjectives(objectives)

		report += "The [name] managed to perform <b>[sacrifices_made]</b> sacrifices to the nest."

	else
		report += "<b>But none of them awakened.</b>"

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"
