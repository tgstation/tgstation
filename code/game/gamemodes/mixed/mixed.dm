
var/global/list/mixed_allowed = list(
	"autotraitor",
	"changeling",
	"cult",
	"vampire",
	"wizard",
	)

/datum/game_mode/mixed
	name = "mixed"
	config_tag = "mixed"
	var/list/datum/game_mode/modes // 3 game modes in 1
	var/list/datum/mind/picked_antags
	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	required_players = 20
	required_players_secret = 25

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/mixed/announce()
	to_chat(world, "<B>The current game mode is - Mixed!</B>")
	to_chat(world, "<B>Anything can happen!</B>")

/datum/game_mode/mixed/pre_setup()
	. = 1
	modes = list()
	picked_antags = list()

	if(mixed_modes.len)
		for(var/M in mixed_modes)
			var/datum/game_mode/GM = config.pick_mode(M)
			GM.mixed = 1
			if(GM.pre_setup())
				modes += GM
			else
				qdel(GM)
	else
		var/list/datum/game_mode/possible = typesof(/datum/game_mode) - list(
																			/datum/game_mode,
																			/datum/game_mode/mixed,
																			/datum/game_mode/malfunction,
																			/datum/game_mode/traitor,
																			/datum/game_mode/traitor/double_agents,
																			/datum/game_mode/sandbox,
																			/datum/game_mode/revolution,
																			/datum/game_mode/meteor,
																			/datum/game_mode/extended,
																			/datum/game_mode/heist,
																			/datum/game_mode/nuclear,
																			/datum/game_mode/traitor/changeling,
																			/datum/game_mode/wizard/raginmages,
																			/datum/game_mode/blob,
																			)
		while(modes.len < 3)
			if(!possible.len) break
			var/ourmode = pick(possible)
			possible -= ourmode
			var/datum/game_mode/M = new ourmode
			M.mixed = 1
			if(!M.pre_setup())
				qdel(M)
				continue
			//modePlayer += M.modePlayer
			modes += M
	if(!modes.len)
		. = 0
	else
		var/keylist[]
		for(var/datum/mind/mind in modePlayer)
			keylist += mind
		log_admin("The gamemode setup for mixed started with [modes.len] mode\s [jointext(modes, " ")] with [jointext(keylist, " ")] as antag\s.")
		message_admins("The gamemode setup for mixed started with [modes.len] mode\s.")
		world.log << "The gamemode setup for mixed started with [modes.len] mode\s [jointext(modes, " ")] with [jointext(keylist, " ")] as antag\s."


/datum/game_mode/mixed/post_setup()
	for(var/datum/game_mode/M in modes)
		spawn() M.post_setup()
	spawn (rand(waittime_l, waittime_h))
		if(!mixed) send_intercept()

/datum/game_mode/mixed/check_finished()
	for(var/datum/game_mode/M in modes)
		if(M.check_finished())
			return 1
/datum/game_mode/mixed/declare_completion()
	for(var/datum/game_mode/M in modes)
		M.declare_completion()

/datum/game_mode/mixed/add_cultist(datum/mind/cult_mind)
	var/datum/game_mode/cult/cult_round = find_active_mode("cult")
	if(cult_round)
		cult_round.add_cultist(..())
	else
		..()

/datum/game_mode/mixed/remove_cultist(var/datum/mind/cult_mind, var/show_message = 1, var/log=1)
	var/datum/game_mode/cult/cult_round = find_active_mode("cult")
	if(cult_round)
		cult_round.remove_cultist(..())
	else
		..()
