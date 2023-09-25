/datum/computer_file/program/mafia
	filename = "mafia"
	filedesc = "Mafia"
	program_icon_state = "arcade" // TEMPORARY HAVE TO CHANGE
	extended_desc = "A program that allows you to play the infamous Mafia game, straight from your Modular PC."
	requires_ntnet = FALSE
	size = 6
	tgui_id = "NtosMafiaPanel"
	program_icon = "gamepad" // TEMPORARY HAVE TO CHANGE

/datum/computer_file/program/mafia/ui_static_data(mob/user)
	var/list/data = list()
	var/datum/mafia_controller/game = GLOB.mafia_game
	if(!game)
		game = create_mafia_game()
	data += game.ui_static_data(computer)
	return data

/datum/computer_file/program/mafia/ui_data(mob/user)
	var/list/data = list()
	var/datum/mafia_controller/game = GLOB.mafia_game
	if(!game)
		game = create_mafia_game()
	data += game.ui_data(computer)
	return data

/datum/computer_file/program/mafia/ui_assets(mob/user)
	var/list/data = list()
	var/datum/mafia_controller/game = GLOB.mafia_game
	if(!game)
		game = create_mafia_game()
	data += game.ui_assets(user)
	return data

/datum/computer_file/program/mafia/ui_act(mob/user, params, datum/tgui/ui, datum/ui_state/state)
	var/datum/mafia_controller/game = GLOB.mafia_game
	if(!game)
		game = create_mafia_game()
	return game.ui_act(user, params, ui, state)
