#define ENABLE_FLASHING -1

/obj/machinery/chem_heater
	name = "reaction chamber" //Maybe this name is more accurate?
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_heater

	var/obj/item/reagent_containers/beaker = null
	var/target_temperature = 300
	var/heater_coefficient = 0.05
	var/on = FALSE
	var/dispense_volume = 1

/obj/machinery/chem_heater/Initialize()
	. = ..()
	create_reagents(100, NO_REACT)//Lets save some calculations here
	reagents.add_reagent(/datum/reagent/reaction_agent/basic_buffer, 20)
	reagents.add_reagent(/datum/reagent/reaction_agent/acidic_buffer, 20)
	
/obj/machinery/chem_heater/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_heater/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/chem_heater/update_icon_state()
	if(beaker)
		icon_state = "mixer1b"
	else
		icon_state = "mixer0b"

/obj/machinery/chem_heater/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)

/obj/machinery/chem_heater/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_icon()
	return TRUE

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = 0.1
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Heating reagents at <b>[heater_coefficient*1000]%</b> speed.</span>"

/obj/machinery/chem_heater/process(delta_time)
	..()
	if(machine_stat & NOPOWER)
		return
	if(on)
		if(beaker?.reagents.total_volume)
			//keep constant with the chemical acclimator please
			beaker.reagents.adjust_thermal_energy((target_temperature - beaker.reagents.chem_temp) * heater_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
			beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
		return

	if(beaker)
		if(istype(I, /obj/item/reagent_containers/dropper))
			var/obj/item/reagent_containers/dropper/D = I
			D.afterattack(beaker, user, 1)
			return
		if(istype(I, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/S = I
			S.afterattack(beaker, user, 1)
			return
	
	return ..()

/obj/machinery/chem_heater/on_deconstruction()
	replace_beaker()
	return ..()

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater", name)
		ui.open()

/obj/machinery/chem_heater/ui_data()
	var/data = list()
	data["targetTemp"] = target_temperature
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? round(beaker.reagents.total_volume, 0.01) : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["currentpH"] = beaker ? round(beaker.reagents.ph, 0.01)  : null
	var/upgrade_level = heater_coefficient*10
	data["upgradeLevel"] = upgrade_level

	var/list/beaker_contents = list()
	for(var/r in beaker?.reagents.reagent_list)
		var/datum/reagent/reagent = r
		beaker_contents.len++
		beaker_contents[length(beaker_contents)] = list("name" = reagent.name, "volume" = round(reagent.volume, 0.01))
	data["beakerContents"] = beaker_contents

	var/list/active_reactions = list()
	var/flashing = 14 //for use with alertAfter - since there is no alertBefore, I set the after to 0 if true, or to the max value if false
	for(var/_reaction in beaker?.reagents.reaction_list)
		var/datum/equilibrium/equilibrium = _reaction
		if(!length(beaker.reagents.reaction_list))//I'm not sure why when it explodes it causes the gui to fail (it's missing danger (?) )
			stack_trace("how is this happening??")
			continue
		if(!equilibrium.reaction.results)//Incase of no result reactions
			continue
		var/_reagent = equilibrium.reaction.results[1]
		var/datum/reagent/reagent = beaker?.reagents.get_reagent(_reagent) //Reactions are named after their primary products
		if(!reagent)
			continue
		active_reactions.len++
		var/danger = FALSE
		var/purity_alert = 2 //same as flashing
		if(reagent.purity < equilibrium.reaction.purity_min)
			purity_alert = ENABLE_FLASHING//Because 0 is seen as null
			danger = TRUE
		if(!(flashing == ENABLE_FLASHING) && (upgrade_level > 1))//So that the pH meter flashes for ANY reactions out of optimal
			if(equilibrium.reaction.optimal_ph_min > beaker?.reagents.ph || equilibrium.reaction.optimal_ph_max < beaker?.reagents.ph)
				flashing = ENABLE_FLASHING			
		if(equilibrium.reaction.overheat_temp < beaker?.reagents.chem_temp)
			danger = TRUE
		active_reactions[length(active_reactions)] = list("name" = reagent.name, "danger" = danger, "purityAlert" = purity_alert, "quality" = equilibrium.reaction_quality, "overheat" = equilibrium.reaction.overheat_temp, "inverse" = reagent.inverse_chem_val, "minPure" = equilibrium.reaction.purity_min, "reactedVol" = equilibrium.reacted_vol, "targetVol" = round(equilibrium.target_vol, 1))//Use the first result reagent to name the reaction detected
	data["activeReactions"] = active_reactions
	data["isFlashing"] = flashing

	data["acidicBufferVol"] = reagents.get_reagent_amount(/datum/reagent/reaction_agent/acidic_buffer)
	data["basicBufferVol"] = reagents.get_reagent_amount(/datum/reagent/reaction_agent/basic_buffer)
	data["dispenseVolume"] = dispense_volume

	return data

/obj/machinery/chem_heater/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			. = TRUE
		if("temperature")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, 0, 1000)
		if("eject")
			//Eject doesn't turn it off, so you can preheat for beaker swapping
			replace_beaker(usr)
			. = TRUE
		if("acidBuffer")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				move_buffer("acid", target)
		if("basicBuffer")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target) //Because the input is flipped
				. = TRUE
			if(.)
				move_buffer("basic", target)
		if("disp_vol")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target) //Because the input is flipped
				. = TRUE
			if(.)
				dispense_volume = target



