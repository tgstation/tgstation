/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return user.holder ? TRUE : FALSE

/datum/keybinding/admin/admin_say
	hotkey_keys = list("F3")
	name = "admin_say"
	full_name = "Admin say"
	description = "Talk with other admins."
	keybind_signal = COMSIG_KB_ADMIN_ASAY_DOWN

/datum/keybinding/admin/admin_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_admin_say()
	return TRUE

/datum/keybinding/admin/admin_ghost
	hotkey_keys = list("F5")
	name = "admin_ghost"
	full_name = "Aghost"
	description = "Go ghost"
	keybind_signal = COMSIG_KB_ADMIN_AGHOST_DOWN

/datum/keybinding/admin/admin_ghost/down(client/user)
	. = ..()
	if(.)
		return
	user.admin_ghost()
	return TRUE

/datum/keybinding/admin/player_panel_new
	hotkey_keys = list("F6")
	name = "player_panel_new"
	full_name = "Player Panel New"
	description = "Opens up the new player panel"
	keybind_signal = COMSIG_KB_ADMIN_PLAYERPANELNEW_DOWN

/datum/keybinding/admin/player_panel_new/down(client/user)
	. = ..()
	if(.)
		return
	user.holder.player_panel_new()
	return TRUE

/datum/keybinding/admin/toggle_buildmode_self
	hotkey_keys = list("F7")
	name = "toggle_buildmode_self"
	full_name = "Toggle Buildmode Self"
	description = "Toggles buildmode"
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN

/datum/keybinding/admin/toggle_buildmode_self/down(client/user)
	. = ..()
	if(.)
		return
	user.togglebuildmodeself()
	return TRUE

/datum/keybinding/admin/stealthmode
	hotkey_keys = list("CtrlF8")
	name = "stealth_mode"
	full_name = "Stealth mode"
	description = "Enters stealth mode"
	keybind_signal = COMSIG_KB_ADMIN_STEALTHMODETOGGLE_DOWN

/datum/keybinding/admin/stealthmode/down(client/user)
	. = ..()
	if(.)
		return
	user.stealth()
	return TRUE

/datum/keybinding/admin/invisimin
	hotkey_keys = list("F8")
	name = "invisimin"
	full_name = "Admin invisibility"
	description = "Toggles ghost-like invisibility (Don't abuse this)"
	keybind_signal = COMSIG_KB_ADMIN_INVISIMINTOGGLE_DOWN

/datum/keybinding/admin/invisimin/down(client/user)
	. = ..()
	if(.)
		return
	user.invisimin()
	return TRUE

/datum/keybinding/admin/deadsay
	hotkey_keys = list("F10")
	name = "dsay"
	full_name = "deadsay"
	description = "Allows you to send a message to dead chat"
	keybind_signal = COMSIG_KB_ADMIN_DSAY_DOWN

/datum/keybinding/admin/deadsay/down(client/user)
	. = ..()
	if(.)
		return
	user.get_dead_say()
	return TRUE

/datum/keybinding/admin/deadmin
	hotkey_keys = list("Unbound")
	name = "deadmin"
	full_name = "Deadmin"
	description = "Shed your admin powers"
	keybind_signal = COMSIG_KB_ADMIN_DEADMIN_DOWN

/datum/keybinding/admin/deadmin/down(client/user)
	. = ..()
	if(.)
		return
	user.deadmin()
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list("Unbound")
	name = "readmin"
	full_name = "Readmin"
	description = "Regain your admin powers"
	keybind_signal = COMSIG_KB_ADMIN_READMIN_DOWN

/datum/keybinding/admin/readmin/down(client/user)
	. = ..()
	if(.)
		return
	user.readmin()
	return TRUE
