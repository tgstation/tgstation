/datum/game_mode/notraitor/bros
	name = "brothers"
	config_tag = "brothers"
	restricted_jobs = list("AI", "Cyborg")

	announce_span = "danger"
	announce_text = "There are Syndicate Blood Brothers on the station!\n\
	<span class='danger'>Blood Brothers</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the brothers succeed!"

	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2
	traitors_required = FALSE //Only teams are possible

/datum/game_mode/notraitor/bros/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_brothers = get_players_for_role(ROLE_BROTHER)

	var/num_teams = team_amount
	var/bsc = CONFIG_GET(number/brother_scaling_coeff)
	if(bsc)
		num_teams = max(1, round(num_players() / bsc))

	for(var/j = 1 to num_teams)
		if(possible_brothers.len < min_team_size || antag_candidates.len <= required_enemies)
			break
		var/datum/team/brother_team/team = new
		var/team_size = prob(10) ? min(3, possible_brothers.len) : 2
		for(var/k = 1 to team_size)
			var/datum/mind/bro = antag_pick(possible_brothers)
			possible_brothers -= bro
			antag_candidates -= bro
			team.add_member(bro)
			bro.special_role = "brother"
			bro.restricted_roles = restricted_jobs
			log_game("[key_name(bro)] has been selected as a Brother")
		pre_brother_teams += team
	return ..()

/datum/game_mode/notraitor/bros/post_setup()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
		team.update_name()
	brother_teams += pre_brother_teams
	return ..()

/datum/game_mode/notraitor/bros/generate_report()
	return "It's Syndicate recruiting season. Be alert for potential Syndicate infiltrators, but also watch out for disgruntled employees trying to defect. Unlike Nanotrasen, the Syndicate prides itself in teamwork and will only recruit pairs that share a brotherly trust."

