/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN
	// BANDASTATION ADDITION START - Valid permissions
	/// Bitfield with permissions required for this keybind
	var/required_permissions = R_NONE
	// BANDASTATION ADDITION END

/datum/keybinding/admin/can_use(client/user)
	return check_rights_for(user, required_permissions) // BANDASTATION EDIT - Valid permissions

// BANDASTATION EDIT START - Mentors
/datum/keybinding/admin/mentor_say
	hotkey_keys = list("F4")
	name = MENTOR_CHANNEL
	full_name = "Msay"
	description = "Разговаривайте с другими менторами"
	keybind_signal = COMSIG_KB_ADMIN_MSAY_DOWN
	required_permissions = R_MENTOR
// BANDASTATION EDIT END - Mentors

/datum/keybinding/admin/admin_say
	hotkey_keys = list("F5") // BANDASTATION EDIT
	name = ADMIN_CHANNEL
	full_name = "Asay"
	description = "Разговаривайте с другими админами"
	keybind_signal = COMSIG_KB_ADMIN_ASAY_DOWN
	required_permissions = R_ADMIN // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/admin_ghost
	hotkey_keys = list("F6") // BANDASTATION EDIT
	name = "admin_ghost"
	full_name = "Aghost"
	description = "Уйти в призраки"
	keybind_signal = COMSIG_KB_ADMIN_AGHOST_DOWN
	required_permissions = R_ADMIN // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/admin_ghost/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	return TRUE

/datum/keybinding/admin/jump_to_ghost
	hotkey_keys = list("F4")
	name = "jump_to_ghost"
	full_name = "Jump to Aghost"
	description = "Jump your body to your Aghost"
	keybind_signal = COMSIG_KB_ADMIN_JUMPTOGHOST_DOWN

/datum/keybinding/admin/jump_to_ghost/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/jump_to_ghost)
	return TRUE

/datum/keybinding/admin/player_panel_new
	hotkey_keys = list("F7") // BANDASTATION EDIT
	name = "player_panel_new"
	full_name = "Player Panel New"
	description = "Открывает панель новых игроков"
	keybind_signal = COMSIG_KB_ADMIN_PLAYERPANELNEW_DOWN

/datum/keybinding/admin/player_panel_new/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.holder.player_panel_new()
	return TRUE

/datum/keybinding/admin/toggle_buildmode_self
	hotkey_keys = list("F11") // BANDASTATION EDIT
	name = "toggle_buildmode_self"
	full_name = "Toggle Buildmode Self"
	description = "Включает режим строительства"
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN
	required_permissions = R_BUILD // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/toggle_buildmode_self/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/build_mode_self)
	return TRUE

/datum/keybinding/admin/stealthmode
	hotkey_keys = list("CtrlF9") // BANDASTATION EDIT
	name = "stealth_mode"
	full_name = "Stealth mode"
	description = "Включает стелс режим"
	keybind_signal = COMSIG_KB_ADMIN_STEALTHMODETOGGLE_DOWN
	required_permissions = R_STEALTH // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/stealthmode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/stealth)
	return TRUE

/datum/keybinding/admin/invisimin
	hotkey_keys = list("F9") // BANDASTATION EDIT
	name = "invisimin"
	full_name = "Invisimin"
	description = "Включает невидимость, как у призраков (Не абузьте этим)"
	keybind_signal = COMSIG_KB_ADMIN_INVISIMINTOGGLE_DOWN
	required_permissions = R_ADMIN // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/invisimin/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/invisimin)
	return TRUE

/datum/keybinding/admin/deadsay
	hotkey_keys = list("F10")
	name = "dsay"
	full_name = "Dsay"
	description = "Отправляет сообщение в чат мертвых"
	keybind_signal = COMSIG_KB_ADMIN_DSAY_DOWN
	required_permissions = R_ADMIN // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/deadsay/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.get_dead_say()
	return TRUE

/datum/keybinding/admin/deadmin
	hotkey_keys = list(UNBOUND_KEY)
	name = "deadmin"
	full_name = "Deadmin"
	description = "Избавиться от своих админских сил"
	keybind_signal = COMSIG_KB_ADMIN_DEADMIN_DOWN

/datum/keybinding/admin/deadmin/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/deadmin)
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list(UNBOUND_KEY)
	name = "readmin"
	full_name = "Readmin"
	description = "Вернуть свои админские силы"
	keybind_signal = COMSIG_KB_ADMIN_READMIN_DOWN

/datum/keybinding/admin/readmin/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.readmin()
	return TRUE

/datum/keybinding/admin/view_tags
	hotkey_keys = list("CtrlF11") // BANDASTATION EDIT
	name = "view_tags"
	full_name = "View Tags"
	description = "Открывает меню View-Tags"
	keybind_signal = COMSIG_KB_ADMIN_VIEWTAGS_DOWN
	required_permissions = R_ADMIN // BANDASTATION EDIT - Valid permissions

/datum/keybinding/admin/view_tags/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/display_tags)
	return TRUE
