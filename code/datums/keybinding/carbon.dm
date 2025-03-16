/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB

/datum/keybinding/carbon/can_use(client/user)
	return iscarbon(user.mob)

/datum/keybinding/carbon/toggle_throw_mode
	hotkey_keys = list("R", "Southwest") // END
	name = "toggle_throw_mode"
	full_name = "Переключение режима броска"
	description = "Переключите, выбрасывать текущий элемент или нет."
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_TOGGLETHROWMODE_DOWN

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE

/datum/keybinding/carbon/hold_throw_mode
	hotkey_keys = list("Space")
	name = "hold_throw_mode"
	full_name = "Удерживайте режим броска"
	description = "Удерживайте эту кнопку, чтобы включить режим броска, и отпустите, чтобы выключить режим броска"
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_HOLDTHROWMODE_DOWN

/datum/keybinding/carbon/hold_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon_user = user.mob
	carbon_user.throw_mode_on(THROW_MODE_HOLD)

/datum/keybinding/carbon/hold_throw_mode/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon_user = user.mob
	carbon_user.throw_mode_off(THROW_MODE_HOLD)
/datum/keybinding/carbon/give
	hotkey_keys = list("G")
	name = "Give_Item"
	full_name = "Дайте предмет"
	description = "Отдайте предмет, который вы сейчас держите в руках (из рук в руки)"
	keybind_signal = COMSIG_KB_CARBON_GIVEITEM_DOWN

/datum/keybinding/carbon/give/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/carbon_user = user.mob
	carbon_user.give()
	return TRUE
