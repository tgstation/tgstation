// If you use a file(...) object, instead of caching the asset it will be loaded from disk every time it's requested.
// This is useful for development, but not recommended for production.
// And if TGS is defined, we're being run in a production environment.

#ifdef TGS
/datum/asset/simple/tgui
	keep_local_name = FALSE
	assets = list(
		"tgui.bundle.js" = "tgui/public/tgui.bundle.js",
		"tgui.bundle.css" = "tgui/public/tgui.bundle.css",
	)

/datum/asset/simple/tgui_panel
	keep_local_name = FALSE
	assets = list(
		"tgui-panel.bundle.js" = "tgui/public/tgui-panel.bundle.js",
		"tgui-panel.bundle.css" = "tgui/public/tgui-panel.bundle.css",
	)

#else
/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = file("tgui/public/tgui-panel.bundle.js"),
		"tgui-panel.bundle.css" = file("tgui/public/tgui-panel.bundle.css"),
	)

#endif

/datum/asset/simple/namespaced/escape_menu_font
	assets = list(
		"Pixellari.ttf" = file("interface/fonts/Pixellari.ttf"),
		"Grand9K_Pixel.ttf" = file("interface/fonts/Grand9K_Pixel.ttf"),
	)
	parents = list(
		"fonts.css" = file("tgui/packages/tgui-escape-menu/styles/fonts.css"),
	)

/datum/asset/simple/namespaced/escape_menu_sounds
	assets = list(
		"esc_open.ogg" = file("sound/misc/escape_menu/esc_open.ogg"),
		"esc_middle.ogg" = file("sound/misc/escape_menu/esc_middle.ogg"),
		"esc_close.ogg" = file("sound/misc/escape_menu/esc_close.ogg"),
	)

/datum/asset/spritesheet/escape_menu_icons
	name = "escape-menu-icons"

/datum/asset/spritesheet/escape_menu_icons/create_spritesheets()
	var/icon/icons_small = 'icons/hud/escape_menu_icons.dmi'
	for(var/state in icon_states(icons_small))
		Insert(state, icons_small, icon_state = state)
	var/icon/icons_large = 'icons/hud/escape_menu_leave_body.dmi'
	for(var/state in icon_states(icons_large))
		Insert("leave-[state]", icons_large, icon_state = state)

/datum/asset/simple/namespaced/lobby_menu_font
	assets = list(
		"Pixellari.ttf" = file("interface/fonts/Pixellari.ttf"),
		"Grand9K_Pixel.ttf" = file("interface/fonts/Grand9K_Pixel.ttf"),
	)
	parents = list(
		"fonts.css" = file("tgui/packages/tgui-lobby/styles/fonts.css"),
	)

/// Registers all PNG/APNG files from icons/hud/lobby/png/ as named assets.
/// To add a new lobby icon, just drop a .png file in that directory.
/datum/asset/simple/namespaced/lobby_menu_icons

/datum/asset/simple/namespaced/lobby_menu_icons/register()
	var/dir_path = "icons/hud/lobby/png/"
	for(var/filename in flist(dir_path))
		if(!findtext(filename, ".png"))
			continue
		assets[filename] = file("[dir_path][filename]")
	return ..()

/datum/asset/simple/namespaced/lobby_menu_sounds
	assets = list(
		"ui_select1.ogg" = file("sound/misc/menu/ui_select1.ogg"),
		"menu_rollup1.ogg" = file("sound/misc/menu/menu_rollup1.ogg"),
		"menu_rolldown1.ogg" = file("sound/misc/menu/menu_rolldown1.ogg"),
	)

/datum/asset/simple/chat_dark
	keep_local_name = FALSE
	assets = list(
		"tgui-chat-dark.bundle.css" = file("tgui/public/tgui-chat-dark.bundle.css"),
	)
