/datum/game_mode/overthrow
	name = "overthrow"
	config_tag = "overthrow"
	antag_flag = ROLE_TRAITOR // they are traitors after all, with a twist
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_players = 20 // the core idea is of a swift, bloodless coup, so it shouldn't be as chaotic as revs.
	required_enemies = 2 // minimum two teams, otherwise it's just nerfed revs.
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

	if(initial_agents.len < required_enemies)
		setup_error = "Not enough initial sleeping agents candidates"
		return FALSE
	return TRUE

/datum/game_mode/overthrow/post_setup()
	for(var/i in initial_agents) // each agent will have its own team.
		var/datum/mind/agent = i
		agent.add_antag_datum(/datum/antagonist/overthrow) // create_team called on_gain will create the team
	return ..()

/datum/game_mode/overthrow/generate_report()
	return "Some sleeping agents have managed to get aboard. Their objective is to stage a coup and take over the station stealthly."