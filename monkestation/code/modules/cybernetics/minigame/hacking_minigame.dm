/**
 *
 * Piping minigame, controls the board and procs surrounding it
 *
 * Holds all relevant information regarding the piping minigame
 * Contains the procs needed to generate the game, check if the game is finished and rotate any pieces.
 *
 */
/datum/hacking_minigame

	var/finished = FALSE

	var/board_size = 8

	var/list/datum/hacking_minigame_piece/board

/datum/hacking_minigame/New(board_size)
	. = ..()
	src.board_size = board_size

/**
 * checks if the game is finished
 *
 * Checks if the game was finished, and sets the finished to TRUE if it is
 * returns finished.
 */
/datum/hacking_minigame/proc/game_check()
	if(check_connections())
		finished = TRUE
	return finished

/**
 * Simple algorithm for generating a labyrinth
 *
 * This algorithm 'carves out' a single path and the destination is placed when there aren't anymore possible moves.
 * Rest of the board is filled randomly. This procedure makes sure that there is at least 1 possible path to take, and possibly more due to randomness.
 */
/datum/hacking_minigame/proc/generate()
	board = list()
	for(var/i in 1 to board_size)
		board += list(list())
		for(var/k in 1 to board_size)
			board[i] += 0

	for(var/i in 1 to board_size)
		for(var/k in 1 to board_size)
			board[i][k] = new /datum/hacking_minigame_piece(src)

	var/list/possible_moves = consider_possible_moves(1,1)
	var/current_x = 1
	var/current_y = 1
	board[current_x][current_y].start = TRUE
	board[current_x][current_y].visited = TRUE
	while(possible_moves.len)
		board[current_x][current_y].visited = TRUE

		var/move = pick(possible_moves)

		board[current_x][current_y].pass_out = move


		switch(move)
			if(NORTH)
				current_y--
			if(SOUTH)
				current_y++
			if(EAST)
				current_x++
			if(WEST)
				current_x--

		board[current_x][current_y].pass_in = REVERSE_DIR(move)

		possible_moves = consider_possible_moves(current_x,current_y)
		if(!possible_moves.len)
			board[current_x][current_y].finish = TRUE

	for(var/i in 1 to board_size)
		for(var/k in 1 to board_size)
			if(board[i][k].visited)
				board[i][k].rotate(rand(-3,3))
				continue
			var/list/dir_list = GLOB.cardinals.Copy()
			var/pick = pick(dir_list)
			board[i][k].pass_in = pick
			dir_list -= pick
			board[i][k].pass_out = pick(dir_list)
			board[i][k].visited = TRUE

	if(check_connections())
		generate()


/**
 * Simplification algorithm for the purpose of display
 *
 * Simplifies a 2d array of datums into a 2d array composed out of letters.
 */
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
				var/add = board[i][k].connected == TRUE ? "_f" : ""
				secondary_board[i][k] = "[board[i][k].get_dir_val()][add]"
	return secondary_board

///Algorithm that returns possible directions from a given coordinate
/datum/hacking_minigame/proc/consider_possible_moves(xcord as num,ycord as num)
	if(xcord < 1 || xcord > board_size)
		return list()
	if(ycord < 1 || ycord > board_size)
		return list()
	var/list/possible_dirs = list()
	if(xcord > 1)
		if(!board[xcord - 1][ycord].visited)
			possible_dirs += WEST

	if(ycord > 1)
		if(!board[xcord ][ycord - 1].visited)
			possible_dirs += NORTH

	if(xcord < board_size)
		if(!board[xcord + 1][ycord ].visited)
			possible_dirs += EAST

	if(ycord != board_size)
		if(!board[xcord ][ycord + 1].visited)
			possible_dirs += SOUTH

	return possible_dirs

