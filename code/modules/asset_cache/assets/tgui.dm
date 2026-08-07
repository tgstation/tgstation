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

/datum/asset/spritesheet/lobby_menu_icons
	name = "lobby-icons"

/datum/asset/spritesheet/lobby_menu_icons/create_spritesheets()
	InsertAll("", 'icons/hud/lobby/ready.dmi')
	InsertAll("", 'icons/hud/lobby/join.dmi')
	InsertAll("", 'icons/hud/lobby/observe.dmi')
	InsertAll("", 'icons/hud/lobby/character_setup.dmi')
	InsertAll("", 'icons/hud/lobby/collapse_expand.dmi')
	InsertAll("", 'icons/hud/lobby/start_now.dmi')
	InsertAll("", 'icons/hud/lobby/signup_button.dmi')
	InsertAll("bottom", 'icons/hud/lobby/bottom_buttons.dmi')
	InsertAll("", 'icons/hud/lobby/poll_overlay.dmi')
	InsertAll("tv", 'icons/hud/lobby/newplayer.dmi')
	Insert("background", 'icons/hud/lobby/background.dmi', icon_state = "background")
	Insert("shutter", 'icons/hud/lobby/shutter.dmi', icon_state = "shutter")

/datum/asset/simple/namespaced/lobby_menu_animated
	assets = list(
		"not_ready_pressed.png" = file("icons/hud/lobby/apng/not_ready_pressed.png"),
		"ready_pressed.png" = file("icons/hud/lobby/apng/ready_pressed.png"),
		"join_game_pressed.png" = file("icons/hud/lobby/apng/join_game_pressed.png"),
		"observe_pressed.png" = file("icons/hud/lobby/apng/observe_pressed.png"),
		"observe_enabled.png" = file("icons/hud/lobby/apng/observe_enabled.png"),
		"character_setup_pressed.png" = file("icons/hud/lobby/apng/character_setup_pressed.png"),
		"character_setup_enabled.png" = file("icons/hud/lobby/apng/character_setup_enabled.png"),
		"poll_pressed.png" = file("icons/hud/lobby/apng/poll_pressed.png"),
		"settings_pressed.png" = file("icons/hud/lobby/apng/settings_pressed.png"),
		"changelog_pressed.png" = file("icons/hud/lobby/apng/changelog_pressed.png"),
		"crew_manifest_pressed.png" = file("icons/hud/lobby/apng/crew_manifest_pressed.png"),
		"signup_pressed.png" = file("icons/hud/lobby/apng/signup_pressed.png"),
		"signup_on_pressed.png" = file("icons/hud/lobby/apng/signup_on_pressed.png"),
		"static_base.png" = file("icons/hud/lobby/apng/static_base.png"),
		"scanline.png" = file("icons/hud/lobby/apng/scanline.png"),
	)

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
