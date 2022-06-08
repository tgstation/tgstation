/// Used in OnResize() - Holds the clients prefs.
GLOBAL_VAR_INIT(lock_client_view_x, null)
GLOBAL_VAR_INIT(lock_client_view_y, null)
GLOBAL_LIST_INIT(valid_icon_sizes, list(32, 48, 64, 96, 128))
/// General handler for viewport updates. Takes an argument for an icon size, if not aligning with your preference, updates your preference.
/client/verb/SetWindowIconSize(val as num|text)
	set hidden = 1
	winset(src, "mapwindow.map", "icon-size=[val]")
	if(prefs && val != prefs.read_preference(/datum/preference/numeric/icon_size))
		prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/icon_size], val)
		prefs.save_preferences()
	OnResize()
/// Verb called by the games skin.dmf to update the server to update view.
/client/verb/OnResize()
	set hidden = 1
	if(!prefs?.read_preference(/datum/preference/toggle/widescreen))
		return

	var/divisor = text2num(winget(src, "mapwindow.map", "icon-size")) || prefs.read_preference(/datum/preference/numeric/icon_size) || world.icon_size
	if(!isnull(GLOB.lock_client_view_x) && !isnull(GLOB.lock_client_view_y))
		last_view_x_dim = GLOB.lock_client_view_x
		last_view_y_dim = GLOB.lock_client_view_y
	else
		var/winsize_string = winget(src, "mapwindow.map", "size")
		last_view_x_dim = GLOB.lock_client_view_x || clamp(ROUND_UP(text2num(winsize_string) / divisor), 15, (CONFIG_GET(number/max_client_view_x)) || (CONFIG_GET(number/max_client_view_x)))
		last_view_y_dim = GLOB.lock_client_view_y || clamp(ROUND_UP(text2num(copytext(winsize_string,findtext(winsize_string,"x")+1,0)) / divisor), 15, (CONFIG_GET(number/max_client_view_y)) || (CONFIG_GET(number/max_client_view_y)))
		if(last_view_x_dim % 2 == 0)
			last_view_x_dim++
		if(last_view_y_dim % 2 == 0)
			last_view_y_dim++
	for(var/check_icon_size in GLOB.valid_icon_sizes)
		winset(src, "menu.icon[check_icon_size]", "is-checked=false")
	winset(src, "menu.icon[divisor]", "is-checked=true")

	view = "[last_view_x_dim]x[last_view_y_dim]"

	// Reset eye/perspective - Yes this CAN mess up. Especially with screen shake.
	var/last_perspective = perspective
	perspective = MOB_PERSPECTIVE
	if(perspective != last_perspective)
		perspective = last_perspective
	var/last_eye = eye
	eye = mob
	if(eye != last_eye)
		eye = last_eye

	// We do this aswell because things tend to be buggy with the click catcher if not.
	change_view(getScreenSize(prefs.read_preference(/datum/preference/toggle/widescreen)))
