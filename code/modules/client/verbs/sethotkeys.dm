/client/verb/sethotkeys(from_pref = 0 as num)
	set name = "Set Hotkeys"
	set hidden = TRUE
	set waitfor = FALSE
	set desc = "Used to set mob-specific hotkeys or load hoykey mode from preferences"

	var/hotkey_default = "default"
	var/hotkey_macro = "hotkeys"
	var/current_setting

	var/list/default_macros = list("default", "robot-default")

	if(from_pref)
		current_setting = (prefs.hotkeys ? hotkey_macro : hotkey_default)
	else
		current_setting = winget(src, "mainwindow", "macro")

	if(mob)
		hotkey_macro = mob.macro_hotkeys
		hotkey_default = mob.macro_default

	if(current_setting in default_macros)
		winset(src, null, "mainwindow.macro=[hotkey_default] input.focus=true input.background-color=#d3b5b5")
	else
		winset(src, null, "mainwindow.macro=[hotkey_macro] mapwindow.map.focus=true input.background-color=#e0e0e0")
