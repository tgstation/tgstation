#define CTF_DEFAULT_RESPAWN 15 SECONDS
#define CTF_INSTAGIB_RESPAWN 5 SECONDS

///The CTF controller acts as a manager for an individual CTF game, each CTF game should have its own, the controller should handle all game-wide functionality.
/datum/ctf_controller
	///The ID associated with this CTF game.
	var/game_id = CTF_GHOST_CTF_GAME_ID
	///Whether or not this CTF game is running.
	var/ctf_enabled = FALSE
	///List of all team_datums participating in this game.
	var/list/datum/ctf_team/teams = list()
	///List of all control points used by the game, if they exist.
	var/list/obj/machinery/ctf/control_point/control_points = list()
	///List of all barricades that have been destroyed during this CTF game.
	var/list/obj/effect/ctf/dead_barricade/barricades = list()
	///How long till players who die can respawn.
	var/respawn_cooldown = CTF_DEFAULT_RESPAWN
	///How many points a team needs to win.
	var/points_to_win = 3
	///The text shown once this CTF match ends.
	var/victory_rejoin_text = "Teams have been cleared. Click on the machines to vote to begin another round."
	///When this CTF match ends should it automatically restart.
	var/auto_restart = FALSE
	///Weather or not instagib mode has been enabled.
	var/instagib_mode = FALSE

/datum/ctf_controller/New(game_id)
	. = ..()
	src.game_id = game_id
	GLOB.ctf_games[game_id] = src

/datum/ctf_controller/Destroy(force)
	GLOB.ctf_games[game_id] = null
	return ..()

/datum/ctf_controller/proc/toggle_ctf()
	if(!ctf_enabled)
		start_ctf()
		return TRUE
	else
		stop_ctf()
		return FALSE

/datum/ctf_controller/proc/start_ctf()
	if(ctf_enabled)
		return //CTF is already running, don't notify ghosts again
	ctf_enabled = TRUE
	for(var/team in teams)
		var/obj/machinery/ctf/spawner/spawner = teams[team].spawner
		notify_ghosts(
			"[spawner.name] has been activated!",
			source = spawner,
			header = "CTF has been activated",
		)

/datum/ctf_controller/proc/stop_ctf()
	ctf_enabled = FALSE
	clear_control_points()
	respawn_barricades()
	for(var/team in teams)
		teams[team].reset_team()

///Unloading CTF removes the map entirely and allows for a new map to be loaded in its place.
/datum/ctf_controller/proc/unload_ctf()
	if(game_id != CTF_GHOST_CTF_GAME_ID)
		return //At present we only support unloading standard centcom ctf, if we intend to support ctf unloading elsewhere then this proc will need to be amended.
	stop_ctf()
	new /obj/effect/landmark/ctf(get_turf(GLOB.ctf_spawner))

///Some CTF maps may require alternate rulesets, this proc is called by the medisim spawners and CTF maploading.
/datum/ctf_controller/proc/setup_rules(
	points_to_win = 3,
	victory_rejoin_text = "Teams have been cleared. Click on the machines to vote to begin another round.",
	auto_restart = FALSE,
)
	src.points_to_win = points_to_win
	src.victory_rejoin_text = victory_rejoin_text
	src.auto_restart = auto_restart

///Add an additional team to the current CTF game.
/datum/ctf_controller/proc/add_team(obj/machinery/ctf/spawner/spawner)
	if(!isnull(teams[spawner.team]))
		return //CTF currently only supports one spawn point per team, if you want to add a map that uses more you'll need to modify add_team/remove_team and turn the spawner var on the team itself into a list
	teams[spawner.team] = new /datum/ctf_team(spawner)

///Called when a spawner is deleted, removes the team from this datum.
/datum/ctf_controller/proc/remove_team(team_color)
	if(isnull(teams[team_color]))
		return //Cannot delete a team that doesn't exist
	QDEL_NULL(teams[team_color])
	teams -= team_color

///Adds a player and a reference to their player component to the corresponding team.
/datum/ctf_controller/proc/add_player(team_color, ckey, datum/component/ctf_player/new_team_member)
	teams[team_color].team_members[ckey] = new_team_member

///Returns a reference to a players component (if it exists) when provided with a player's ckey
/datum/ctf_controller/proc/get_player_component(team_color, ckey)
	return teams[team_color].team_members[ckey]

///Returns a list of all players in the provided team.
/datum/ctf_controller/proc/get_players(team_color)
	return teams[team_color].team_members

///Returns a list of all players in all teams.
/datum/ctf_controller/proc/get_all_players()
	var/list/players = list()
	for(var/team in teams)
		players += get_players(team)
	return players

///Identifies if the provided team is a valid team to join for the provided player.
/datum/ctf_controller/proc/team_valid_to_join(team_color, mob/user)
	var/list/friendly_team_members = get_players(team_color)
	for(var/team in teams)
		if(team == team_color)
			continue
		var/list/enemy_team_members = get_players(team)
		if(user.ckey in enemy_team_members)
			to_chat(user, span_warning("No switching teams while the round is going!"))
			return FALSE
		else if(friendly_team_members.len > enemy_team_members.len)
			to_chat(user, span_warning("[team_color] has more team members than [team]! Try joining [team] team to even things up."))
			return FALSE
	return TRUE

///Called when a flag is captured by the provided team. Messages players telling them who scored a point and if points are high enough declares victory.
/datum/ctf_controller/proc/capture_flag(team_color, mob/living/user, team_span, obj/item/ctf_flag/flag)
	teams[team_color].score_points(flag.flag_value)
	message_all_teams("<span class='userdanger [team_span]'>[user.real_name] has captured \the [flag], scoring a point for [team_color] team! They now have [get_points(team_color)]/[points_to_win] points!</span>")
	if(get_points(team_color) >= points_to_win)
		victory(team_color)

///Called when points are scored at a control point. Messages players telling them when a team is half way to winning and if points are high enough declares victory.
/datum/ctf_controller/proc/control_point_scoring(team_color, points)
	teams[team_color].score_points(points)
	if(get_points(team_color) == points_to_win/2)
		message_all_teams("<span class='userdanger [teams[team_color].team_span]'>[team_color] is half way to winning! they only need [points_to_win/2] more points to win!</span>")
	if(get_points(team_color) >= points_to_win)
		victory(team_color)

///Returns the current amount of points the provided team has.
/datum/ctf_controller/proc/get_points(team_color)
	return teams[team_color].points

///Ends the current CTF game and informs all players which team won. Restarts CTF if auto_restart is enabled.
/datum/ctf_controller/proc/victory(winning_team)
	ctf_enabled = FALSE
	clear_control_points()
	respawn_barricades()
	var/datum/ctf_team/winning_ctf_team = teams[winning_team]
	for(var/team in teams)
		var/datum/ctf_team/ctf_team = teams[team]
		ctf_team.message_team("<span class='narsie [winning_ctf_team.team_span]'>[winning_team] team wins!</span>")
		ctf_team.message_team(span_userdanger(victory_rejoin_text))
		ctf_team.reset_team()
	if(auto_restart)
		toggle_id_ctf(null, game_id, TRUE)

///Marks all control points as neutral, called when a CTF match ends.
/datum/ctf_controller/proc/clear_control_points()
	for(var/obj/machinery/ctf/control_point/control_point in control_points)
		control_point.clear_point()

///Respawns all barricades destroyed during the current CTF game, called when the match ends.
/datum/ctf_controller/proc/respawn_barricades()
	for(var/obj/effect/ctf/dead_barricade/barricade in barricades)
		barricade.respawn()
	barricades = list()

///Sends a message to all players in all CTF teams in this game.
/datum/ctf_controller/proc/message_all_teams(message)
	for(var/team in teams)
		teams[team].message_team(message)

///Enables and disables instagib mode in this game. During instagib mode respawns are faster, players are faster and people die faster (instant).
/datum/ctf_controller/proc/toggle_instagib_mode()
	if(!instagib_mode) // Normal > Instagib
		for(var/team in teams)
			var/datum/ctf_team/ctf_team = teams[team]
			ctf_team.spawner.ctf_gear = ctf_team.spawner.instagib_gear
			respawn_cooldown = CTF_INSTAGIB_RESPAWN
	else //Instagib > Normal
		for(var/team in teams)
			var/datum/ctf_team/ctf_team = teams[team]
			ctf_team.spawner.ctf_gear = ctf_team.spawner.default_gear
			respawn_cooldown = CTF_DEFAULT_RESPAWN
	instagib_mode = !instagib_mode

///A datum that holds details about individual CTF teams, any team specific CTF functionality should be implemented here.
/datum/ctf_team
	///Reference to the spawn point that this team uses.
	var/obj/machinery/ctf/spawner/spawner
	///What color this team is, also acts as a team name.
	var/team_color
	///Total score that this team currently has.
	var/points = 0
	///Assoc list containing a list of team members ckeys and the associated ctf_player components.
	var/list/team_members = list()
	///Span used for messages sent to this team.
	var/team_span = ""

/datum/ctf_team/New(obj/machinery/ctf/spawner/spawner)
	. = ..()
	src.spawner = spawner
	team_color = spawner.team
	team_span = spawner.team_span

///If the team is destroyed all players in that team need their component removed.
/datum/ctf_team/Destroy(force)
	for(var/player in team_members)
		var/datum/component/ctf_player/ctf_player = team_members[player]
		ctf_player.end_game()
	return ..()

///Increases this teams number of points by the provided amount.
/datum/ctf_team/proc/score_points(points_scored)
	points += points_scored

///Resets this teams score and clears its member list. All members will be dusted and have their player component removed.
/datum/ctf_team/proc/reset_team()
	points = 0
	for(var/player in team_members)
		var/datum/component/ctf_player/ctf_player = team_members[player]
		ctf_player.end_game()
	team_members = list()

///Sends a message to all players in this team.
/datum/ctf_team/proc/message_team(message)
	for(var/player in team_members)
		var/datum/component/ctf_player/ctf_player = team_members[player]
		ctf_player.send_message(message)

///Creates a CTF game with the provided team ID then returns a reference to the new controller. If a controller already exists provides a reference to it.
/proc/create_ctf_game(game_id)
	if(GLOB.ctf_games[game_id])
		return GLOB.ctf_games[game_id]
	var/datum/ctf_controller/CTF = new(game_id)
	return CTF

#undef CTF_DEFAULT_RESPAWN
#undef CTF_INSTAGIB_RESPAWN
