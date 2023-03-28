#define DEFAULT_RESPAWN 15 SECONDS //Todo move to _defines

/datum/ctf_controller
	var/game_id = CTF_GHOST_CTF_GAME_ID
	var/list/datum/ctf_team/teams = list()
	var/points_to_win = 3
	var/ctf_enabled = FALSE
	var/respawn_cooldown = DEFAULT_RESPAWN

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
		notify_ghosts("[spawner.name] has been activated!", source = spawner, action = NOTIFY_ORBIT, header = "CTF has been activated")
		//spawner.start_ctf() todo port the functinality from old start_ctf()
	
/datum/ctf_controller/proc/add_team(obj/machinery/ctf/spawner/spawner)
	if(!isnull(teams[spawner.team]))
		return
	teams[spawner.team] = new /datum/ctf_team(spawner)

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

/datum/ctf_team
	var/obj/machinery/ctf/spawner/spawner
	var/team_color
	var/points = 0
	var/list/team_members = list()
	var/team_span = ""

/datum/ctf_team/New(obj/machinery/capture_the_flag/spawner)
	src.spawner = spawner
	team_color = spawner.team
	team_span = spawner.team_span

/proc/create_ctf_game(game_id)
	if(GLOB.ctf_games[game_id])
		QDEL_NULL(GLOB.ctf_games[game_id])
	var/datum/ctf_controller/CTF = new()
	return CTF
