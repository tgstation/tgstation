#define DEFAULT_FIELD_HEIGHT 16
#define DEFAULT_FIELD_WIDTH 16
#define DEFAULT_BOMBS_AMOUNT 40

#define STARTING_AREA_SIZE 9
#define MIN_FIELD_SIDE_SIZE 9
#define MAX_FIELD_SIDE_SIZE 25
#define MIN_BOMBS_AMOUNT 10
#define MAX_BOMBS_AMOUNT 100
#define FIELD_AREA_TO_BOMBS_MIN_RATIO 5

#define CELL_PARAM_OPEN "open"
#define CELL_PARAM_BOMB "bomb"
#define CELL_PARAM_FLAG "flag"
#define CELL_PARAM_AROUND "around"
#define CELL_PARAM_MARKED "marked"
#define CELL_PARAM_FINAL "final"

/datum/computer_file/program/minesweeper
	filename = "minesweeper"
	filedesc = "Сапёр"
	// program_open_overlay = "minesweeper"
	extended_desc = "Погрузись в удивительный мир 'Сапёра', \
		где каждое неверное нажатие может привести к взрыву! \
		Сразись с друзьями и стань мастером разминирования в этой захватывающей игре!."
	downloader_category = PROGRAM_CATEGORY_GAMES
	size = 6
	tgui_id = "NtosMinesweeperPanel"
	program_icon = "bomb"

	/// Thing, to make first touch safety
	var/first_touch = TRUE

	/// Amount of set flags. Used to check win condition
	var/set_flags = 0
	/// Amount of flagged bombs. Used to check win condition
	var/flagged_bombs = 0
	/// Amount of opened cells. Used to check win condition
	var/opened_cells = 0

	/// Decision to make interface untouchable in the momemnt of regenerating
	var/ignore_touches = FALSE
	/// Current field amount of rows
	var/field_height = DEFAULT_FIELD_HEIGHT
	/// Current field amount of columns
	var/field_width = DEFAULT_FIELD_WIDTH
	/// Current field amount of bombs
	var/field_bombs_amount = DEFAULT_BOMBS_AMOUNT
	/// Current field 3BV (special system of score for minesweeper). Used to calculate 3BV/s (user efficiency)
	var/current_3BV = 0
	/// The world.time the game was started. Used to calculate 3BV/s (user efficiency)
	var/start_time = 0

	/// Emagged bomb stats
	var/loose_explosion_range_heavy = -1
	var/loose_explosion_range_medium = 1
	var/loose_explosion_range_light = 3
	var/loose_explosion_range_flame = 2

	/// Cells with bombs. Used in `reveal_all_bombs`
	var/list/bomb_cells = list()

	/// Here we have all the minesweeper info
	var/list/minesweeper_matrix = list()

	/// The global leaderboard list
	var/static/list/glob_leaderboard = null
	/// The current round leaderboard list
	var/static/list/leaderboard = list()
	/// Directions for adjacent cells
	var/static/list/directions = list(
		list(-1,  0), // Left
		list( 1,  0), // Right
		list( 0, -1), // Up
		list( 0,  1), // Down
		list(-1, -1), // Top-Left
		list( 1,  1), // Bottom-Right
		list(-1,  1), // Top-Right
		list( 1, -1)  // Bottom-Left
	)

/datum/computer_file/program/minesweeper/New()
	..()
	if(isnull(glob_leaderboard))
		init_leaderboard()

/datum/computer_file/program/minesweeper/ui_interact(mob/user, datum/tgui/ui)
	if(!length(minesweeper_matrix))
		make_empty_matrix()

/datum/computer_file/program/minesweeper/ui_data(mob/user)
	var/list/data = list()
	data["matrix"] = minesweeper_matrix
	data["flags"] = set_flags
	data["bombs"] = field_bombs_amount
	data["leaderboard"] = leaderboard
	data["glob_leaderboard"] = glob_leaderboard
	data["first_touch"] = first_touch
	data["field_params"] = list("width" = field_width, "height" = field_height, "bombs" = field_bombs_amount)
	return data

