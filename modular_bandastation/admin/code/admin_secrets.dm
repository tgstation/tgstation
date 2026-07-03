/datum/secrets_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("move_gamma_shuttle")
			if(isnull(SSshuttle.gamma))
				to_chat(ui.user, span_warning("Шаттл «ГАММА» не найден (не заспавнен, удалён, или ошибка)."))
				return
			if(!SSshuttle.getDock("gamma_home"))
				to_chat(ui.user, span_warning("На карте \"[SSmapping.current_map.map_name]\" нет порта стыковки для оружейного шаттла «ГАММА»."))
				return
			if(SSshuttle.gamma.getDockedId() == "gamma_away")
				SSshuttle.moveShuttle("gamma", "gamma_home", FALSE)
				priority_announce("К вам направлен оружейный шаттл «ГАММА».","[command_name()]: Департамент защиты активов")
			else
				SSshuttle.moveShuttle("gamma", "gamma_away", FALSE)
				priority_announce("Оружейный шаттл «ГАММА» был отозван.", "[command_name()]: Департамент защиты активов")
			message_admins("[key_name_admin(holder)] moved gamma shuttle")
			log_admin("[key_name(holder)] moved the gamma shuttle")