///Moves a type of buffer from the heater to the beaker, or vice versa
/obj/machinery/chem_heater/proc/move_buffer(buffer_type, volume)
	if(!beaker)
		say("No beaker found!")
		return
	if(buffer_type == "acid")
		if(volume < 0)
			var/datum/reagent/acid_reagent = beaker.reagents.get_reagent(/datum/reagent/reaction_agent/acidic_buffer)
			if(!acid_reagent)
				say("Unable to find acidic buffer in beaker to draw from! Please insert a beaker containing acidic buffer.")
				return
			var/datum/reagent/acid_reagent_heater = reagents.get_reagent(/datum/reagent/reaction_agent/acidic_buffer)
			volume = 50 - acid_reagent_heater.volume 
			beaker.reagents.trans_id_to(src, acid_reagent.type, volume)//negative because we're going backwards
			return
		//We must be positive here
		reagents.trans_id_to(beaker, /datum/reagent/reaction_agent/acidic_buffer, dispense_volume)
		return

	if(buffer_type == "basic")
		if(volume < 0)
			var/datum/reagent/basic_reagent = beaker.reagents.get_reagent(/datum/reagent/reaction_agent/basic_buffer)
			if(!basic_reagent)
				say("Unable to find basic buffer in beaker to draw from! Please insert a beaker containing basic buffer.")
				return
			var/datum/reagent/basic_reagent_heater = reagents.get_reagent(/datum/reagent/reaction_agent/basic_buffer)
			volume = 50 - basic_reagent_heater.volume 
			beaker.reagents.trans_id_to(src, basic_reagent.type, volume)//negative because we're going backwards
			return
		reagents.trans_id_to(beaker, /datum/reagent/reaction_agent/basic_buffer, dispense_volume)
		return


/obj/machinery/chem_heater/proc/get_purity_color(datum/equilibrium/equilibrium)
	var/_reagent = equilibrium.reaction.results[1]
	var/datum/reagent/reagent = equilibrium.holder.get_reagent(_reagent)
	switch(reagent.purity)
		if(1 to INFINITY)
			return "blue"
		if(0.8 to 1)
			return "green"
		if(reagent.inverse_chem_val to 0.8)
			return "olive"
		if(equilibrium.reaction.purity_min to reagent.inverse_chem_val)
			return "orange"
		if(-INFINITY to equilibrium.reaction.purity_min)
			return "red"

//Has a lot of buffer and is upgraded
/obj/machinery/chem_heater/debug
	name = "Debug Reaction Chamber"
	desc = "Now with even more buffers!"

/obj/machinery/chem_heater/debug/Initialize()
	. = ..()
	reagents.maximum_volume = 2000
	reagents.add_reagent(/datum/reagent/reaction_agent/basic_buffer, 980)
	reagents.add_reagent(/datum/reagent/reaction_agent/acidic_buffer, 980)
	heater_coefficient = 0.4 //hack way to upgrade