/datum/computer_file/program/minesweeper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	// After loose/win cooldown
	if(ignore_touches)
		return

	switch(action)
		// Click on game field
		if("Square")
			return handle_square_click(text2num(params["X"]) + 1, text2num(params["Y"]) + 1, params["mode"], ui.user)

		// Change field params
		if("ChangeSize")
			return change_field_params(ui.user)

/**
 * Handles a click on a square on the field.
 *
 * @param {number} x - Row of the square
 * @param {number} y - Column of the square
 * @param {string} mode - The mode of the click. Can be "bomb" or "flag"
 * @param {mob} user - Mob that made the click
 *
 * @return {boolean} - TRUE if the click was handled successfully, FALSE otherwise
 */
/datum/computer_file/program/minesweeper/proc/handle_square_click(x, y, mode, mob/user)
	PRIVATE_PROC(TRUE)

	if(x < 1)
		stack_trace("invalid x '[x]' passed.")
		return FALSE

	if(y < 1)
		stack_trace("invalid y '[y]' passed.")
		return FALSE

	switch(mode)
		if("bomb")
			if(first_touch)
				generate_field(x, y)

			if(minesweeper_matrix[x][y][CELL_PARAM_BOMB])
				on_loose(x, y)
				return TRUE

			update_zeros(x, y)

		if("flag")
			var/list/minesweeper_cell = minesweeper_matrix[x][y]
			if(first_touch || minesweeper_cell[CELL_PARAM_OPEN])
				return FALSE

			if(minesweeper_cell[CELL_PARAM_FLAG])
				minesweeper_cell[CELL_PARAM_FLAG] = FALSE
				set_flags -= 1
				if(minesweeper_cell[CELL_PARAM_BOMB])
					flagged_bombs -= 1
			else
				minesweeper_cell[CELL_PARAM_FLAG] = TRUE
				set_flags += 1
				if(minesweeper_cell[CELL_PARAM_BOMB])
					flagged_bombs += 1
		else
			stack_trace("Invalid mode '[mode]' passed.")
			return FALSE

	check_win(user)
	return TRUE


/// Requests user the new field params and updates the field
/datum/computer_file/program/minesweeper/proc/change_field_params(mob/user)
	PRIVATE_PROC(TRUE)

	if(computer.loc != user)
		return FALSE

	if(!first_touch)
		return FALSE

	var/ans = tgui_alert(user, "Вы хотите изменить параметры поля?", "Настройки Сапёра", list("Да", "Нет"))
	if(ans != "Да")
		return FALSE

	var/width = tgui_input_number(user, "Выставите ширину", "Настройки Сапёра", field_width, MAX_FIELD_SIDE_SIZE, MIN_FIELD_SIDE_SIZE)
	var/height = tgui_input_number(user, "Выставите длину", "Настройки Сапёра", field_height, MAX_FIELD_SIDE_SIZE, MIN_FIELD_SIDE_SIZE)

	var/field_area = width * height
	if(field_area - STARTING_AREA_SIZE < MIN_BOMBS_AMOUNT)
		stack_trace("Field area is too small [field_area].")
		to_chat(user, span_warning("Поле слишком маленькое!"))
		return FALSE

	var/max_bombs_amount = clamp(floor(field_area / FIELD_AREA_TO_BOMBS_MIN_RATIO), MIN_BOMBS_AMOUNT, MAX_BOMBS_AMOUNT)
	var/bombs = tgui_input_number(
		user,
		"Выставите кол-во бомб",
		"Настройки Сапёра",
		min(field_bombs_amount, max_bombs_amount),
		max_bombs_amount,
		MIN_BOMBS_AMOUNT
	)

	field_height = height
	field_width = width
	field_bombs_amount = bombs
	make_empty_matrix()
	return TRUE

/datum/computer_file/program/minesweeper/proc/check_win(mob/user)
	PRIVATE_PROC(TRUE)

	if(
		flagged_bombs == field_bombs_amount && \
		set_flags == field_bombs_amount && \
		opened_cells == (field_height * field_width - field_bombs_amount)
	)

		on_win(user)

