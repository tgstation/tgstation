/datum/keybinding/mob
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/mob/stop_pulling
	hotkey_keys = list("H", "Delete")
	name = "stop_pulling"
	full_name = "Перестань тянуть"
	description = ""
	keybind_signal = COMSIG_KB_MOB_STOPPULLING_DOWN

/datum/keybinding/mob/stop_pulling/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	if(!M.pulling)
		to_chat(user, span_notice("Вы ничего не тащите."))
	else
		M.stop_pulling()
	return TRUE

/datum/keybinding/mob/swap_hands
	hotkey_keys = list("X")
	name = "swap_hands"
	full_name = "Поменять руки"
	description = ""
	keybind_signal = COMSIG_KB_MOB_SWAPHANDS_DOWN

/datum/keybinding/mob/swap_hands/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.swap_hand()
	return TRUE

/datum/keybinding/mob/activate_inhand
	hotkey_keys = list("Z")
	name = "activate_inhand"
	full_name = "Активировать в руке"
	description = "Использует любой предмет, который у вас есть в руках"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/mob/activate_inhand/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/mob/drop_item
	hotkey_keys = list("Q")
	name = "drop_item"
	full_name = "Положить предмет"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/down(client/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user.mob)) //cyborgs can't drop items
		return FALSE
	var/mob/M = user.mob
	var/obj/item/I = M.get_active_held_item()
	if(!I)
		to_chat(user, span_warning("Тебе нечего положить!"))
	else
		user.mob.dropItemToGround(I)
	return TRUE

/datum/keybinding/mob/target/down(client/user)
	. = ..()
	if(.)
		return .

	var/original = user.mob.zone_selected
	switch(keybind_signal)
		if(COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN)
			user.body_toggle_head()
		if(COMSIG_KB_MOB_TARGETHEAD_DOWN)
			user.body_head()
		if(COMSIG_KB_MOB_TARGETEYES_DOWN)
			user.body_eyes()
		if(COMSIG_KB_MOB_TARGETMOUTH_DOWN)
			user.body_mouth()
		if(COMSIG_KB_MOB_TARGETRIGHTARM_DOWN)
			user.body_r_arm()
		if(COMSIG_KB_MOB_TARGETBODYCHEST_DOWN)
			user.body_chest()
		if(COMSIG_KB_MOB_TARGETLEFTARM_DOWN)
			user.body_l_arm()
		if(COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN)
			user.body_r_leg()
		if(COMSIG_KB_MOB_TARGETBODYGROIN_DOWN)
			user.body_groin()
		if(COMSIG_KB_MOB_TARGETLEFTLEG_DOWN)
			user.body_l_leg()
		else
			stack_trace("Целевая привязка клавиш нажата, но не реализована! '[keybind_signal]'")
			return FALSE
	user.mob.log_manual_zone_selected_update("keybind", old_target = original)

/datum/keybinding/mob/target/head_cycle
	hotkey_keys = list("Numpad8")
	name = "target_head_cycle"
	full_name = "Цель: Лицо"
	description = "Нажатие этой клавиши нацелено на голову, а при продолжении нажатия происходит циклическое воздействие на глаза и рот. Это влияет на то, куда вы ударяете людей, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN

/datum/keybinding/mob/target/head
	hotkey_keys = list("Unbound")
	name = "target_head"
	full_name = "Цель: Голова"
	description = "Нажатие этой клавиши нацелено на голову. Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETHEAD_DOWN

/datum/keybinding/mob/target/eyes
	hotkey_keys = list("Numpad7")
	name = "target_eyes"
	full_name = "Цель: Глаза"
	description = "Нажатие этой клавиши направлено на глаза. Это повлияет на то, куда вы ударите людей, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETEYES_DOWN

/datum/keybinding/mob/target/mouth
	hotkey_keys = list("Numpad9")
	name = "target_mouths"
	full_name = "Цель: Рот"
	description = "Нажатие этой клавиши нацелено на рот. Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETMOUTH_DOWN

/datum/keybinding/mob/target/r_arm
	hotkey_keys = list("Numpad4")
	name = "target_r_arm"
	full_name = "Цель: Правая рука"
	description = "Нажатие этой клавиши нацелено на правую руку. Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN

/datum/keybinding/mob/target/body_chest
	hotkey_keys = list("Numpad5")
	name = "target_body_chest"
	full_name = "Цель: Body"
	description = "Нажатие этой клавиши нацелено на торс (грудь). Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target/left_arm
	hotkey_keys = list("Numpad6")
	name = "target_left_arm"
	full_name = "Цель: Левая рука"
	description = "Нажатие этой клавиши нацелено на левую руку. Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN

/datum/keybinding/mob/target/right_leg
	hotkey_keys = list("Numpad1")
	name = "target_right_leg"
	full_name = "Цель: Правая нога"
	description = "Нажатие этой клавиши нацелено на правую ногу. Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN

/datum/keybinding/mob/target/body_groin
	hotkey_keys = list("Numpad2")
	name = "target_body_groin"
	full_name = "Цель: Пах"
	description = "Нажатие этой клавиши нацелено на область паха. Это повлияет на то, куда вы наносите удары, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target/left_leg
	hotkey_keys = list("Numpad3")
	name = "target_left_leg"
	full_name = "Цель: Левая нога"
	description = "Нажатие этой клавиши нацелено на левую ногу. Это повлияет на то, куда вы ударите человека, и может быть использовано при хирургическом вмешательстве."
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN

/datum/keybinding/mob/prevent_movement
	hotkey_keys = list("Alt")
	name = "block_movement"
	full_name = "Блокируйте движение (Своё)"
	description = "Не даёт вам двигаться по тайтлам."
	keybind_signal = COMSIG_KB_MOB_BLOCKMOVEMENT_DOWN

/datum/keybinding/mob/prevent_movement/down(client/user)
	. = ..()
	if(.)
		return
	user.movement_locked = TRUE

/datum/keybinding/mob/prevent_movement/up(client/user)
	. = ..()
	if(.)
		return
	user.movement_locked = FALSE

/datum/keybinding/living/view_pet_data
	hotkey_keys = list("Shift")
	name = "view_pet_commands"
	full_name = "Просмотр команд для персонажа"
	description = "Удерживайте нажатой клавишу, чтобы увидеть все команды, которые вы можете дать своим персонажме! (Хоткей + ПКМ = все действия)"
	keybind_signal = COMSIG_KB_LIVING_VIEW_PET_COMMANDS
