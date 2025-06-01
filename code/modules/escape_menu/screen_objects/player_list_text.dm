/atom/movable/screen/escape_menu/text/clickable/ignoring
	///The ckey this targets, this has to be its own thing because of admin fake keys.
	///otherwise, by default, this is simply button_text.
	var/player_ckey

/atom/movable/screen/escape_menu/text/clickable/ignoring/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	list/offset,
	font_size,
	on_click_callback,
	player_ckey
)
	src.player_ckey = player_ckey || button_text
	return ..()

/atom/movable/screen/escape_menu/text/clickable/ignoring/text_color()
	return (player_ckey in escape_menu.client?.prefs.ignoring) ? "grey" : "white"

///Offline subtype that deletes itself when you unignore, as they aren't online to re-ignore.
/atom/movable/screen/escape_menu/text/clickable/ignoring/offline/update_text()
	if(player_ckey in escape_menu.client?.prefs.ignoring)
		return ..()
	qdel(src)