/datum/computer_file/program/minesweeper/proc/on_win(mob/user)
	PRIVATE_PROC(TRUE)

	ignore_touches = TRUE
	playsound(get_turf(computer), 'sound/machines/ping.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(make_empty_matrix)), 5 SECONDS)
	add_into_leaders(user, world.time - start_time)

/// Add player result to local, global leaderboards and DB
/datum/computer_file/program/minesweeper/proc/add_into_leaders(mob/user, game_time)
	PRIVATE_PROC(TRUE)

	var/game_time_in_seconds = game_time / (1 SECONDS)
	var/nickname = tgui_input_text(
		user,
		"Вы сравелись за [game_time_in_seconds] секунд!\n Напишите ваш никнейм чтобы сохранить результат в рейтинговой таблице.\n",
		"Сапёр",
		"",
		10
	)
	if(!nickname)
		return

	var/result_to_add = list(
		"name" = nickname,
		"time" = "[game_time_in_seconds]",
		"points" = "[current_3BV]",
		"pointsPerSec" = "[round(current_3BV / (game_time_in_seconds), 0.1)]",
		"fieldParams" = "[field_width]X[field_height]([field_bombs_amount])"
	)

	leaderboard += list(result_to_add)
	glob_leaderboard += list(result_to_add)
	add_result_to_db(result_to_add, user.ckey, field_width, field_height, field_bombs_amount)

///Insert new player result into database
/datum/computer_file/program/minesweeper/proc/add_result_to_db(list/new_result, ckey, width, height, bombs)
	PRIVATE_PROC(TRUE)

	if(SSdbcore.Connect())
		var/datum/db_query/query_minesweeper = SSdbcore.NewQuery(
			"INSERT INTO [format_table_name("minesweeper")] (ckey, time, points, points_per_sec, nickname, width, height, bombs) VALUES (:ckey, :time, :points, :points_per_sec, :nickname, :width, :height, :bombs)",
			list(
				"ckey" = ckey,
				"time" = new_result["time"],
				"points" = new_result["points"],
				"points_per_sec" = new_result["pointsPerSec"],
				"nickname" = new_result["name"],
				"width" = width,
				"height" = height,
				"bombs" = bombs
			)
		)
		query_minesweeper.Execute()
		qdel(query_minesweeper)

/// Called when player lost the game
/datum/computer_file/program/minesweeper/proc/on_loose(final_bomb_x, final_bomb_y)
	PRIVATE_PROC(TRUE)

	ignore_touches = TRUE
	minesweeper_matrix[final_bomb_x][final_bomb_y][CELL_PARAM_FINAL] = TRUE
	reveal_all_bombs()
	playsound(get_turf(computer), 'sound/effects/explosion/explosion1.ogg', 50, TRUE)
	if(computer.obj_flags & EMAGGED)
		explosion(
			computer,
			loose_explosion_range_heavy,
			loose_explosion_range_medium,
			loose_explosion_range_light,
			loose_explosion_range_flame
		)

	if(!QDELETED(src))
		addtimer(CALLBACK(src, PROC_REF(make_empty_matrix)), 3 SECONDS)

/// Makes all cells with bombs open. Used in `on_loose` proc
/datum/computer_file/program/minesweeper/proc/reveal_all_bombs()
	PRIVATE_PROC(TRUE)

	for(var/list/bomb_cell in bomb_cells)
		bomb_cell[CELL_PARAM_OPEN] = TRUE

/// Return the minesweeper matrix to initial state
/datum/computer_file/program/minesweeper/proc/make_empty_matrix()
	PRIVATE_PROC(TRUE)

	minesweeper_matrix = list()
	for(var/row_number in 1 to field_height)
		var/list/new_row = list()
		for(var/column_number in 1 to field_width)
			var/list/cell = list(
				CELL_PARAM_OPEN = FALSE,
				CELL_PARAM_BOMB = FALSE,
				CELL_PARAM_FLAG = FALSE,
				CELL_PARAM_AROUND = 0,
				CELL_PARAM_MARKED = FALSE
			)

			UNTYPED_LIST_ADD(new_row, cell)

		UNTYPED_LIST_ADD(minesweeper_matrix, new_row)

	first_touch = TRUE
	ignore_touches = FALSE
	SStgui.update_uis(computer)

/// Fill matrix with bombs, ignores 3x3 square around first touch place
/datum/computer_file/program/minesweeper/proc/generate_field(start_x, start_y)
	PRIVATE_PROC(TRUE)

	flagged_bombs = 0
	set_flags = 0
	opened_cells = 0
	bomb_cells.Cut()

	var/list/possible_bomb_cells = list()
	var/list/adjacent_cells_x = list(start_x - 1, start_x, start_x + 1)
	var/list/adjacent_cells_y = list(start_y - 1, start_y, start_y + 1)
	for(var/possible_bomb_cell_x in 1 to field_height)
		for(var/possible_bomb_cell_y in 1 to field_width)
			if((possible_bomb_cell_x in adjacent_cells_x) && (possible_bomb_cell_y in adjacent_cells_y))
				continue

			UNTYPED_LIST_ADD(possible_bomb_cells, list(possible_bomb_cell_x, possible_bomb_cell_y))

	for(var/bomb in 1 to field_bombs_amount)
		if(!length(possible_bomb_cells))
			break

		var/list/cell_coordinates = pick_n_take(possible_bomb_cells)
		var/cell_x = cell_coordinates[1]
		var/cell_y = cell_coordinates[2]

		var/list/cell = minesweeper_matrix[cell_x][cell_y]
		cell[CELL_PARAM_BOMB] = TRUE
		UNTYPED_LIST_ADD(bomb_cells, cell)

		for(var/list/direction in directions)
			var/adjacent_cell_x = cell_x + direction[1]
			var/adjacent_cell_y = cell_y + direction[2]
			if(!is_cell_in_bounds(adjacent_cell_x, adjacent_cell_y))
				continue

			minesweeper_matrix[adjacent_cell_x][adjacent_cell_y][CELL_PARAM_AROUND] += 1

	first_touch = FALSE
	count_3BV()
	start_time = world.time

/// Open all "zeroes" around the click place
/datum/computer_file/program/minesweeper/proc/update_zeros(x, y)
	PRIVATE_PROC(TRUE)

	var/list/list_for_update = list(list(x, y))
	var/list/visited = list()
	while(length(list_for_update))
		var/list/coordinates = pop(list_for_update)
		var/this_cell_x = coordinates[1]
		var/this_cell_y = coordinates[2]

		if(!open_cell(this_cell_x, this_cell_y))
			continue

		for(var/list/direction in directions)
			var/new_x = this_cell_x + direction[1]
			var/new_y = this_cell_y + direction[2]
			if(!is_cell_in_bounds(new_x, new_y) || visited["[new_x][new_y]"])
				continue

			visited["[new_x][new_y]"] = TRUE
			UNTYPED_LIST_ADD(list_for_update, list(new_x, new_y))

/**
 * Makes cell by passed coordinates open.
 * Increases `opened_cells` if cell was successfully opened and removes flag from it.
 *
 * @param {number] x - The row of the cell
 * @param {number] y - The column of the cell
 *
 * @return {boolean} - TRUE if cell should cause recursive opening, FALSE otherwise
 */
/datum/computer_file/program/minesweeper/proc/open_cell(x, y)
	PRIVATE_PROC(TRUE)

	var/list/minesweeper_cell = minesweeper_matrix[x][y]
	if(minesweeper_cell[CELL_PARAM_OPEN])
		return FALSE

	minesweeper_cell[CELL_PARAM_OPEN] = TRUE
	opened_cells += 1

	if(minesweeper_cell[CELL_PARAM_FLAG])
		minesweeper_cell[CELL_PARAM_FLAG] = FALSE
		set_flags -= 1
		if(minesweeper_cell[CELL_PARAM_BOMB])
			flagged_bombs -= 1

	if(minesweeper_cell[CELL_PARAM_AROUND] > 0)
		return FALSE

	return TRUE

/// Count value of field for scoring
/datum/computer_file/program/minesweeper/proc/count_3BV()
	PRIVATE_PROC(TRUE)

	current_3BV = 0
	for(var/x in 1 to field_height)
		for(var/y in 1 to field_width)
			var/list/minesweeper_cell = minesweeper_matrix[x][y]
			if(minesweeper_cell[CELL_PARAM_MARKED])
				continue

			minesweeper_cell[CELL_PARAM_MARKED] = TRUE
			if(minesweeper_cell[CELL_PARAM_BOMB])
				continue

			current_3BV++
			if(minesweeper_cell[CELL_PARAM_AROUND])
				continue

			mark_adjacent_zeros(x, y)

/// part of proc/count_3BV, used to ignore adjacent "zeroes"
/datum/computer_file/program/minesweeper/proc/mark_adjacent_zeros(start_x, start_y)
	PRIVATE_PROC(TRUE)

	var/list/check_list = list(list(start_x, start_y))
	while(length(check_list))
		var/list/coordinates = pop(check_list)
		var/this_cell_x = coordinates[1]
		var/this_cell_y = coordinates[2]
		minesweeper_matrix[this_cell_x][this_cell_y][CELL_PARAM_MARKED] = TRUE
		for(var/list/direction as anything in directions)
			var/adjacent_cell_x = this_cell_x + direction[1]
			var/adjacent_cell_y = this_cell_y + direction[2]
			if(!is_cell_in_bounds(adjacent_cell_x, adjacent_cell_y))
				continue

			var/list/adjacent_cell = minesweeper_matrix[adjacent_cell_x][adjacent_cell_y]
			if(adjacent_cell[CELL_PARAM_MARKED])
				continue

			if(adjacent_cell[CELL_PARAM_AROUND])
				continue

			UNTYPED_LIST_ADD(check_list, list(adjacent_cell_x, adjacent_cell_y))

/// Checks if cell by passed coordinates is in field bounds
/datum/computer_file/program/minesweeper/proc/is_cell_in_bounds(cell_x, cell_y)
	PRIVATE_PROC(TRUE)

	return cell_x >= 1 && cell_x <= field_height && cell_y >= 1 && cell_y <= field_width

///Get stored in database player results and fill glob_leaderboard with them
/datum/computer_file/program/minesweeper/proc/init_leaderboard()
	PRIVATE_PROC(TRUE)

	glob_leaderboard = list()
	var/datum/db_query/minesweeper_query = SSdbcore.NewQuery("SELECT nickname, points, points_per_sec, time, width, height, bombs FROM [format_table_name("minesweeper")]")
	if(!minesweeper_query.Execute())
		qdel(minesweeper_query)
		return

	while(minesweeper_query.NextRow())
		glob_leaderboard += list(
			list(
				"name" = minesweeper_query.item[1],
				"time" = "[minesweeper_query.item[4]]",
				"points" = "[minesweeper_query.item[2]]",
				"pointsPerSec" = "[minesweeper_query.item[3]]",
				"fieldParams" = "[minesweeper_query.item[5]]X[minesweeper_query.item[6]]([minesweeper_query.item[7]])"
			)
		)
	qdel(minesweeper_query)

#undef DEFAULT_FIELD_HEIGHT
#undef DEFAULT_FIELD_WIDTH
#undef DEFAULT_BOMBS_AMOUNT
#undef MIN_FIELD_SIDE_SIZE
#undef MAX_FIELD_SIDE_SIZE
#undef MIN_BOMBS_AMOUNT
#undef MAX_BOMBS_AMOUNT
#undef FIELD_AREA_TO_BOMBS_MIN_RATIO
#undef CELL_PARAM_OPEN
#undef CELL_PARAM_BOMB
#undef CELL_PARAM_FLAG
#undef CELL_PARAM_AROUND
#undef CELL_PARAM_MARKED

/* MINESWEEPER-PDA EMAG ACT */

/obj/item/modular_computer/pda/emag_act(mob/user, obj/item/card/emag/emag_card, forced)
	. = ..()
	if(.)
		INVOKE_ASYNC(src, PROC_REF(add_minesweeper))

/obj/item/modular_computer/pda/proc/add_minesweeper()
	store_file(new /datum/computer_file/program/minesweeper)
