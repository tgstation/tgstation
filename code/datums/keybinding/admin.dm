/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return user.holder ? TRUE : FALSE

/datum/keybinding/admin/admin_say
	hotkey_keys = list("F3")
	name = ADMIN_CHANNEL
	full_name = "Администратор чат Say"
	description = "Поговорите с другими администраторами."
	keybind_signal = COMSIG_KB_ADMIN_ASAY_DOWN

/datum/keybinding/admin/admin_ghost
	hotkey_keys = list("F5")
	name = "admin_ghost"
	full_name = "Админский призрак"
	description = "Стань призраком, но чуть круче"
	keybind_signal = COMSIG_KB_ADMIN_AGHOST_DOWN

/datum/keybinding/admin/admin_ghost/down(client/user)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	return TRUE

/datum/keybinding/admin/player_panel_new
	hotkey_keys = list("F6")
	name = "player_panel_new"
	full_name = "Новая панель проигрывателя"
	description = "Открывает новую панель проигрывателя"
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
	full_name = "Переключить режим сборки самостоятельно"
	description = "Переключает режим сборки"
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN

/datum/keybinding/admin/toggle_buildmode_self/down(client/user)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/build_mode_self)
	return TRUE

/datum/keybinding/admin/stealthmode
	hotkey_keys = list("CtrlF8")
	name = "stealth_mode"
	full_name = "Скрытый режим"
	description = "Переходит в скрытый режим"
	keybind_signal = COMSIG_KB_ADMIN_STEALTHMODETOGGLE_DOWN

/datum/keybinding/admin/stealthmode/down(client/user)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/stealth)
	return TRUE

/datum/keybinding/admin/invisimin
	hotkey_keys = list("F8")
	name = "invisimin"
	full_name = "Невидимость администратора"
	description = "Переключает призрачную невидимость (не злоупотребляйте этим)"
	keybind_signal = COMSIG_KB_ADMIN_INVISIMINTOGGLE_DOWN

/datum/keybinding/admin/invisimin/down(client/user)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/invisimin)
	return TRUE

/datum/keybinding/admin/deadsay
	hotkey_keys = list("F10")
	name = "dsay"
	full_name = "Мёртвый чат Say"
	description = "Позволяет вам отправить сообщение в мертвый чат"
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
	full_name = "Снять админ права"
	description = "Откажитесь от своих административных полномочий"
	keybind_signal = COMSIG_KB_ADMIN_DEADMIN_DOWN

/datum/keybinding/admin/deadmin/down(client/user)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/deadmin)
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list("Unbound")
	name = "readmin"
	full_name = "Вернуть админ права"
	description = "Восстановите свои административные полномочия"
	keybind_signal = COMSIG_KB_ADMIN_READMIN_DOWN

/datum/keybinding/admin/readmin/down(client/user)
	. = ..()
	if(.)
		return
	user.readmin()
	return TRUE

/datum/keybinding/admin/view_tags
	hotkey_keys = list("F9")
	name = "view_tags"
	full_name = "Просмотр тегов"
	description = "Откройте меню Просмотр-Теги"
	keybind_signal = COMSIG_KB_ADMIN_VIEWTAGS_DOWN

/datum/keybinding/admin/view_tags/down(client/user)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/display_tags)
	return TRUE
