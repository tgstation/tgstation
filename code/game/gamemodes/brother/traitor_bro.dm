/datum/brother_team
	var/list/datum/mind/members = list()
	var/meeting_area

/datum/game_mode
	var/list/datum/mind/brothers = list()

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

	var/list/datum/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2

	var/meeting_areas = list("Medbay Entrance", "Science Entrance", "Engineering Entrance", "Bridge Entrance", "The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage")

/datum/game_mode/traitor/bros/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_bros = get_players_for_role(ROLE_BROTHER)

	var/num_teams = 1
	if(config.brother_scaling_coeff)
		num_teams = max(1, min( round(num_players()/(config.brother_scaling_coeff*4))+2, round(num_players()/(config.brother_scaling_coeff*2)) ))
	else
		num_teams = max(1, min(num_players(), team_amount))

	for(var/j = 0, j < num_teams, j++)
		if(possible_bros.len < min_team_size) 
			break

		var/datum/brother_team/team = new
		team.meeting_area = pick(meeting_areas)
		meeting_areas -= team.meeting_area
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
	for(var/datum/brother_team/team in pre_brother_teams)
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(ANTAG_DATUM_BROTHER, team)
			modePlayer += M
	..()

/datum/game_mode/proc/auto_declare_completion_brother()
	if(brothers.len)
		var/text = "<br><font size=4><b>The blood brothers were:</b></font>"
		var/list/teams = list()
		for(var/datum/mind/B in brothers)
			var/datum/antagonist/brother/brother_datum = B.has_antag_datum(ANTAG_DATUM_BROTHER)
			if(brother_datum && !(brother_datum.team in teams))
				teams += brother_datum.team

		var/teamnumber = 1
		for(var/datum/brother_team/team in teams)
			if(!team.members.len)
				continue
			var/datum/mind/first_brother = team.members[1]
			var/datum/antagonist/brother/brother_datum = first_brother.has_antag_datum(ANTAG_DATUM_BROTHER)
			if(!brother_datum)
				continue

			var/members_text = ""
			for(var/i = 1 to team.members.len)
				var/datum/mind/M = team.members[i]
				members_text += M.name
				if(i == brothers.len - 1)
					members_text += " and "
				else if(i != brothers.len)
					members_text += ", "

			text += "<br><font size=3><b>Team #[teamnumber++]</b></font>"
			text += "<br><b>Members:</b> [members_text]."

			var/win = TRUE
			var/objectives = ""
			var/objective_count = 1
			for(var/datum/objective/objective in brother_datum.objectives_given)
				if(objective.check_completion())
					objectives += "<br><B>Objective #[objective_count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					SSblackbox.add_details("traitor_objective","[objective.type]|SUCCESS")
				else
					objectives += "<br><B>Objective #[objective_count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					SSblackbox.add_details("traitor_objective","[objective.type]|FAIL")
					win = FALSE
				objective_count++
			text += objectives
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
