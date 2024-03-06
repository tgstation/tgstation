/obj/machinery/xenoflora_pod_part
	name = "xenoflora pod shell"
	desc = "A part of a xenoflora pod shell. Combine four of these and you'll get a full pod."
	icon = 'icons/obj/xenobiology/machinery.dmi'
	icon_state = "xenoflora_pod"
	density = TRUE

/obj/machinery/xenoflora_pod_part/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/xenoflora_pod_part/pod_part in range(1, src))
		pod_part.attempt_assembly()

/obj/machinery/xenoflora_pod_part/proc/attempt_assembly()
	var/turf/first_turf = locate(x + 1, y, z)
	var/turf/second_turf = locate(x, y + 1, z)
	var/turf/third_turf = locate(x + 1, y + 1, z)

	var/obj/machinery/xenoflora_pod_part/first = locate(/obj/machinery/xenoflora_pod_part) in first_turf
	var/obj/machinery/xenoflora_pod_part/second = locate(/obj/machinery/xenoflora_pod_part) in second_turf
	var/obj/machinery/xenoflora_pod_part/third = locate(/obj/machinery/xenoflora_pod_part) in third_turf

	if(!first || !second || !third)
		return

	qdel(first)
	qdel(second)
	qdel(third)
	new /obj/machinery/atmospherics/components/binary/xenoflora_pod(get_turf(src))
	qdel(src)

// The pod itself

/obj/machinery/atmospherics/components/binary/xenoflora_pod
	name = "xenoflora pod"
	desc = "A large hydroponics tray with an extendable glass dome in case your green friends need special atmosphere."
	icon = 'icons/obj/xenobiology/xenoflora_pod.dmi'
	icon_state = "pod"
	base_icon_state = "pod"
	density = TRUE
	bound_width = 64
	bound_height = 64
	initialize_directions = SOUTH|WEST
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	vent_movement = NONE
	var/datum/gas_mixture/internal_gases
	var/datum/xenoflora_plant/plant
	var/dome_extended = TRUE

/obj/machinery/atmospherics/components/binary/xenoflora_pod/on_deconstruction()
	. = ..()
	var/turf/first_turf = locate(x + 1, y, z)
	var/turf/second_turf = locate(x, y + 1, z)
	var/turf/third_turf = locate(x + 1, y + 1, z)

	new /obj/machinery/xenoflora_pod_part(first_turf)
	new /obj/machinery/xenoflora_pod_part(second_turf)
	new /obj/machinery/xenoflora_pod_part(third_turf)

	name = initial(name)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/Initialize(mapload)
	. = ..()
	internal_gases = new
	create_reagents(XENOFLORA_MAX_CHEMS, TRANSPARENT | REFILLABLE)
	AddComponent(/datum/component/plumbing/xenoflora_pod, TRUE, SECOND_DUCT_LAYER)
	update_icon()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon_state]-open", "[base_icon_state]-unpowered", I))
			return
	if(default_change_direction_wrench(user, I)) //Updates connections, crucial for atmos shitcode to work
		return
	if(default_deconstruction_crowbar(I))
		return
	if(istype(I, /obj/item/xeno_seeds) && on && is_operational && !plant)
		var/obj/item/xeno_seeds/seeds = I
		plant = new seeds.plant_type(src)
		to_chat(user, span_notice("You plant [seeds] into [src]."))
		qdel(seeds)
	return ..()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	if(!plant || plant.stage < plant.max_stage || !plant.produce_type)
		return

	to_chat(user, span_notice("You harvest [plant]."))
	playsound(get_turf(src), plant.interaction_sound, 100, TRUE)
	plant.harvested(user)
	update_icon()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!plant)
		return

	to_chat(user, span_notice("You remove [plant] from [src]."))
	playsound(get_turf(src), plant.interaction_sound, 100, TRUE)
	qdel(plant)
	update_icon()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/atmospherics/components/binary/xenoflora_pod/default_change_direction_wrench(mob/user, obj/item/I) //Atmos shitcode be like
	set_init_directions()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null
	if(node2)
		if(src in node2.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node2.disconnect(src)
		nodes[2] = null

	if(parents[1])
		nullify_pipenet(parents[1])
	if(parents[2])
		nullify_pipenet(parents[2])

	atmos_init()
	node1 = nodes[1]
	if(node1)
		node1.atmos_init()
		node1.add_member(src)
	node2 = nodes[2]
	if(node2)
		node2.atmos_init()
		node2.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/process_atmos()
	update_icon()
	if(!on || !is_operational || !plant)
		return

	inject_gases()
	plant.Life()
	if(!dome_extended)
		spread_gases() //Don't forget to extend the dome when working with plants that require special atmos!
	dump_gases()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/inject_gases()
	if(internal_gases.return_volume() >= XENOFLORA_MAX_MOLES)
		return

	var/datum/gas_mixture/input_gases = airs[2]
	for(var/gas_type in plant.required_gases)
		if(!input_gases.gases[gas_type] || !input_gases.gases[gas_type][MOLES])
			continue

		var/pump_amount = min(input_gases.gases[gas_type][MOLES], XENOFLORA_MAX_MOLES - internal_gases.return_volume())
		if(internal_gases.gases[gas_type] && internal_gases.gases[gas_type][MOLES])
			pump_amount = min(pump_amount, plant.required_gases[gas_type] * XENOFLORA_POD_INPUT_MULTIPLIER - internal_gases.gases[gas_type][MOLES])
		internal_gases.merge(input_gases.remove_specific(gas_type, max(0, pump_amount)))

/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/spread_gases()
	var/datum/gas_mixture/expelled_gas = internal_gases.remove(internal_gases.total_moles())
	var/turf/turf = get_turf(src)
	turf.assume_air(expelled_gas)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/dump_gases()
	var/datum/gas_mixture/output_gases = airs[1]
	if(plant)
		for(var/gas_type in internal_gases.gases)
			if((gas_type in plant.required_gases) || !internal_gases.gases[gas_type][MOLES])
				continue

			output_gases.merge(internal_gases.remove_specific(gas_type, internal_gases.gases[gas_type][MOLES]))
	else
		output_gases.merge(internal_gases.remove(internal_gases.return_volume()))

	internal_gases.garbage_collect()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[base_icon_state]-open"
	else if(on && is_operational)
		icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]-unpowered"

