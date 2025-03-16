/datum/keybinding/movement
	category = CATEGORY_MOVEMENT
	weight = WEIGHT_HIGHEST

/datum/keybinding/movement/north
	hotkey_keys = list("W", "North")
	name = "North"
	full_name = "Двигаться на вверх"
	description = "Перемещает вашего персонажа на вверх"
	keybind_signal = COMSIG_KB_MOVEMENT_NORTH_DOWN

/datum/keybinding/movement/south
	hotkey_keys = list("S", "South")
	name = "South"
	full_name = "Двигаться на вниз"
	description = "Перемещает вашего персонажа на вниз"
	keybind_signal = COMSIG_KB_MOVEMENT_SOUTH_DOWN

/datum/keybinding/movement/west
	hotkey_keys = list("A", "West")
	name = "West"
	full_name = "Двигаться на лево"
	description = "Перемещает вашего персонажа на лево"
	keybind_signal = COMSIG_KB_MOVEMENT_WEST_DOWN

/datum/keybinding/movement/east
	hotkey_keys = list("D", "East")
	name = "East"
	full_name = "Двигаться на право"
	description = "Перемещает вашего персонажа на право"
	keybind_signal = COMSIG_KB_MOVEMENT_EAST_DOWN

/datum/keybinding/movement/zlevel_upwards
	hotkey_keys = list("Northeast") // PGUP
	name = "Upwards"
	full_name = "Двигайтесь вверх (альт)"
	description = "Продвигает вашего персонажа на z-уровень выше, если это возможно"
	keybind_signal = COMSIG_KB_MOVEMENT_ZLEVEL_MOVEUP_DOWN

/datum/keybinding/movement/zlevel_upwards/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.up()
	return TRUE

/datum/keybinding/movement/zlevel_downwards
	hotkey_keys = list("Southeast") // PGDOWN
	name = "Downwards"
	full_name = "Двигаться вниз (альт)"
	description = "Перемещает вашего персонажа на z-уровень ниже, если это возможно"
	keybind_signal = COMSIG_KB_MOVEMENT_ZLEVEL_MOVEDOWN_DOWN

/datum/keybinding/movement/zlevel_downwards/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.down()
	return TRUE
