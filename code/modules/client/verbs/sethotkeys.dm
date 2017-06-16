/client/verb/sethotkeys(from_pref = 0 as num)
	set name = "Set Hotkeys"
	set hidden = TRUE
	set waitfor = FALSE
	set desc = "Used to set mob-specific hotkeys or load hoykey mode from preferences"

	var/hotkey_default = "default"
	var/hotkey_macro = "hotkeys"
	var/current_setting

	if(from_pref)
		current_setting = (prefs.hotkeys ? hotkey_macro : hotkey_default)
	else
		current_setting = winget(src, "mainwindow", "macro")

	if(mob)
		hotkey_macro = mob.macro_hotkeys
		hotkey_default = mob.macro_default

	if(!in_hotkey_mode(current_setting))
		winset(src, null, "mainwindow.macro=[hotkey_default] input.focus=true input.background-color=#d3b5b5")
	else
		winset(src, null, "mainwindow.macro=[hotkey_macro] mapwindow.map.focus=true input.background-color=#e0e0e0")

/client/proc/in_hotkey_mode(current_setting)
	var/static/list/default_macros = list("default", "robot-default")
	if(!current_setting)
		current_setting = winget(src, "mainwindow", "macro")
	return !(current_setting in default_macros)

/client/proc/ResetHotkeyInputFocus(clear_input)
	var/cmd
	if(clear_input)
		cmd = "input.text=[null]"
	if(in_hotkey_mode())
		cmd = "[cmd ? "[cmd] " : ""] mapwindow.map.focus=true"
	if(cmd)
		winset(src, null, cmd)