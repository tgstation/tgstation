/client/verb/toggle_reverb()
	set name = "Toggle reverb"
	set category = "Preferences"
	set desc = "Toggle reverb effects"

	prefs.reverb = !prefs.reverb
	prefs.save_preferences()
	to_chat(usr, "<span class='danger'>Reverb effects [prefs.reverb ? "enabled" : "disabled"]</span>")