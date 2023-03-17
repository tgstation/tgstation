/obj/vehicle/sealed/mecha/ui_close(mob/user)
	. = ..()
	ui_view.hide_from(user)

/obj/vehicle/sealed/mecha/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name, ui_x, ui_y)
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
	return list(get_asset_datum(/datum/asset/spritesheet/mechaarmor))

/obj/vehicle/sealed/mecha/ui_static_data(mob/user)
	var/list/data = list()
	data["cabin_dangerous_highpressure"] = WARNING_HIGH_PRESSURE
	data["mineral_material_amount"] = MINERAL_MATERIAL_AMOUNT
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
	data["mech_electronics"] = list(
		"minfreq" = MIN_FREE_FREQ,
		"maxfreq" = MAX_FREE_FREQ,
	)
	return data

/obj/vehicle/sealed/mecha/ui_data(mob/user)
	var/list/data = list()
	var/isoperator = (user in occupants) //maintenance mode outside of mech
	data["isoperator"] = isoperator
	if(!isoperator)
		data["name"] = name
		data["mecha_flags"] = mecha_flags
		data["internal_tank_valve"] = internal_tank_valve
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
	var/datum/gas_mixture/int_tank_air = internal_tank?.return_air()
	data["name"] = name
	data["integrity"] = atom_integrity/max_integrity
	data["power_level"] = cell?.charge
	data["power_max"] = cell?.maxcharge
	data["mecha_flags"] = mecha_flags
	data["internal_damage"] = internal_damage
	data["airtank_present"] = !!internal_tank
	data["air_source"] = use_internal_tank ? "Internal Airtank" : "Environment"
	data["airtank_pressure"] = int_tank_air ? round(int_tank_air.return_pressure(), 0.01) : null
	data["airtank_temp"] = int_tank_air?.temperature
	data["port_connected"] = internal_tank?.connected_port ? TRUE : FALSE
	data["cabin_pressure"] = round(return_pressure(), 0.01)
	data["cabin_temp"] = return_temperature()
	data["dna_lock"] = dna_lock
	data["weapons_safety"] = weapons_safety
	data["mech_view"] = ui_view.assigned_map
	if(radio)
		data["mech_electronics"] = list(
			"microphone" = radio.get_broadcasting(),
			"speaker" = radio.get_listening(),
			"frequency" = radio.get_frequency(),
		)
	if(equip_by_category[MECHA_L_ARM])
		var/obj/item/mecha_parts/mecha_equipment/l_gun = equip_by_category[MECHA_L_ARM]
		var/isballisticweapon = istype(l_gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic)
		data["left_arm_weapon"] = list(
			"name" = l_gun.name,
			"desc" = l_gun.desc,
			"ref" = REF(l_gun),
			"integrity" = (l_gun.get_integrity()/l_gun.max_integrity),
			"isballisticweapon" = isballisticweapon,
			"energy_per_use" = l_gun.energy_drain,
			"snowflake" = l_gun.get_snowflake_data(),
		)
		if(isballisticweapon)
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/weapon = l_gun
			data["left_arm_weapon"] += list(
				"projectiles" = weapon.projectiles,
				"max_magazine" = initial(weapon.projectiles),
				"projectiles_cache" = weapon.projectiles_cache,
				"projectiles_cache_max" = weapon.projectiles_cache_max,
				"disabledreload" = weapon.disabledreload,
				"ammo_type" = weapon.ammo_type,
			)
	if(equip_by_category[MECHA_R_ARM])
		var/obj/item/mecha_parts/mecha_equipment/r_gun = equip_by_category[MECHA_R_ARM]
		var/isballisticweapon = istype(r_gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic)
		data["right_arm_weapon"] = list(
			"name" = r_gun.name,
			"desc" = r_gun.desc,
			"ref" = REF(r_gun),
			"integrity" = (r_gun.get_integrity()/r_gun.max_integrity),
			"isballisticweapon" = isballisticweapon,
			"energy_per_use" = r_gun.energy_drain,
			"snowflake" = r_gun.get_snowflake_data(),
		)
		if(isballisticweapon)
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/weapon = r_gun
			data["right_arm_weapon"] += list(
				"projectiles" = weapon.projectiles,
				"max_magazine" = initial(weapon.projectiles),
				"projectiles_cache" = weapon.projectiles_cache,
				"projectiles_cache_max" = weapon.projectiles_cache_max,
				"disabledreload" = weapon.disabledreload,
				"ammo_type" = weapon.ammo_type,
			)
	data["mech_equipment"] = list("utility" = list(), "power" = list(), "armor" = list())
	for(var/obj/item/mecha_parts/mecha_equipment/utility as anything in equip_by_category[MECHA_UTILITY])
		data["mech_equipment"]["utility"] += list(list(
			"name" = utility.name,
			"activated" = utility.activated,
			"snowflake" = utility.get_snowflake_data(),
			"ref" = REF(utility),
		))
	for(var/obj/item/mecha_parts/mecha_equipment/power as anything in equip_by_category[MECHA_POWER])
		data["mech_equipment"]["power"] += list(list(
			"name" = power.name,
			"activated" = power.activated,
			"snowflake" = power.get_snowflake_data(),
			"ref" = REF(power),
		))
	for(var/obj/item/mecha_parts/mecha_equipment/armor/armor as anything in equip_by_category[MECHA_ARMOR])
		data["mech_equipment"]["armor"] += list(list(
			"protect_name" = armor.protect_name,
			"iconstate_name" = armor.iconstate_name,
			"ref" = REF(armor),
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
				cell.forceMove(get_turf(src))
				cell = null
			if("drop_scanning")
				if(construction_state == MECHA_OPEN_HATCH)
					return
				scanmod.forceMove(get_turf(src))
				scanmod = null
			if("drop_capacitor")
				if(construction_state == MECHA_OPEN_HATCH)
					return
				capacitor.forceMove(get_turf(src))
				capacitor = null
			if("set_pressure")
				var/new_pressure = tgui_input_number(usr, "Enter new pressure", "Cabin pressure change", internal_tank_valve)
				if(isnull(new_pressure) || !construction_state)
					return
				internal_tank_valve = new_pressure
				to_chat(usr, span_notice("The internal pressure valve has been set to [internal_tank_valve]kPa."))
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
			var/userinput = tgui_input_text(usr, "Choose a new exosuit name", "Rename exosuit", max_length = MAX_NAME_LEN)
			if(!userinput)
				return
			if(is_ic_filtered(userinput) || is_soft_ic_filtered(userinput))
				tgui_alert(usr, "You cannot set a name that contains a word prohibited in IC chat!")
				return
			if(userinput == format_text(name)) //default mecha names may have improper span artefacts in their name, so we format the name
				to_chat(usr, span_notice("You rename [name] to... well, [userinput]."))
				return
			name = userinput
			chassis_camera.update_c_tag(src)
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
		if("toggle_airsource")
			if(!internal_tank)
				return
			use_internal_tank = !use_internal_tank
			balloon_alert(usr, "taking air from [use_internal_tank ? "internal airtank" : "environment"]")
			log_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].", LOG_MECHA)
		if("toggle_port")
			if(internal_tank.connected_port)
				if(internal_tank.disconnect())
					to_chat(occupants, "[icon2html(src, occupants)][span_notice("Disconnected from the air system port.")]")
					log_message("Disconnected from gas port.", LOG_MECHA)
					return TRUE
				to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to disconnect from the air system port!")]")
				return
			var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate() in loc
			if(internal_tank.connect(possible_port))
				to_chat(occupants, "[icon2html(src, occupants)][span_notice("Connected to the air system port.")]")
				log_message("Connected to gas port.", LOG_MECHA)
				return TRUE
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to connect with air system port!")]")
		if("toggle_maintenance")
			if(construction_state)
				to_chat(occupants, "[icon2html(src, occupants)][span_danger("Maintenance protocols in effect")]")
				return
			mecha_flags ^= ADDING_MAINT_ACCESS_POSSIBLE
		if("toggle_id_panel")
			mecha_flags ^= ADDING_ACCESS_POSSIBLE
		if("toggle_microphone")
			radio.set_broadcasting(!radio.get_broadcasting())
		if("toggle_speaker")
			radio.set_listening(!radio.get_listening())
		if("set_frequency")
			radio.set_frequency(sanitize_frequency(params["new_frequency"], radio.freerange, radio.syndie))
		if("repair_int_damage")
			ui.close() //if doing this you're likely want to watch for bad people so close the UI
			try_repair_int_damage(usr, params["flag"])
			return FALSE
		if("equip_act")
			var/obj/item/mecha_parts/mecha_equipment/gear = locate(params["ref"]) in flat_equipment
			return gear?.ui_act(params["gear_action"], params, ui, state)
	return TRUE
