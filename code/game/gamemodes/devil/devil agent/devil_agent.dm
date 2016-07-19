/datum/game_mode/devil/devil_agents
	name = "Devil Agents"
	config_tag = "devil_agents"
	required_players = 25
	required_enemies = 3
	recommended_enemies = 8
	reroll_friendly = 0

	traitors_possible = 10 //hard limit on traitors if scaling is turned off
	num_modifier = 6 // Six additional traitors
	objective_count = 2

	var/list/target_list = list()
	var/list/late_joining_list = list()

/datum/game_mode/devil/devil_agents/announce()
	world << "<B>The current game mode is - Devil Agents!</B>"
	world << "<B>There are several devils onboard the station, trying to each buy more souls than the other.</B>"

/datum/game_mode/devil/devil_agents/post_setup()
	var/i = 0
	for(var/datum/mind/devil in devils)
		i++
		if(i + 1 > devils.len)
			i = 0
		target_list[devil] = devils[i + 1]
	..()

/datum/game_mode/devil/devil_agents/add_devil_objectives(datum/mind/devil_mind, quantity)
	..(devil_mind, quantity - give_outsell_objective(devil_mind))

/datum/game_mode/devil/devil_agents/proc/give_outsell_objective(datum/mind/devil)
	//If you override this method, have it return the number of objectives added.
	if(target_list.len && target_list[devil]) // Is a double agent
		var/datum/mind/target_mind = target_list[devil]
		var/datum/objective/devil/outsell/outsellobjective = new
		outsellobjective.owner = devil
		outsellobjective.target = target_mind
		outsellobjective.update_explanation_text()
		devil.objectives += outsellobjective
		return 1
	return 0
