/*!
Basically the traitor game mode but with an agent who works against the other syndicate operatives, attempting to extract one or more of them.
*/
/datum/game_mode/traitor/special_agent
	name = "traitor+specialagent"
	config_tag = "traitoragent"
	report_type = "traitoragent"
	antag_flag = ROLE_SPECIAL_AGENT
	fale_report_weight = 5
	restricted_jobs = list("AI","Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 5
	reroll_friendly = 1

	announce_span = "danger"
	announce_text = "There are Syndicate Agents and Special Agents on the Station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives!\n\
	<span class='danger'>Special Agents</span>: Accomplish your objectives!\n\
	<span class='notice'>Crew</span>: Do not let the traitors or special agents succeed!"

	var/list/datum/mind/pre_agents = list()
	var/list/datum/mind/agents = list()

/datum/game_mode/traitor/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	
	var/datum/minds/possible_agents = get_players_for_role(ROLE_SPECIAL_AGENT)
	
	var/num_agents = 1
	
	var/sasc = CONFIG_GET(number/special_agent_scaling_coeff)
	if(sasc)
		num_agents = max(1, min(round(num_players() / (sasc * 2)) + 2 + num_modifier, round(num_players() / sasc) + num_modifier))
	else()
		num_agents = max(1, min(num_players(), traitors_possible))
	if(possible_agents.len>0)
		for(/var/j = 0, j < num_agents, j++)
			if(!possible_agents.len)
				break 
			/var/datum/mind/agent = antag_pick(possible_agents)
			pre_agents += agent
			antag_cadidates -= agent
			possible_agents -= agent
			agent.special_role = "agent"
			agent.restricted_jobs = restricted_jobs
			log_game("[key_name(agent)] has been selected as a special agent")
		return ..()
		else()
			return 0
/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/agent in pre_agents)
		agent.add_antag_datum(/datum/antagonist/special_agent)
		agents += agent

/datum/game_mode/traitor/special_agent/make_antag_chance(mob/living/carbon/human/character)
	var/sasc = CONFIG_GET(number/special_agent_scaling_coeff)
	var/agentcap = min( round(GLOB.joined_player_list.len / (sasc * 4)) + 2, round(GLOB.joined_player_list.len / (sasc * 2)))
	if(agents.len >= agentcap) //Caps number of latejoin antagonists
		..()
		return
	if(agents.len <= (agentcap - 2) || prob(100 / (csc * 4)))
		if(ROLE_SPECIAL_AGENT in character.client.prefs.be_special)
			if(!is_banned_from(character.ckey, list(ROLE_SPECIAL_AGENT, ROLE_SYNDICATE)) && !QDELETED(character))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						var/datum/antagonist/traitor/new_antag = new antag_datum()
						character.add_antag_datum(new_antag)
						agents += character.mind
	if(QDELETED(character))
		return
	..()

	
