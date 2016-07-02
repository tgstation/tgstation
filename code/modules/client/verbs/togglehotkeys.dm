/client/verb/togglehotkeys(notoggle = 0 as num)
	set name = "Toggle Hotkey Mode"
	set category = "OOC"
	set desc = "Switches input mode betweeen regular and hotkey mode."

	//fallback
	var/hotkey_default = "default"
	var/hotkey_macro = "hotkeys"

	if(!notoggle)
		hotkeys = !hotkeys

	if(mob)
		hotkey_macro = mob.macro_hotkeys
		hotkey_default = mob.macro_default

	if(hotkeys)
		winset(src, null, "mainwindow.macro=[hotkey_macro] mapwindow.map.focus=true input.background-color=#e0e0e0")
	else
		winset(src, null, "mainwindow.macro=[hotkey_default] input.focus=true input.background-color=#d3b5b5")