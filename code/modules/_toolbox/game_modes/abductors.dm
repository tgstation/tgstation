#define ABDUCTORS_WIN 26

/datum/game_mode/anal_probers
	name = "abductors"
	config_tag = "abductors"
	antag_flag = ROLE_ABDUCTOR
	false_report_weight = 10
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 18
	required_enemies = 2
	recommended_enemies = 2
	minimum_enemies = 2

	announce_span = "green"
	announce_text = "Strange aliens are here to implant things in your bum!\n\
	<span class='green'>Abductors</span>: kidnap crew members and implant experiments in them.\n\
	<span class='notice'>Crew</span>: Destroy these alien abductors at all cost!"

	var/list/toucher_teams = list()

	var/max_teams = 4

	var/max_teams_at_player_count = 32 //always have max teams at this player count

	var/list/toucher_types = list(/datum/antagonist/abductor/agent, /datum/antagonist/abductor/scientist)

/datum/game_mode/anal_probers/pre_setup()

	//This part isn't used by this game mode but antag tokens do use this so it stays in.
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	if(antag_candidates.len < minimum_enemies)
		return 0

	var/list/bum_touchers = list()
	var/list/teams = list()

	var/playercount = GLOB.clients.len
	if(GLOB.override_lobby_player_count > 0)
		playercount = GLOB.override_lobby_player_count

	var/_max_teams = max(min(round(playercount/10),max_teams),1)

	if(playercount >= max_teams_at_player_count)
		_max_teams = max_teams

	var/team_number = 1
	while(team_number <= _max_teams && antag_candidates.len)
		if(!teams["team_[team_number]"])
			teams["team_[team_number]"] = list()
		var/datum/mind/bum_toucher = pick(antag_candidates)
		antag_candidates.Remove(bum_toucher)
		var/list/the_team = teams["team_[team_number]"]
		if(the_team.len < 2)
			the_team += bum_toucher
			bum_touchers[bum_toucher] = "[team_number]"
		if(the_team.len >= 2)
			teams["team_[team_number]"] = the_team
			team_number++

	//Cleaning up teams so all teams have exactly 2 people, teams with less are deleted.
	var/one_full_team = 0
	for(var/t in teams)
		var/list/the_team = teams[t]
		if(the_team.len < 2)
			teams.Remove(t)
			continue

		//making sure theres at least one full team.
		else if(!one_full_team)
			one_full_team = 1

	if(!one_full_team)
		return 0

	toucher_teams = teams

	for(var/datum/mind/bum_toucher in bum_touchers)
		var/team = bum_touchers[bum_toucher]
		bum_toucher.assigned_role = ROLE_ABDUCTOR
		bum_toucher.special_role = ROLE_ABDUCTOR
		log_game("[bum_toucher.key] (ckey) has been selected as abductor in team [team]")

	return bum_touchers.len

/datum/game_mode/anal_probers/post_setup()

	for(var/team in toucher_teams)
		var/list/team_members = toucher_teams[team]
		if((!istype(team_members,/list)) || (team_members.len != 2))
			continue

		var/datum/team/abductor_team/T = new
		if((T.team_number > max_teams))
			break

		var/list/_toucher_types = toucher_types.Copy()

		for(var/i=1,i<=2,i++)
			var/datum/mind/mind = pick_n_take(team_members)
			if(mind.current && _toucher_types.len)
				var/path = pick_n_take(_toucher_types)
				mind.add_antag_datum(path, T)

	return ..()

/datum/game_mode/anal_probers/generate_report()
	return "Aliens are boarding the station to kidnap our crew and experiment on them and then returning them back to the station with modifications, these victims have been acting strange when they return. We need to catch and destroy these aliens while they are on board."