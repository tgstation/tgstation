/datum/game_mode/mixed
	name = "mixed"
	config_tag = "mixed"
	var/list/datum/game_mode/modes[3] // 3 game modes in 1

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
	world << "<B>The current game mode is - Mixed!</B>"
	world << "<B>Anything can happen!</B>"

/datum/game_mode/mixed/pre_setup()
	var/list/datum/game_mode/possible = typesof(/datum/game_mode) - list(/datum/game_mode, /datum/game_mode/mixed, /datum/game_mode/borer, /datum/game_mode/malfunction, /datum/game_mode/traitor, /datum/game_mode/traitor/double_agents, /datum/game_mode/sandbox, /datum/game_mode/revolution, /datum/game_mode/meteor, /datum/game_mode/extended, /datum/game_mode/heist, /datum/game_mode/nuclear, /datum/game_mode/traitor/changeling, /datum/game_mode/wizard/raginmages, /datum/game_mode/blob)
	possible = shuffle(possible)
	for(var/i = 0, i < 2, i++)
		var/datum/game_mode/M = pick(possible)
		modes[i] = M
		possible = shuffle(possible)
	for(var/datum/game_mode/M in modes)
		M.pre_setup()

/datum/game_mode/mixed/post_setup()
	for(var/datum/game_mode/M in modes)
		M.post_setup()
	spawn (rand(waittime_l, waittime_h))
		send_intercept()