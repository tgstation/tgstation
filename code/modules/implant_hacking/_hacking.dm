/obj/item/hacker_debug
	name = "debughacker"
	icon = 'icons/obj/blackmarket.dmi'
	icon_state = "uplink"
	var/datum/hacking_minigame/game

/obj/item/hacker_debug/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		game = new()
		game.generate()
		ui = new(user, src, "Hacking", name)
		ui.open()

/obj/item/hacker_debug/ui_data(mob/user)
	var/list/data = list()
	data["array"] = game.get_simplified_image()
	return data

/obj/item/hacker_debug/ui_assets(mob/user)
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/hacking)


/datum/hacking_minigame
	/// Amount od conflicting protocols, from 1 to 3
	var/difficulty = 1

	var/board_size = 5

	var/list/datum/hacking_minigame_piece/board

/datum/hacking_minigame/proc/generate()
	board = list()
	for(var/i in 1 to board_size)
		board += list(list())
		for(var/k in 1 to board_size)
			board[i] += 0

	for(var/i in 1 to board_size)
		for(var/k in 1 to board_size)
			board[i][k] = new /datum/hacking_minigame_piece()

	var/list/possible_moves = consider_possible_moves(1,1)
	var/current_x = 1
	var/current_y = 1
	board[current_x][current_y]?.start = TRUE
	board[current_x][current_y]?.visited = TRUE
	while(possible_moves.len)
		board[current_x][current_y]?.visited = TRUE
		var/move = pick(possible_moves)
		switch(move)
			if("north")
				board[current_x][current_y].pass_out |= NORTH
				current_y--
				board[current_x][current_y].pass_in |= SOUTH
			if("south")
				board[current_x][current_y].pass_out |= SOUTH
				current_y++
				board[current_x][current_y].pass_in |= NORTH
			if("east")
				board[current_x][current_y].pass_out |= EAST
				current_x++
				board[current_x][current_y].pass_in |= WEST
			if("west")
				board[current_x][current_y].pass_out |= WEST
				current_x--
				board[current_x][current_y].pass_in |= EAST
		possible_moves = consider_possible_moves(current_x,current_y)

/datum/hacking_minigame/proc/get_simplified_image()
	var/list/secondary_board = list()
	for(var/i in 1 to board_size)
		secondary_board += list(list())
		for(var/k in 1 to board_size)
			secondary_board[i] += 0

	for(var/i in 1 to board_size)
		for(var/k in 1 to board_size)
			if(board[i][k].finish)
				secondary_board[i][k] = "e"
			else if(board[i][k].start)
				secondary_board[i][k] = "s"
			else
				secondary_board[i][k] = board[i][k].get_dir_val()

	return secondary_board

/datum/hacking_minigame/proc/consider_possible_moves(xcord as num,ycord as num)
	if(xcord < 1 || xcord > board_size)
		return list()
	if(ycord < 1 || ycord > board_size)
		return list()
	var/list/possible_dirs = list()
	if(xcord > 1)
		if(!board[xcord - 1][ycord]?.visited)
			possible_dirs += "west"

	if(ycord > 1)
		if(!board[xcord ][ycord - 1]?.visited)
			possible_dirs += "north"

	if(xcord < board_size)
		if(!board[xcord + 1][ycord ]?.visited)
			possible_dirs += "east"

	if(ycord != board_size)
		if(!board[xcord ][ycord + 1]?.visited)
			possible_dirs += "south"

	return possible_dirs

/datum/hacking_minigame_piece
	var/rotation = 0
	var/pass_in = NONE
	var/pass_out = NONE
	var/visited = FALSE
	var/start = FALSE
	var/finish = FALSE

/datum/hacking_minigame_piece/proc/get_dir_val()
	if(pass_in != NONE && pass_out != NONE)
		return angle2dir(dir2angle(pass_in)+rotation*90) + angle2dir(dir2angle(pass_out)+rotation*90)
	return 0
