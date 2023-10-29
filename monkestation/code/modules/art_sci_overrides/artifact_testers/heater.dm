/obj/machinery/atmospherics/components/unary/artifact_heatingpad
	icon = 'goon/icons/obj/networked.dmi'
	icon_state = "pad_norm"

	name = "Heating Pad"
	desc = "Through some science bullcrap, this machine heats artifacts and people on top of it, without heating air, to the temperature of the gas contained. It will, in addition, heat its contents to 20C."
	density = FALSE
	max_integrity = 300
	armor_type = /datum/armor/unary_thermomachine
	layer = LOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/artifactheater
	hide = TRUE
	move_resist = MOVE_RESIST_DEFAULT
	vent_movement = NONE
	pipe_flags = PIPING_ONE_PER_TURF
	set_dir_on_move = FALSE

	var/heat_capacity = 0

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/Initialize(mapload)
	. = ..()
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/update_icon_state()
	var/datum/gas_mixture/port = airs[1]
	if(!port?.total_moles())
		icon_state = "pad_norm"
		return ..()
	var/state_to_use = ""
	switch(port.temperature)
		if(BODYTEMP_HEAT_WARNING_1 to INFINITY)
			state_to_use = "pad_on" // MONKESTATION EDIT ART_SCI_OVERRIDE
		if(-INFINITY to BODYTEMP_COLD_WARNING_1)
			state_to_use = "pad_on" // MONKESTATION EDIT ART_SCI_OVERRIDE
		else
			state_to_use = "pad_norm"

	if(panel_open)
		icon_state = "pad_open"
		return ..()
	icon_state = state_to_use
	return ..()

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/update_overlays()
	. = ..()
	if(!initial(icon))
		return
	var/mutable_appearance/pipe = new('icons/obj/machines/atmospherics/heatingpad.dmi')
	. += get_pipe_image(pipe, "pipe", dir, COLOR_LIME, piping_layer)

	// MONKESTATION EDIT START ART_SCI_OVERRIDE
	var/datum/gas_mixture/port = airs[1]
	if(!port?.total_moles())
		return
	switch(port.temperature)
		if(BODYTEMP_HEAT_WARNING_1 to INFINITY)
			. += emissive_appearance(icon, "heat+3", src)
			. += mutable_appearance(icon, "heat+3", src)
		if(-INFINITY to BODYTEMP_COLD_WARNING_1)
			. += emissive_appearance(icon, "heat-3", src)
			. += mutable_appearance(icon, "heat-3", src)
			
	// MONKESTATION EDIT END ART_SCI_OVERRIDE

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/RefreshParts()
	. = ..()
	var/calculated_bin_rating = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.tier
	heat_capacity = 5000 * ((calculated_bin_rating - 1) ** 2) //pointless but uhh yeah

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/process_atmos()
	if(panel_open)
		return
	var/turf/turf = get_turf(src)
	var/datum/gas_mixture/port = airs[1]
	if(!is_operational || !turf)
		return
	if(!port.total_moles())
		return

	var/port_capacity = port.heat_capacity()
	var/delta = T20C - port.temperature //i dont think objs have temperature so
	var/heat_amount = CALCULATE_CONDUCTION_ENERGY(delta, port_capacity, heat_capacity)
	port.temperature = max(((port.temperature * port_capacity) + heat_amount) / port_capacity, TCMB)

	for(var/atom/movable/content in turf.contents)
		if(isliving(content)) // this so so will backfire but they can just walk off
			var/mob/living/victim = content
			if(victim.bodytemperature < port.temperature)
				victim.adjust_bodytemperature(port.temperature * TEMPERATURE_DAMAGE_COEFFICIENT)
			continue
		else if(content in GLOB.running_artifact_list) //this is an artifact, probably!
			var/datum/component/artifact/pulled_artifact = GLOB.running_artifact_list[content]
			if(!istype(pulled_artifact))
				return
			pulled_artifact.process_stimuli(STIMULUS_HEAT, port.temperature) //if its in the artifacts list it should have the component and if it doesnt shit is fuck
	update_appearance()

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "pad_open", "pad_norm", tool))
		change_pipe_connection(panel_open)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = TOOL_ACT_TOOLTYPE_SUCCESS
	if(!panel_open)
		balloon_alert(user, "open panel!")
		return
	piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
	update_appearance()

/obj/machinery/atmospherics/components/unary/artifact_heatingpad/default_change_direction_wrench(mob/user, obj/item/item)
	if(!..())
		return FALSE
	set_init_directions()
	update_appearance()
	return TRUE
