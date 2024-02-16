/datum/computer_file/program/mafia
	filename = "mafia"
	filedesc = "Mafia"
	program_open_overlay = "mafia"
	extended_desc = "A program that allows you to play the infamous Mafia game, straight from your Modular PC."
	downloader_category = PROGRAM_CATEGORY_GAMES
	size = 6
	tgui_id = "NtosMafiaPanel"
	program_icon = "user-secret"
	alert_able = TRUE

/datum/computer_file/program/mafia/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_MAFIA_GAME_START, PROC_REF(on_game_start))

/datum/computer_file/program/mafia/Destroy(force)
	var/datum/mafia_controller/game = GLOB.mafia_game
	if(!game)
		return ..()
	UnregisterSignal(game, COMSIG_MAFIA_GAME_END)
	var/datum/mafia_role/pda_role = game.get_role_player(computer)
	if(!pda_role)
		return ..()
	game.send_message(span_notice("[pda_role.body] has deleted the game from their PDA, and therefore has left the game."))
	pda_role.kill(game)
	return ..()

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
	. = ..()
	var/datum/mafia_controller/game = GLOB.mafia_game
	if(!game)
		game = create_mafia_game()
	return game.ui_act(user, params, ui, state)

///Called when a game of Mafia starts, sets the ui header to the proper one.
/datum/computer_file/program/mafia/proc/on_game_start(datum/controller/subsystem/processing/dcs/source, datum/mafia_controller/game)
	SIGNAL_HANDLER
	RegisterSignal(game, COMSIG_MAFIA_GAME_END, PROC_REF(on_game_end))
	ui_header = "mafia.gif"
	if(game.get_role_player(computer))
		alert_pending = TRUE
		computer.alert_call(src, "Mafia game started!")

///Called when a game of Mafia ends, deletes its ui header.
/datum/computer_file/program/mafia/proc/on_game_end(datum/mafia_controller/game)
	SIGNAL_HANDLER
	UnregisterSignal(game, COMSIG_MAFIA_GAME_END)
	ui_header = null
	update_static_data_for_all_viewers()
