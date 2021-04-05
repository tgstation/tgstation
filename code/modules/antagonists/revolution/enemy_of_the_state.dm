
/datum/antagonist/enemy_of_the_state
	name = "enemy of the state"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	hijack_speed = 2 //not like they have much to do

/datum/antagonist/enemy_of_the_state/proc/forge_objectives()

	var/datum/objective/exile/choice_1 = new
	choice_1.owner = owner
	choice_1.objective_name = "Choice"
	objectives += choice_1

	var/datum/objective/hijack/choice_2 = new
	choice_2.owner = owner
	choice_2.objective_name = "Choice"
	objectives += choice_2

/datum/antagonist/enemy_of_the_state/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/enemy_of_the_state/greet()
	to_chat(owner, "<span class='userdanger'>The revolution is dead.</span>")
	to_chat(owner, "<span class='boldannounce'>You're an enemy of the state to Nanotrasen. You're a loose end to the Syndicate.</span>")
	to_chat(owner, "<b>It's time to live out your days as an exile... or go out in one last big bang.</b>")
	owner.announce_objectives()

/datum/antagonist/enemy_of_the_state/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("Antagonist datum without owner")

	report += printplayer(owner)

	//needs to complete only one objective, not all

	var/option_chosen = FALSE
	var/badass = FALSE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				option_chosen = TRUE
				if(istype(objective, /datum/objective/hijack))
					badass = TRUE
				break

	if(objectives.len == 0 || option_chosen)
		if(badass)
			report += "<span class='greentext big'>Major [name] Victory</span>"
			report += "<B>[name] chose the badass option, and hijacked the shuttle!</B>"
		else
			report += "<span class='greentext big'>Minor [name] Victory</span>"
			report += "<B>[name] has survived as an exile!</B>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")
