/obj/structure/chem_separator
	name = "chemical separator"
	desc = "A device that performs chemical separation by distillation."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "separator"
	var/fill_icon = 'icons/obj/reagentfillings.dmi'
	var/fill_icon_state = "separator"
	var/list/fill_icon_thresholds = list(1,30,80)
	var/list/temperature_icon_thresholds = list(0,50,100)
	var/datum/looping_sound/generator/soundloop
	var/burning = FALSE
	var/req_temp = T0C + 100 // water boiling temperature
	var/heating_rate = 5 // degrees per second
	var/distillation_rate = 5 // units per second
	var/datum/reagent/separating_reagent
	var/obj/item/reagent_containers/beaker

/obj/structure/chem_separator/Initialize(mapload)
	create_reagents(200)
	. = ..()

/obj/structure/chem_separator/deconstruct(disassembled)
	. = ..()
	if(beaker && disassembled)
		beaker.forceMove(drop_location())
		beaker = null

/obj/structure/chem_separator/Destroy()
	if(burning)
		STOP_PROCESSING(SSobj, src)
	if(beaker)
		QDEL_NULL(beaker)
	return ..()

/obj/structure/chem_separator/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_appearance()

/obj/structure/chem_separator/update_overlays()
	. = ..()
	set_light(burning ? 1 : 0)
	// Burner overlay
	if(burning)
		. += mutable_appearance(icon, "[icon_state]_burn", alpha = alpha)
		. += emissive_appearance(icon, "[icon_state]_burn", src, alpha = alpha)
	// Separator reagents overlay
	if(reagents.total_volume)
		var/threshold = null
		for(var/i in 1 to fill_icon_thresholds.len)
			if(ROUND_UP(100 * reagents.total_volume / reagents.maximum_volume) >= fill_icon_thresholds[i])
				threshold = i
		if(threshold)
			var/fill_name = "[fill_icon_state]_m_[fill_icon_thresholds[threshold]]"
			var/mutable_appearance/filling = mutable_appearance(fill_icon, fill_name)
			filling.color = mix_color_from_reagents(reagents.reagent_list)
			. += filling
	// Beaker overlay
	if(beaker)
		. += "[icon_state]_beaker"
		// Beaker reagents overlay
		if(beaker.reagents.total_volume)
			var/threshold = null
			for(var/i in 1 to fill_icon_thresholds.len)
				if(ROUND_UP(100 * beaker.reagents.total_volume / beaker.reagents.maximum_volume) >= fill_icon_thresholds[i])
					threshold = i
			if(threshold)
				var/fill_name = "[fill_icon_state]_b_[fill_icon_thresholds[threshold]]"
				var/mutable_appearance/filling = mutable_appearance(fill_icon, fill_name)
				filling.color = mix_color_from_reagents(beaker.reagents.reagent_list)
				. += filling
	// Thermometer overlay
	var/threshold = null
	for(var/i in 1 to temperature_icon_thresholds.len)
		if(ROUND_UP(reagents.chem_temp - T0C) >= temperature_icon_thresholds[i])
			threshold = i
	if(threshold)
		var/fill_name = "[icon_state]_temp_[temperature_icon_thresholds[threshold]]"
		var/mutable_appearance/filling = mutable_appearance(icon_state, fill_name)
		. += filling

/obj/structure/chem_separator/proc/burn_attackby_check(obj/item/I, mob/living/user)
	var/ignition_message = I.ignition_effect(src, user)
	if(!ignition_message)
		return
	. = TRUE
	user.visible_message(ignition_message)
	fire_act(I.get_temperature())

/obj/structure/chem_separator/attackby(obj/item/I, mob/user, params)
	if(burn_attackby_check(I, user))
		return
	if(is_reagent_container(I) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/new_beaker = I
		if(!user.transferItemToLoc(new_beaker, src))
			return
		replace_beaker(user, new_beaker)
		to_chat(user, span_notice("You add [new_beaker] to [src]."))
		update_appearance()
		. = TRUE // no afterattack
	else
		return ..()

/obj/structure/chem_separator/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		if(burning)
			stop()
		if(!issilicon(user) && in_range(src, user))
			user.put_in_hands(beaker)
		else
			beaker.forceMove(drop_location())
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_appearance()
	return TRUE

/obj/structure/chem_separator/fire_act(exposed_temperature, exposed_volume)
	if(!burning)
		start()
		return
	. = ..()

/obj/structure/chem_separator/extinguish()
	if(burning)
		stop()
	. = ..()

/obj/structure/chem_separator/proc/start()
	if(!beaker)
		return
	if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	if(!reagents.total_volume)
		return
	separating_reagent = reagents.reagent_list[1].type
	burning = TRUE
	update_appearance()
	START_PROCESSING(SSobj, src)

/obj/structure/chem_separator/proc/stop()
	separating_reagent = null
	burning = FALSE
	update_appearance()
	STOP_PROCESSING(SSobj, src)

/obj/structure/chem_separator/proc/load()
	if(burning)
		return
	if(!beaker)
		return
	if(!beaker.reagents.total_volume)
		return
	if(reagents.total_volume >= reagents.maximum_volume)
		return
	beaker.reagents.trans_to(reagents, beaker.reagents.total_volume)
	update_appearance()

/obj/structure/chem_separator/proc/unload()
	if(burning)
		return
	if(!reagents.total_volume)
		return
	if(!beaker)
		return
	if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	reagents.trans_to(beaker.reagents, reagents.total_volume)
	update_appearance()

/obj/structure/chem_separator/process(delta_time)
	if(!burning)
		stop()
		return
	if(!beaker)
		stop()
		return
	if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		stop()
		return
	if(!reagents.get_reagent_amount(separating_reagent))
		stop()
		return
	if(isturf(loc))
		var/turf/location = loc
		location.hotspot_expose(exposed_temperature = 700, exposed_volume = 5)
	if(reagents.chem_temp < req_temp)
		reagents.adjust_thermal_energy(heating_rate * delta_time * SPECIFIC_HEAT_DEFAULT * reagents.total_volume)
		update_appearance()
		return
	if(reagents.chem_temp >= req_temp)
		var/transfer_amount = distillation_rate * delta_time
		reagents.trans_id_to(beaker.reagents, separating_reagent, transfer_amount)
	update_appearance()

/obj/structure/chem_separator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSeparator", name)
		ui.open()

/obj/structure/chem_separator/ui_data(mob/user)
	var/list/data = list()
	data["is_burning"] = burning
	data["temperature"] = reagents.chem_temp - T0C // Thermometer is in Celsius
	data["own_total_volume"] = reagents.total_volume
	data["own_maximum_volume"] = reagents.maximum_volume
	data["own_reagent_color"] = mix_color_from_reagents(reagents.reagent_list)
	data["beaker"] = !!beaker
	if(beaker)
		data["beaker_total_volume"] = beaker.reagents.total_volume
		data["beaker_maximum_volume"] = beaker.reagents.maximum_volume
		data["beaker_reagent_color"] = mix_color_from_reagents(beaker.reagents.reagent_list)
	return data

/obj/structure/chem_separator/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("load")
			load()
			. = TRUE
		if("unload")
			unload()
			. = TRUE
		if("start")
			start()
			. = TRUE
		if("stop")
			stop()
			. = TRUE
		if("eject")
			replace_beaker(usr)
			. = TRUE

/datum/crafting_recipe/chem_separator
	name = "Chemical separator"
	result = /obj/structure/chem_separator
	tool_behaviors = list(TOOL_WELDER)
	time = 5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/burner = 1,
		/obj/item/thermometer = 1,
	)
	category = CAT_CHEMISTRY
