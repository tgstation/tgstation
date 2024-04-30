/proc/printborer(datum/mind/borer)
	var/list/text = list()
	var/mob/living/basic/cortical_borer/player_borer = borer.current
	if(!player_borer)
		text += span_redtext("[span_bold(borer.name)] had their body destroyed.")
		return text.Join("<br>")
	if(borer.current.stat != DEAD)
		text += "[span_bold(player_borer.name)] [span_greentext("survived")]"
	else
		text += "[span_bold(player_borer.name)] [span_redtext("died")]"
	text += span_bold("[span_bold(player_borer.name)] produced [player_borer.children_produced] borers.")
	var/list/string_of_genomes = list()

	for(var/evo_index in player_borer.past_evolutions)
		var/datum/borer_evolution/evolution = player_borer.past_evolutions[evo_index]
		string_of_genomes += evolution.name

	text += "[span_bold(player_borer.name)] had the following evolutions: [english_list(string_of_genomes)]"
	return text.Join("<br>")

/proc/printborerlist(list/players,fleecheck)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M in players)
		parts += "<li>[printborer(M)]</li>"
	parts += "</ul>"
	return parts.Join("<br>")

/datum/team/cortical_borers
	name = "Cortical Borers"

/datum/team/cortical_borers/roundend_report()
	var/list/parts = list()
	parts += span_header("The [name] were:")
	parts += printborerlist(members)
	var/survival = FALSE
	for(var/mob/living/basic/cortical_borer/check_borer in GLOB.cortical_borers)
		if(check_borer.stat == DEAD)
			continue
		survival = TRUE
	if(survival)
		parts += span_greentext("Borers were able to survive the shift!")
	else
		parts += span_redtext("Borers were unable to survive the shift!")
	if(GLOB.successful_egg_number >= GLOB.objective_egg_borer_number)
		parts += span_greentext("Borers were able to produce enough eggs!")
	else
		parts += span_redtext("Borers were unable to produce enough eggs!")
	if(length(GLOB.willing_hosts) >= GLOB.objective_willing_hosts)
		parts += span_greentext("Borers were able to gather enough willing hosts!")
	else
		parts += span_redtext("Borers were unable to gather enough willing hosts!")
	if(GLOB.successful_blood_chem >= GLOB.objective_blood_borer)
		parts += span_greentext("Borers were able to learn enough chemicals through the blood!")
	else
		parts += span_redtext("Borers were unable to learn enough chemicals through the blood!")
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
