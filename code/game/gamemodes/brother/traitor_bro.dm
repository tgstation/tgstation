/datum/objective_team/brother_team
	name = "brotherhood" 
	member_name = "blood brother" 
	var/list/objectives = list()
	var/meeting_area

/datum/objective_team/brother_team/is_solo()
	return FALSE

/datum/objective_team/brother_team/proc/add_objective(datum/objective/O)
	O.update_explanation_text()
	objectives += O

/datum/objective_team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/single_objectives_amount = config.brother_objectives_amount
	if(members.len > 2)
		++single_objectives_amount
	var/is_hijacker = single_objectives_amount > 0 && prob(10)
	if(is_hijacker)
		--single_objectives_amount
	for(var/i = 0, i < single_objectives_amount, i++)
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.team = src
			add_objective(hijack_objective)
	else if(!locate(/datum/objective/escape) in objectives)
		var/datum/objective/escape/escape_objective = new
		escape_objective.team = src
		add_objective(escape_objective)

/datum/objective_team/brother_team/proc/forge_single_objective() //Returns how many objectives are added
	. = 1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.team = src
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.team = src
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.team = src
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.team = src
		steal_objective.find_target()
		add_objective(steal_objective)

/datum/game_mode
	var/list/datum/mind/brothers = list()
	var/list/datum/objective_team/brother_team/brother_teams = list()

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	antag_flag = ROLE_BROTHER
	restricted_jobs = list("AI", "Cyborg")
	required_players = 0
	required_enemies = 2 // It's just called two brothers.
	recommended_enemies = 4
	reroll_friendly = TRUE
	enemy_minimum_age = 7

	announce_span = "danger"
	announce_text = "There are Syndicate agents and Blood Brothers on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Blood Brothers</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or brothers succeed!"

	var/list/datum/objective_team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2

	var/meeting_areas = list("Medbay Entrance", "Science Entrance", "Engineering Entrance", "Bridge Entrance", "The Bar", "Kitchen", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area")

/datum/game_mode/traitor/bros/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_bros = get_players_for_role(ROLE_BROTHER)
	var/num_teams = max(1, team_amount)
	if(config.brother_scaling_coeff)
		num_teams = max(1, round(num_players()/config.brother_scaling_coeff))

	for(var/j = 0, j < num_teams, j++)
		if(possible_bros.len < min_team_size) 
			break
		var/datum/objective_team/brother_team/team = new
		var/team_size = pick(10) ? min(3, possible_bros.len) : 2
		for(var/k = 0, k < team_size, k++)
			var/datum/mind/bro = pick(possible_bros)
			antag_candidates -= bro
			possible_bros -= bro
			team.members += bro
			bro.restricted_roles = restricted_jobs
			log_game("[bro.key] (ckey) has been selected as a Brother")
		pre_brother_teams += team
	return pre_brother_teams.len ? ..() : FALSE

/datum/game_mode/traitor/bros/post_setup()
	for(var/datum/objective_team/brother_team/team in pre_brother_teams)
		team.meeting_area = pick(meeting_areas)
		meeting_areas -= team.meeting_area
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(ANTAG_DATUM_BROTHER, team)
			modePlayer += M
	brother_teams += pre_brother_teams
	..()

/datum/game_mode/proc/auto_declare_completion_brother()
	if(LAZYLEN(brother_teams))
		var/text = "<br><font size=4><b>The blood brothers were:</b></font>"
		var/teamnumber = 1
		for(var/datum/objective_team/brother_team/team in brother_teams)
			if(!team.members.len)
				continue
			text += "<br><font size=3><b>Team #[teamnumber++]</b></font>"
			for(var/datum/mind/M in team.members)
				text += printplayer(M)
			var/win = TRUE
			var/objective_count = 1
			for(var/datum/objective/objective in team.objectives)
				if(objective.check_completion())
					text += "<br><B>Objective #[objective_count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					SSblackbox.add_details("traitor_objective","[objective.type]|SUCCESS")
				else
					text += "<br><B>Objective #[objective_count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					SSblackbox.add_details("traitor_objective","[objective.type]|FAIL")
					win = FALSE
				objective_count++
			if(win)
				text += "<br><font color='green'><B>The blood brothers were successful!</B></font>"
				SSblackbox.add_details("brother_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The blood brothers have failed!</B></font>"
				SSblackbox.add_details("brother_success","FAIL")
			text += "<br>"
		to_chat(world, text)
	return TRUE

/datum/game_mode/proc/update_brother_icons_added(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.join_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, "brother")

/datum/game_mode/proc/update_brother_icons_removed(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.leave_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, null)
