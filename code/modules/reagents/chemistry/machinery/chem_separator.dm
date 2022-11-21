/obj/structure/chem_separator
	name = "chemical separator"
	desc = "A device that performs chemical separation by distillation."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "separator"
	light_power = 1
	var/fill_icon = 'icons/obj/reagentfillings.dmi'
	var/fill_icon_state = "separator"
	var/list/fill_icon_thresholds = list(1,30,80)
	var/list/temperature_icon_thresholds = list(0,50,100)
	var/burning = FALSE
	/// Minimal mixture temperature for separation
	var/required_temp = T0C + 100
	/// Mixture heating speed in degrees per second
	var/heating_rate = 5
	/// Separation speed in units per second
	var/distillation_rate = 5
	var/datum/reagent/separating_reagent
	var/obj/item/reagent_containers/beaker

/obj/structure/chem_separator/Initialize(mapload)
	. = ..()
	create_reagents(200)

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
		update_appearance(UPDATE_ICON)

/obj/structure/chem_separator/update_overlays()
	. = ..()
	set_light(burning ? light_power : 0)
	// Burner overlay
	if(burning)
		. += mutable_appearance(icon, "[icon_state]_burn")
		. += emissive_appearance(icon, "[icon_state]_burn", src)
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

/// Checks whether the item can ignite the separator
/obj/structure/chem_separator/proc/ignite_with(obj/item/object, mob/living/user)
	var/ignition_message = object.ignition_effect(src, user)
	if(!ignition_message)
		return FALSE
	user.visible_message(ignition_message)
	fire_act(object.get_temperature())
	return TRUE

/obj/structure/chem_separator/attackby(obj/item/item, mob/user, params)
	if(ignite_with(item, user))
		return TRUE // no afterattack
	if(is_reagent_container(item) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		var/obj/item/reagent_containers/new_beaker = item
		if(!user.transferItemToLoc(new_beaker, src))
			return FALSE
		replace_beaker(user, new_beaker)
		balloon_alert(user, "added beaker")
		update_appearance(UPDATE_ICON)
		return TRUE // no afterattack
	return ..()

/// Insert, replace or eject the container depending on the state and parameters
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
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/chem_separator/fire_act(exposed_temperature, exposed_volume)
	if(!burning)
		start()
		return
	return ..()

/obj/structure/chem_separator/extinguish()
	if(burning)
		stop()
	return ..()

/// Ignite the burner to start the separation process
/obj/structure/chem_separator/proc/start()
	if(!beaker)
		return
	if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	if(!reagents.total_volume)
		return
	separating_reagent = reagents.reagent_list[1].type
	burning = TRUE
	update_appearance(UPDATE_ICON)
	START_PROCESSING(SSobj, src)

/// Extinguish the burner to stop the separation process
/obj/structure/chem_separator/proc/stop()
	separating_reagent = null
	burning = FALSE
	update_appearance(UPDATE_ICON)
	STOP_PROCESSING(SSobj, src)

/// Fill internal storage with reagents from the container
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
	update_appearance(UPDATE_ICON)

/// Drain internal reagents into the container
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
	update_appearance(UPDATE_ICON)

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
	if(reagents.chem_temp < required_temp)
		reagents.adjust_thermal_energy(heating_rate * delta_time * SPECIFIC_HEAT_DEFAULT * reagents.total_volume)
		update_appearance(UPDATE_ICON)
		return
	if(reagents.chem_temp >= required_temp)
		var/transfer_amount = distillation_rate * delta_time
		reagents.trans_id_to(beaker.reagents, separating_reagent, transfer_amount)
	update_appearance(UPDATE_ICON)

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
		return TRUE
	switch(action)
		if("load")
			load()
		if("unload")
			unload()
		if("start")
			start()
		if("stop")
			stop()
		if("eject")
			replace_beaker(usr)
	return TRUE

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