/obj/machinery/atmospherics/components/binary/xenoflora_pod/update_overlays()
	. = ..()
	cut_overlays()

	if(dome_extended)
		var/mutable_appearance/dome_behind = mutable_appearance(icon, "glass_behind", layer = ABOVE_ALL_MOB_LAYER + 0.1, plane = ABOVE_GAME_PLANE)
		var/mutable_appearance/dome_front = mutable_appearance(icon, "glass_front", layer = ABOVE_ALL_MOB_LAYER + 0.3, plane = ABOVE_GAME_PLANE)
		. += dome_front
		. += dome_behind

	var/mutable_appearance/pipe_appearance1 = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_2_[piping_layer]", layer = GAS_SCRUBBER_LAYER)
	pipe_appearance1.color = COLOR_LIME

	var/mutable_appearance/pipe_appearance2 = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_8_[piping_layer]", layer = GAS_SCRUBBER_LAYER)
	pipe_appearance2.color = COLOR_MOSTLY_PURE_RED

	. += pipe_appearance1
	. += pipe_appearance2
	if(plant)
		var/mutable_appearance/ground_overlay = mutable_appearance(plant.icon, "[plant.ground_icon_state]", layer = ABOVE_ALL_MOB_LAYER + 0.15, plane = ABOVE_GAME_PLANE)
		var/mutable_appearance/plant_overlay = mutable_appearance(plant.icon, "[plant.icon_state]-[plant.stage]", layer = ABOVE_ALL_MOB_LAYER + 0.2, plane = ABOVE_GAME_PLANE)
		. += ground_overlay
		. += plant_overlay
		if(on)
			var/mutable_appearance/screen_overlay = mutable_appearance(icon, (internal_gases.return_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70) ? "pod-screen-fire" : "pod-screen", layer = ABOVE_ALL_MOB_LAYER + 0.1, plane = ABOVE_GAME_PLANE)
			. += screen_overlay

	if(internal_gases.return_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70 && dome_extended)
		var/mutable_appearance/fire_overlay = mutable_appearance(icon, "fire", layer = ABOVE_ALL_MOB_LAYER + 0.25, plane = ABOVE_GAME_PLANE)
		. += fire_overlay


/obj/machinery/atmospherics/components/binary/xenoflora_pod/set_init_directions()
	initialize_directions = SOUTH|WEST

