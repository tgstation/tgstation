/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Ахелп"
	description = "Обратитесь за помощью к администратору."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/admin_help/down(client/user)
	. = ..()
	if(.)
		return
	user.adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("F2")
	name = "screenshot"
	full_name = "Скриншот"
	description = "Сделайте снимок экрана."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.auto")
	return TRUE

/datum/keybinding/client/toggle_fullscreen
	hotkey_keys = list("F11")
	name = "toggle_fullscreen"
	full_name = "Переключение полноэкранного режима"
	description = "Делает игровое окно полноэкранным."
	keybind_signal = COMSIG_KB_CLIENT_FULLSCREEN_DOWN

/datum/keybinding/client/toggle_fullscreen/down(client/user)
	. = ..()
	if(.)
		return
	user.toggle_fullscreen()
	return TRUE

/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Минимальный HUD"
	description = "Скрыть большинство функций HUD"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/minimal_hud/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE
