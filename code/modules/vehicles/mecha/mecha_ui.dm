/obj/vehicle/sealed/mecha/ui_close(mob/user)
	. = ..()
	ui_view.hide_from(user)

/obj/vehicle/sealed/mecha/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name)
		ui.open()
		ui_view.display_to(user)

/obj/vehicle/sealed/mecha/ui_status(mob/user)
	if(contains(user))
		return UI_INTERACTIVE
	return min(
		ui_status_user_is_abled(user, src),
		ui_status_user_has_free_hands(user, src),
		ui_status_user_is_advanced_tool_user(user),
		ui_status_only_living(user),
		max(
			ui_status_user_is_adjacent(user, src),
			ui_status_silicon_has_access(user, src),
		)
	)

/obj/vehicle/sealed/mecha/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/mecha_equipment))

/obj/vehicle/sealed/mecha/ui_static_data(mob/user)
	var/list/data = list()
	data["ui_theme"] = ui_theme
	data["cabin_dangerous_highpressure"] = WARNING_HIGH_PRESSURE
	data["sheet_material_amount"] = SHEET_MATERIAL_AMOUNT
	//map of relevant flags to check tgui side, not every flag needs to be here
	data["mechflag_keys"] = list(
		"ADDING_ACCESS_POSSIBLE" = ADDING_ACCESS_POSSIBLE,
		"ADDING_MAINT_ACCESS_POSSIBLE" = ADDING_MAINT_ACCESS_POSSIBLE,
		"LIGHTS_ON" = LIGHTS_ON,
		"HAS_LIGHTS" = HAS_LIGHTS,
	)
	data["internal_damage_keys"] = list(
		"MECHA_INT_FIRE" = MECHA_INT_FIRE,
		"MECHA_INT_TEMP_CONTROL" = MECHA_INT_TEMP_CONTROL,
		"MECHA_INT_TANK_BREACH" = MECHA_INT_TANK_BREACH,
		"MECHA_INT_CONTROL_LOST" = MECHA_INT_CONTROL_LOST,
		"MECHA_INT_SHORT_CIRCUIT" = MECHA_INT_SHORT_CIRCUIT,
	)
	return data

/obj/vehicle/sealed/mecha/ui_data(mob/user)
	var/list/data = list()
	var/isoperator = (user in occupants) //maintenance mode outside of mech
	data["isoperator"] = isoperator
	if(!isoperator)
		data["name"] = name
		data["mecha_flags"] = mecha_flags
		data["cell"] = cell?.name
		data["scanning"] = scanmod?.name
		data["capacitor"] = capacitor?.name
		data["operation_req_access"] = list()
		data["idcard_access"] = list()
		for(var/code in operation_req_access)
			data["operation_req_access"] += list(list("name" = SSid_access.get_access_desc(code), "number" = code))
		if(!isliving(user))
			return data
		var/mob/living/living_user = user
		var/obj/item/card/id/card = living_user.get_idcard(TRUE)
		if(!card)
			return data
		for(var/idcode in card.access)
			if(idcode in operation_req_access)
				continue
			var/accessname = SSid_access.get_access_desc(idcode)
			if(!accessname)
				continue //there's some strange access without a name
			data["idcard_access"] += list(list("name" = accessname, "number" = idcode))
		return data
	ui_view.appearance = appearance
	data["name"] = name
	data["integrity"] = atom_integrity/max_integrity
	data["power_level"] = cell?.charge
	data["power_max"] = cell?.maxcharge
	data["mecha_flags"] = mecha_flags
	data["internal_damage"] = internal_damage
	data["dna_lock"] = dna_lock
	data["weapons_safety"] = weapons_safety
	data["mech_view"] = ui_view.assigned_map
	data["modules"] = get_module_ui_data()
	return data

/obj/vehicle/sealed/mecha/proc/get_module_ui_data()
	var/list/data = list()
	for(var/category in max_equip_by_category)
		var/max_per_category = max_equip_by_category[category]
		for(var/i = 1 to max_per_category)
			var/equipment = equip_by_category[category]
			var/is_slot_free = islist(equipment) ? i > length(equipment) : isnull(equipment)
			if(is_slot_free)
				data += list(list(
					"slot" = category
				))
			else
				var/obj/item/mecha_parts/mecha_equipment/module = islist(equipment) ? equipment[i] : equipment
				data += list(list(
					"slot" = category,
					"icon" = module.icon_state,
					"name" = module.name,
					"desc" = module.desc,
					"detachable" = module.detachable,
					"integrity" = (module.get_integrity()/module.max_integrity),
					"can_be_toggled" = module.can_be_toggled,
					"can_be_triggered" = module.can_be_triggered,
					"active" = module.active,
					"equip_cooldown" = module.equip_cooldown && DisplayTimeText(module.equip_cooldown),
					"energy_per_use" = module.energy_drain,
					"snowflake" = module.get_snowflake_data(),
					"ref" = REF(module),
				))
	return data