///Checks connections coming from the source, returns TRUE if the source has a path to the destination
/datum/hacking_minigame/proc/check_connections()

	for(var/i in 1 to board_size)
		for(var/k in 1 to board_size)
			board[i][k].visited = FALSE
			board[i][k].connected = FALSE

	var/xcord
	var/ycord

	var/list/dirlist

	var/list/queued_coord_list = list(list(1,1))

	var/counter = 0

	var/list/possible_directions = list()

	while(queued_coord_list.len > counter)

		if(counter > board_size*board_size)
			stack_trace("Counter runoff stopped occured!")
			break

		possible_directions = list()

		counter++

		xcord = queued_coord_list[counter][1]
		ycord = queued_coord_list[counter][2]

		var/list/maybe_dir = board[xcord][ycord].get_dir_val_list()

		if(xcord > 1 && ((WEST in maybe_dir) || board[xcord][ycord].start || board[xcord][ycord].finish))
			possible_directions += WEST

		if(xcord < board_size && ((EAST in maybe_dir) || board[xcord][ycord].start || board[xcord][ycord].finish))
			possible_directions += EAST

		if(ycord > 1 && ((NORTH in maybe_dir) || board[xcord][ycord].start || board[xcord][ycord].finish))
			possible_directions += NORTH

		if(ycord < board_size && ((SOUTH in maybe_dir) || board[xcord][ycord].start || board[xcord][ycord].finish))
			possible_directions += SOUTH

		board[xcord][ycord].connected = FALSE

		if(NORTH in possible_directions)

			dirlist = board[xcord][ycord-1].get_dir_val_list()

			if(board[xcord][ycord-1].finish)
				board[xcord][ycord].connected = TRUE
				return TRUE

			if(SOUTH in dirlist)
				if(!board[xcord][ycord-1].visited)
					queued_coord_list += list(list(xcord,ycord-1))
				board[xcord][ycord].connected = TRUE

		if(SOUTH in possible_directions)

			dirlist = board[xcord][ycord+1].get_dir_val_list()

			if(board[xcord][ycord+1].finish)
				board[xcord][ycord].connected = TRUE
				return TRUE

			if(NORTH in dirlist)
				if(!board[xcord][ycord+1].visited)
					queued_coord_list += list(list(xcord,ycord+1))
				board[xcord][ycord].connected = TRUE

		if(WEST in possible_directions)

			dirlist = board[xcord-1][ycord].get_dir_val_list()

			if(board[xcord-1][ycord].finish)
				board[xcord][ycord].connected = TRUE
				return TRUE

			if(EAST in dirlist)
				if(!board[xcord-1][ycord].visited)
					queued_coord_list += list(list(xcord-1,ycord))
				board[xcord][ycord].connected = TRUE

		if(EAST in possible_directions)

			dirlist = board[xcord+1][ycord].get_dir_val_list()

			if(board[xcord+1][ycord].finish)
				board[xcord][ycord].connected = TRUE
				return TRUE

			if(WEST in dirlist)
				if(!board[xcord+1][ycord].visited)
					queued_coord_list += list(list(xcord+1,ycord))
				board[xcord][ycord].connected = TRUE

		board[xcord][ycord].visited = TRUE

	return FALSE
/**
 * Simple holder of information and some procs relating to this information
 *
 * Holds relevant information about a single cell of the board.
 */
/datum/hacking_minigame_piece
	var/pass_in = NONE
	var/pass_out = NONE
	var/visited = FALSE
	var/start = FALSE
	var/finish = FALSE
	var/connected = FALSE

	var/datum/hacking_minigame/game

/datum/hacking_minigame_piece/New(datum/hacking_minigame/_game)
	. = ..()
	game = _game

///Returns value of pass_in + pass_out
/datum/hacking_minigame_piece/proc/get_dir_val()
	if(pass_in != NONE && pass_out != NONE)
		return pass_in + pass_out
	return 0

///Returns a list of possible directions this cell can connect to
/datum/hacking_minigame_piece/proc/get_dir_val_list()
	//If this is a finish or start node than it is available from all directions, otherwise return the list containing both directions.
	return finish == TRUE || start == TRUE ? GLOB.cardinals.Copy() : list(pass_in , pass_out)

///Rotates the cell num amount of times
/datum/hacking_minigame_piece/proc/rotate(num = 1)
	//if you want to do this bitshifting way, then be my guest. BYOND direction system makes my head ache and is illogical even by lowest of standards.
	num = clamp(num,-3,3)
	pass_in = turn(pass_in,90*num)
	pass_out = turn(pass_out,90*num)