/obj/machinery/atmospherics/components/binary/xenoflora_pod/get_node_connects()
	return list(WEST, SOUTH)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
		if("dome")
			if(on && is_operational)
				dome_extended = !dome_extended
				playsound(get_turf(src), 'sound/mecha/mechmove03.ogg', 100, TRUE)
				update_icon()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/ui_data()
	var/data = list()
	data["on"] = on
	data["dome"] = dome_extended
	data["plant_name"] = ""
	data["plant_desc"] = ""

	data["health"] = 0
	data["progress"] = 0
	data["total_progress"] = 0

	var/list/required_gases = list()
	var/list/required_chems = list()
	var/total_required_gases = 0
	var/total_required_chems = 0

	var/list/produced_gases = list()
	var/list/produced_chems = list()
	var/total_produced_gases = 0
	var/total_produced_chems = 0

	var/additional_bars = 0

	if(plant)
		data["plant_name"] = plant.name
		data["plant_desc"] = plant.desc

		data["health"] = round(plant.health / plant.max_health * 100, 0.1)
		data["progress"] = round(plant.progress / plant.max_progress * 100, 0.1)
		data["total_progress"] = round((plant.progress / plant.max_progress + (plant.stage - 1)) * 100 / plant.max_stage, 0.1)

		data["safe_temp"] = "Safe temperature: [plant.min_safe_temp] °C to [plant.max_safe_temp] °C"

		if(LAZYLEN(plant.required_gases))
			for(var/gas_type in plant.required_gases)
				var/datum/gas/req_gas = gas_type
				required_gases.Add(list(list(
				"name"= initial(req_gas.name),
				"amount" = plant.required_gases[gas_type] SECONDS,
				)))
				total_required_gases += required_gases[gas_type] SECONDS
				additional_bars += 1

		if(LAZYLEN(plant.required_chems))
			for(var/chem_type in plant.required_chems)
				var/datum/reagent/chem = chem_type
				required_chems.Add(list(list(
				"name"= initial(chem.name),
				"amount" = plant.required_chems[chem_type] SECONDS,
				"color" = chem.color,
				)))
				total_required_chems += required_chems[chem_type] SECONDS
				additional_bars += 1

		if(LAZYLEN(plant.produced_gases))
			for(var/gas_type in plant.produced_gases)
				var/datum/gas/prod_gas = gas_type
				produced_gases.Add(list(list(
				"name"= initial(prod_gas.name),
				"amount" = plant.produced_gases[gas_type] SECONDS,
				)))
				total_produced_gases += required_gases[gas_type] SECONDS
				additional_bars += 1

		if(LAZYLEN(plant.produced_chems))
			for(var/chem_type in plant.produced_chems)
				var/datum/reagent/chem = chem_type
				produced_chems.Add(list(list(
				"name"= initial(chem.name),
				"amount" = plant.produced_chems[chem_type] SECONDS,
				"color" = chem.color,
				)))
				total_produced_chems += required_chems[chem_type] SECONDS
				additional_bars += 1

	data["required_gases"] = required_gases
	data["required_chems"] = required_chems
	data["total_required_gases"] = total_required_gases
	data["total_required_chems"] = total_required_chems

	data["produced_gases"] = produced_gases
	data["produced_chems"] = produced_chems
	data["total_produced_gases"] = total_produced_gases
	data["total_produced_chems"] = total_produced_chems

	var/list/internal_gas_data = list()
	if(internal_gases.total_moles())
		data["temperature"] = internal_gases.return_temperature()
		for(var/gas_id in internal_gases.gases)
			internal_gas_data.Add(list(list(
			"name"= internal_gases.gases[gas_id][GAS_META][META_GAS_NAME],
			"amount" = round(internal_gases.gases[gas_id][MOLES], 0.01),
			)))
			additional_bars += 1
	else
		data["temperature"] = 0

	data["internal_gas_data"] = internal_gas_data

	var/list/chemical_data = list()
	if(reagents.total_volume)
		data["chem_volume"] = reagents.total_volume
		data["chem_temperature"] = reagents.chem_temp
		var/list/cached_reagents = reagents.reagent_list
		for(var/datum/reagent/cached_reagent as anything in cached_reagents)
			chemical_data.Add(list(list(
			"name"= cached_reagent.name,
			"color"= cached_reagent.color,
			"amount" = round(cached_reagent.volume, 0.01),
			)))
			additional_bars += 1
	else
		data["chem_volume"] = 0
		data["chem_temperature"] = 0
	data["chemical_data"] = chemical_data

	data["total_gases"] = internal_gases.total_moles()
	data["total_chems"] = reagents.total_volume
	data["additional_bars"] = additional_bars

	return data

/obj/machinery/atmospherics/components/binary/xenoflora_pod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenofloraPod", name)
		ui.open()