/obj/vehicle/sealed/mecha/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!(usr in occupants))
		switch(action)
			if("stopmaint")
				if(construction_state > MECHA_LOCKED)
					to_chat(usr, span_warning("You must end Maintenance Procedures first!"))
					return
				mecha_flags &= ~ADDING_MAINT_ACCESS_POSSIBLE
				ui.close()
				return FALSE
			if("togglemaint")
				if(!(mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE))
					return FALSE
				if(construction_state == MECHA_LOCKED)
					construction_state = MECHA_SECURE_BOLTS
					to_chat(usr, span_notice("The securing bolts are now exposed."))
				else if(construction_state == MECHA_SECURE_BOLTS)
					construction_state = MECHA_LOCKED
					to_chat(usr, span_notice("The securing bolts are now hidden."))
			if("drop_cell")
				if(construction_state != MECHA_OPEN_HATCH)
					return
				usr.put_in_hands(cell)
				cell = null
			if("drop_scanning")
				if(construction_state != MECHA_OPEN_HATCH)
					return
				usr.put_in_hands(scanmod)
				scanmod = null
			if("drop_capacitor")
				if(construction_state != MECHA_OPEN_HATCH)
					return
				usr.put_in_hands(capacitor)
				capacitor = null
			if("add_req_access")
				if(!(mecha_flags & ADDING_ACCESS_POSSIBLE))
					return
				if(!(params["added_access"] == "all"))
					operation_req_access += params["added_access"]
				else
					var/mob/living/living_user = usr
					var/obj/item/card/id/card = living_user.get_idcard(TRUE)
					operation_req_access += card.access
			if("del_req_access")
				if(!(mecha_flags & ADDING_ACCESS_POSSIBLE))
					return
				if(!(params["removed_access"] == "all"))
					operation_req_access -= params["removed_access"]
				else
					operation_req_access = list()
			if("lock_req_edit")
				mecha_flags &= ~ADDING_ACCESS_POSSIBLE
		return TRUE
	//usr is in occupants
	switch(action)
		if("changename")
			var/userinput = tgui_input_text(usr, "Choose a new exosuit name", "Rename exosuit", max_length = MAX_NAME_LEN, default = name)
			if(!userinput)
				return
			if(is_ic_filtered(userinput) || is_soft_ic_filtered(userinput))
				tgui_alert(usr, "You cannot set a name that contains a word prohibited in IC chat!")
				return
			if(userinput == format_text(name)) //default mecha names may have improper span artefacts in their name, so we format the name
				to_chat(usr, span_notice("You rename [name] to... well, [userinput]."))
				return
			name = userinput
			chassis_camera?.update_c_tag(src)
		if("toggle_safety")
			set_safety(usr)
			return
		if("dna_lock")
			var/mob/living/carbon/user = usr
			if(!istype(user) || !user.dna)
				to_chat(user, "[icon2html(src, occupants)][span_notice("You can't create a DNA lock with no DNA!.")]")
				return
			dna_lock = user.dna.unique_enzymes
			to_chat(user, "[icon2html(src, occupants)][span_notice("You feel a prick as the needle takes your DNA sample.")]")
		if("reset_dna")
			dna_lock = null
		if("view_dna")
			tgui_alert(usr, "Enzymes detected: " + dna_lock)
			return FALSE
		if("toggle_maintenance")
			if(construction_state)
				to_chat(occupants, "[icon2html(src, occupants)][span_danger("Maintenance protocols in effect")]")
				return
			mecha_flags ^= ADDING_MAINT_ACCESS_POSSIBLE
		if("toggle_id_panel")
			mecha_flags ^= ADDING_ACCESS_POSSIBLE
		if("repair_int_damage")
			ui.close() //if doing this you're likely want to watch for bad people so close the UI
			try_repair_int_damage(usr, params["flag"])
			return FALSE
		if("equip_act")
			var/obj/item/mecha_parts/mecha_equipment/gear = locate(params["ref"]) in flat_equipment
			return gear?.ui_act(params["gear_action"], params, ui, state)
	return TRUE

