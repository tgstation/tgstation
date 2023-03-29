#define DEFAULT_RESPAWN 15 SECONDS //Todo move to _defines

/datum/ctf_controller
	var/game_id = CTF_GHOST_CTF_GAME_ID
	var/list/datum/ctf_team/teams = list()
	var/points_to_win = 3
	var/ctf_enabled = FALSE
	var/respawn_cooldown = DEFAULT_RESPAWN
	var/victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. Click on the machines to vote to begin another round.</span>"

/datum/ctf_controller/New()
	. = ..()
	GLOB.ctf_games[game_id] = src

/datum/ctf_controller/Destroy(force, ...)
	GLOB.ctf_games[game_id] = null
	return ..()

/datum/ctf_controller/proc/start_ctf()
	ctf_enabled = TRUE
	for(var/team in teams)
		var/obj/machinery/ctf/spawner/spawner = teams[team].spawner
		notify_ghosts("[spawner.name] has been activated!", source = spawner, action = NOTIFY_ORBIT, header = "CTF has been activated") //Why is this silent?
		//spawner.start_ctf() todo port the functinality from old start_ctf() (Barriers)
	
/datum/ctf_controller/proc/stop_ctf()
	ctf_enabled = FALSE
	for(var/datum/ctf_team/team in teams)
		team.reset_team()

/datum/ctf_controller/proc/add_team(obj/machinery/ctf/spawner/spawner)
	if(!isnull(teams[spawner.team]))
		return //Todo multi-spawnpoints
	teams[spawner.team] = new /datum/ctf_team(spawner)

//Todo: Remove team()

/datum/ctf_controller/proc/add_player(team_color, ckey, datum/component/ctf_player/new_team_member)
	teams[team_color].team_members[ckey] = new_team_member

/datum/ctf_controller/proc/get_player_component(team_color, key)
	return teams[team_color].team_members[key]

/datum/ctf_controller/proc/get_players(team_color)
	return teams[team_color].team_members

/datum/ctf_controller/proc/get_all_players()
	var/list/players = list()
	for(var/team in teams)
		players += get_players(team)
	return players

/datum/ctf_controller/proc/team_valid_to_join(team_color, mob/user)
	var/list/friendly_team_members = get_players(team_color)
	for(var/team in teams)
		if(team == team_color)
			continue
		var/list/enemy_team_members = get_players(team)
		if(user.ckey in enemy_team_members)
			to_chat(user, span_warning("No switching teams while the round is going!"))
			return FALSE
		if(friendly_team_members.len > enemy_team_members.len)
			to_chat(user, span_warning("[team_color] has more team members than [team]! Try joining [team] team to even things up."))
			return FALSE
	return TRUE

//Probably need to split up capture flag into capture flag and score point so it can be used for control points

/datum/ctf_controller/proc/capture_flag(team_color, mob/living/user, team_span, flag)
	teams[team_color].points++
	message_all_teams("<span class='userdanger [team_span]'>[user.real_name] has captured \the [flag], scoring a point for [team_color] team! They now have [get_points(team_color)]/[points_to_win] points!</span>")
	if(get_points(team_color) >= points_to_win)
		victory(team_color)

/datum/ctf_controller/proc/get_points(team_color)
	return teams[team_color].points

/datum/ctf_controller/proc/victory(winning_team)
	ctf_enabled = FALSE //Medi-sim never disables itself, todo, support this
	var/datum/ctf_team/winning_ctf_team = teams[winning_team]
	for(var/team in teams)
		var/datum/ctf_team/ctf_team = teams[team]
		ctf_team.message_team("<span class='narsie [winning_ctf_team.team_span]'>[winning_team] team wins!</span>")
		ctf_team.message_team(victory_rejoin_text)
		ctf_team.reset_team()
	//Control point reset code

/datum/ctf_controller/proc/message_all_teams(message)
	for(var/team in teams)
		teams[team].message_team(message)

/datum/ctf_team
	var/obj/machinery/ctf/spawner/spawner
	var/team_color
	var/points = 0
	var/list/team_members = list()
	var/team_span = ""

/datum/ctf_team/New(obj/machinery/capture_the_flag/spawner)
	. = ..()
	src.spawner = spawner
	team_color = spawner.team
	team_span = spawner.team_span

/datum/ctf_team/proc/reset_team()
	points = 0
	for(var/player in team_members)
		var/datum/component/ctf_player/ctf_player = team_members[player]
		ctf_player.end_game()
	team_members = list()

//victory proc, probably needed, confirm if it is...

/datum/ctf_team/proc/message_team(message)
	for(var/player in team_members)
		var/datum/component/ctf_player/ctf_player = team_members[player]
		ctf_player.send_message(message)

/proc/create_ctf_game(game_id)
	if(GLOB.ctf_games[game_id])
		QDEL_NULL(GLOB.ctf_games[game_id]) //This'll break the medi-sim shuttle I'll bet you //Todo: check if it does
	var/datum/ctf_controller/CTF = new()
	return CTF
