/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/resist
	hotkey_keys = list("B")
	name = "resist"
	full_name = "Сопротивляться"
	description = "Освободись от своего нынешнего состояния. В наручниках? в огне? В захвате? Сопротивляйся!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	owner.resist()
	if (owner.hud_used?.resist_icon)
		owner.hud_used.resist_icon.icon_state = "[owner.hud_used.resist_icon.base_icon_state]_on"
	return TRUE

/datum/keybinding/living/resist/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	if (owner.hud_used?.resist_icon)
		owner.hud_used.resist_icon.icon_state = owner.hud_used.resist_icon.base_icon_state

/datum/keybinding/living/look_up
	hotkey_keys = list("L")
	name = "look up"
	full_name = "Поиск"
	description = "Посмотрите на следующий z-уровень. Работает только в том случае, если находится непосредственно под открытым пространством."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_up()
	return TRUE

/datum/keybinding/living/look_up/up(client/user)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look_up()
	return TRUE

/datum/keybinding/living/look_down
	hotkey_keys = list(";")
	name = "look down"
	full_name = "Смотреть вниз"
	description = "Посмотрите вниз на предыдущий z-уровень. Работает, только если находится непосредственно над открытым пространством."
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_down()
	return TRUE

/datum/keybinding/living/look_down/up(client/user)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look_down()
	return TRUE

/datum/keybinding/living/rest
	hotkey_keys = list("U")
	name = "rest"
	full_name = "Отдых"
	description = "Ложись или вставай."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/toggle_combat_mode
	hotkey_keys = list("F")
	name = "toggle_combat_mode"
	full_name = "Переключение боевого режима"
	description = "Переключает боевой режим. Нравится помогать / вредить, но круче пить пиво."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN


/datum/keybinding/living/toggle_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(!user_mob.combat_mode, FALSE)

/datum/keybinding/living/enable_combat_mode
	hotkey_keys = list("4")
	name = "enable_combat_mode"
	full_name = "Включить боевой режим"
	description = "Включит боевой режим."
	keybind_signal = COMSIG_KB_LIVING_ENABLE_COMBAT_DOWN

/datum/keybinding/living/enable_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(TRUE, silent = FALSE)

/datum/keybinding/living/disable_combat_mode
	hotkey_keys = list("1")
	name = "disable_combat_mode"
	full_name = "Включить режим помощи"
	description = "Включит режим помощи."
	keybind_signal = COMSIG_KB_LIVING_DISABLE_COMBAT_DOWN

/datum/keybinding/living/disable_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(FALSE, silent = FALSE)

/datum/keybinding/living/toggle_move_intent
	hotkey_keys = list("C")
	name = "toggle_move_intent"
	full_name = "Режим перемещения"
	description = "Удерживая нажатой клавишу для перехода к бегу, отпустите ее, чтобы перейти к хотьбе."
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/living/toggle_move_intent/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_move_intent/up(client/user)
	. = ..()
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_move_intent_alternative
	hotkey_keys = list("Unbound")
	name = "toggle_move_intent_alt"
	full_name = "Нажмите, чтобы повторить перемещение"
	description = "Нажатие на этот цикл с целью, противоположного перемещения (Я сам нихуя не понял)."
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENTALT_DOWN

/datum/keybinding/living/toggle_move_intent_alternative/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE
