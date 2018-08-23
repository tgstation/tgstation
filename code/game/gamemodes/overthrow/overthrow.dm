// Overthrow gamemode, based on the sleeping agent antagonist.
/datum/game_mode/overthrow
	name = "overthrow"
	config_tag = "overthrow"
	antag_flag = ROLE_OVERTHROW
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 1 //20 // the core idea is of a swift, bloodless coup, so it shouldn't be as chaotic as revs.
	required_enemies = 1 //2 minimum two teams, otherwise it's just nerfed revs.
	recommended_enemies = 4

	announce_span = "danger"
	announce_text = "There are sleeping Syndicate agents on the station who are trying to stage a coup!\n\
	<span class='danger'>Agents</span>: Accomplish your objectives, convert heads and targets, take control of the AI.\n\
	<span class='notice'>Crew</span>: Do not let the agents succeed!"
	var/list/initial_agents = list() // Why doesn't this exist at /game_mode level? Literally every gamemode has some sort of version for this, what the fuck

/datum/game_mode/overthrow/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/sleeping_agents = required_enemies + round(num_players()*0.1)

	for (var/i in 1 to sleeping_agents)
		if (!antag_candidates.len)
			break
		var/datum/mind/sleeping_agent = antag_pick(antag_candidates)
		antag_candidates -= sleeping_agent
		initial_agents += sleeping_agent
		sleeping_agent.restricted_roles = restricted_jobs
		sleeping_agent.special_role = ROLE_OVERTHROW

	if(initial_agents.len < required_enemies)
		setup_error = "Not enough initial sleeping agents candidates"
		return FALSE
	return TRUE

/datum/game_mode/overthrow/post_setup()
	for(var/i in initial_agents) // each agent will have its own team.
		var/datum/mind/agent = i
		var/datum/antagonist/overthrow/O = agent.add_antag_datum(/datum/antagonist/overthrow) // create_team called on_gain will create the team
		O.equip_initial_overthrow_agent()
	return ..()

/datum/game_mode/overthrow/generate_report()
	return "Some sleeping agents have managed to get aboard. Their objective is to stage a coup and take over the station stealthly."

// Calculates points for each team and displays the winners.
/datum/game_mode/overthrow/special_report() // so many for loops, i am deeply sorry
	var/list/teams = list()
	var/winnertext = ""
	for(var/i in initial_agents)
		var/datum/mind/bad_dude = i
		var/datum/antagonist/overthrow/O = bad_dude.has_antag_datum(/datum/antagonist/overthrow)
		if(istype(O)) // shouldn't be ever removed but you never know
			var/datum/team/overthrow/Oteam = O.team
			if(istype(Oteam)) // same
				teams += Oteam
	var/max_points = 0 // the maximum amount of points reached
	for(var/j in teams)
		var/datum/team/T = j
		var/points = 0 // Sum of points of all the objectives done
		for(var/k in T.objectives)
			var/datum/objective/overthrow/obj = k
			if(istype(obj))
				points += obj.get_points()
		if(max_points < points)
			max_points = points
		teams[T] = points
	// Now we will have a list of team=points and a max_points var. Let's fetch all the teams with points=maxpoints and display them as winner. This code allows multiple teams to win if they both achieved
	// the same amount of points and they got the most points out of all the teams.
	for(var/l in teams)
		var/one_winner = winnertext ? FALSE : TRUE
		var/datum/team/Tagain = l
		if(teams[Tagain] == max_points)
			winnertext += "<span class='greentext big'>The [Tagain] team [one_winner ? "" : "also"] won with [max_points] points!</span>[one_winner ? "" : "<br>"]"
	return winnertext