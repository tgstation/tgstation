/obj/structure/chem_separator
	name = "chemical separator"
	desc = "A device that performs chemical separation by distillation."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "separator"
	var/burning = FALSE
	var/req_temp = T0C + 100 // water boiling temperature
	var/heating_rate = 5 // degrees per second
	var/distillation_rate = 5 // units per second
	var/datum/reagent/separating_reagent
	var/obj/item/reagent_containers/beaker

/obj/structure/chem_separator/Initialize(mapload)
	create_reagents(100)
	. = ..()

/obj/structure/chem_separator/Destroy()
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
	if(beaker)
		. += "[icon_state]_beaker"
	if(burning)
		. += mutable_appearance(icon, "[icon_state]_burn", alpha = alpha)
		. += emissive_appearance(icon, "[icon_state]_burn", src, alpha = alpha)

/obj/structure/chem_separator/attackby(obj/item/I, mob/user, params)
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

/obj/structure/chem_separator/process(delta_time)
	if(!burning)
		stop()
		return
	if(!beaker)
		stop()
		return
	var/datum/reagents/beaker_reagents = beaker.reagents
	if(beaker_reagents.total_volume >= beaker_reagents.maximum_volume)
		stop()
		return
	var/datum/reagents/own_reagents = reagents
	var/amount_available = own_reagents.get_reagent_amount(separating_reagent)
	if(!amount_available)
		stop()
		return
	if(isturf(loc))
		var/turf/location = loc
		location.hotspot_expose(exposed_temperature = 700, exposed_volume = 5)
	if(own_reagents.chem_temp < req_temp)
		own_reagents.chem_temp += heating_rate * delta_time // TODO: heat capacity factor
		return
	if(reagents.chem_temp >= req_temp)
		var/transfer_amount = distillation_rate * delta_time
		own_reagents.trans_id_to(beaker_reagents, separating_reagent, transfer_amount)
		// TODO: delete if needed

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
	update_appearance()

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
