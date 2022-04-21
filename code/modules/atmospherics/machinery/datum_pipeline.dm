/datum/pipeline
	var/datum/gas_mixture/air
	var/list/datum/gas_mixture/other_airs

	var/list/obj/machinery/atmospherics/pipe/members
	var/list/obj/machinery/atmospherics/components/other_atmos_machines

	///Should we equalize air amoung all our members?
	var/update = TRUE
	///Is this pipeline being reconstructed?
	var/building = FALSE

/datum/pipeline/New()
	other_airs = list()
	members = list()
	other_atmos_machines = list()
	SSairmachines.networks += src

/datum/pipeline/Destroy()
	SSairmachines.networks -= src
	if(building)
		SSairmachines.remove_from_expansion(src)
	if(air?.volume)
		temporarily_store_air()
	for(var/obj/machinery/atmospherics/pipe/considered_pipe in members)
		considered_pipe.parent = null
		if(QDELETED(considered_pipe))
			continue
		SSairmachines.add_to_rebuild_queue(considered_pipe)
	for(var/obj/machinery/atmospherics/components/considered_component in other_atmos_machines)
		considered_component.nullify_pipenet(src)
	return ..()

/datum/pipeline/process()
	if(!update || building)
		return
	reconcile_air()
	//Only react if the mix has changed, and don't keep updating if it hasn't
	update = air.react(src)

///Preps a pipeline for rebuilding, insterts it into the rebuild queue
/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/base)
	building = TRUE
	var/volume = 0
	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/considered_pipe = base
		volume = considered_pipe.volume
		members += considered_pipe
		if(considered_pipe.air_temporary)
			air = considered_pipe.air_temporary
			considered_pipe.air_temporary = null
	else
		add_machinery_member(base)

	if(!air)
		air = new

	air.volume = volume
	SSairmachines.add_to_expansion(src, base)

///Has the same effect as build_pipeline(), but this doesn't queue its work, so overrun abounds. It's useful for the pregame
/datum/pipeline/proc/build_pipeline_blocking(obj/machinery/atmospherics/base)
	var/volume = 0
	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/considered_pipe = base
		volume = considered_pipe.volume
		members += considered_pipe
		if(considered_pipe.air_temporary)
			air = considered_pipe.air_temporary
			considered_pipe.air_temporary = null
	else
		add_machinery_member(base)

	if(!air)
		air = new
	var/list/possible_expansions = list(base)
	while(possible_expansions.len)
		for(var/obj/machinery/atmospherics/borderline in possible_expansions)
			var/list/result = borderline.pipeline_expansion(src)
			if(!result?.len)
				possible_expansions -= borderline
				continue
			for(var/obj/machinery/atmospherics/considered_device in result)
				if(!istype(considered_device, /obj/machinery/atmospherics/pipe))
					considered_device.set_pipenet(src, borderline)
					add_machinery_member(considered_device)
					continue
				var/obj/machinery/atmospherics/pipe/item = considered_device
				if(members.Find(item))
					continue
				if(item.parent)
					var/static/pipenetwarnings = 10
					if(pipenetwarnings > 0)
						log_mapping("build_pipeline(): [item.type] added to a pipenet while still having one. (pipes leading to the same spot stacking in one turf) around [AREACOORD(item)].")
					if(pipenetwarnings == 0)
						log_mapping("build_pipeline(): further messages about pipenets will be suppressed")
					pipenetwarnings--

				members += item
				possible_expansions += item

				volume += item.volume
				item.parent = src

				if(item.air_temporary)
					air.merge(item.air_temporary)
					item.air_temporary = null

			possible_expansions -= borderline

	air.volume = volume

	/**
	 *  For a machine to properly "connect" to a pipeline and share gases,
	 *  the pipeline needs to acknowledge a gas mixture as it's member.
	 *  This is currently handled by the other_airs list in the pipeline datum.
	 *
	 *	Other_airs itself is populated by gas mixtures through the parents list that each machineries have.
	 *	This parents list is populated when a machinery calls update_parents and is then added into the queue by the controller.
	 */

/datum/pipeline/proc/add_machinery_member(obj/machinery/atmospherics/components/considered_component)
	other_atmos_machines |= considered_component
	var/list/returned_airs = considered_component.return_pipenet_airs(src)
	if (!length(returned_airs) || (null in returned_airs))
		stack_trace("addMachineryMember: Nonexistent (empty list) or null machinery gasmix added to pipeline datum from [considered_component] \
		which is of type [considered_component.type]. Nearby: ([considered_component.x], [considered_component.y], [considered_component.z])")
	other_airs |= returned_airs

/datum/pipeline/proc/add_member(obj/machinery/atmospherics/reference_device, obj/machinery/atmospherics/device_to_add)
	if(!istype(reference_device, /obj/machinery/atmospherics/pipe))
		reference_device.set_pipenet(src, device_to_add)
		add_machinery_member(reference_device)
	else
		var/obj/machinery/atmospherics/pipe/reference_pipe = reference_device
		if(reference_pipe.parent)
			merge(reference_pipe.parent)
		reference_pipe.parent = src
		var/list/adjacent = reference_pipe.pipeline_expansion()
		for(var/obj/machinery/atmospherics/pipe/adjacent_pipe in adjacent)
			if(adjacent_pipe.parent == src)
				continue
			var/datum/pipeline/parent_pipeline = adjacent_pipe.parent
			merge(parent_pipeline)
		if(!members.Find(reference_pipe))
			members += reference_pipe
			air.volume += reference_pipe.volume

/datum/pipeline/proc/merge(datum/pipeline/parent_pipeline)
	if(parent_pipeline == src)
		return
	air.volume += parent_pipeline.air.volume
	members.Add(parent_pipeline.members)
	for(var/obj/machinery/atmospherics/pipe/reference_pipe in parent_pipeline.members)
		reference_pipe.parent = src
	air.merge(parent_pipeline.air)
	for(var/obj/machinery/atmospherics/components/reference_component in parent_pipeline.other_atmos_machines)
		reference_component.replace_pipenet(parent_pipeline, src)
	other_atmos_machines |= parent_pipeline.other_atmos_machines
	other_airs |= parent_pipeline.other_airs
	parent_pipeline.members.Cut()
	parent_pipeline.other_atmos_machines.Cut()
	update = TRUE
	qdel(parent_pipeline)

/obj/machinery/atmospherics/proc/add_member(obj/machinery/atmospherics/considered_device)
	return

/obj/machinery/atmospherics/pipe/add_member(obj/machinery/atmospherics/considered_device)
	parent.add_member(considered_device, src)

/obj/machinery/atmospherics/components/add_member(obj/machinery/atmospherics/considered_device)
	var/datum/pipeline/device_pipeline = return_pipenet(considered_device)
	if(!device_pipeline)
		CRASH("null.add_member() called by [type] on [COORD(src)]")
	device_pipeline.add_member(considered_device, src)


/datum/pipeline/proc/temporarily_store_air()
	//Update individual gas_mixtures by volume ratio

	for(var/obj/machinery/atmospherics/pipe/member in members)
		member.air_temporary = new
		member.air_temporary.volume = member.volume
		member.air_temporary.copy_from(air, member.volume / air.volume)

		member.air_temporary.temperature = air.temperature

/datum/pipeline/proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
	var/total_heat_capacity = air.heat_capacity()
	var/partial_heat_capacity = total_heat_capacity * (share_volume / air.volume)
	var/target_temperature
	var/target_heat_capacity


	var/turf/modeled_location = target
	target_temperature = modeled_location.GetTemperature()
	target_heat_capacity = modeled_location.GetHeatCapacity()

	var/delta_temperature = air.temperature - target_temperature
	var/sharer_heat_capacity = target_heat_capacity

	if((sharer_heat_capacity <= 0) || (partial_heat_capacity <= 0))
		return TRUE
	var/heat = thermal_conductivity * delta_temperature * (partial_heat_capacity * sharer_heat_capacity / (partial_heat_capacity + sharer_heat_capacity))

	var/self_temperature_delta = - heat / total_heat_capacity
	var/sharer_temperature_delta = heat / sharer_heat_capacity

	air.temperature += self_temperature_delta
	modeled_location.TakeTemperature(sharer_temperature_delta)
	/*if(modeled_location.blocks_air & AIR_BLOCKED)
		modeled_location.temperature_expose(air, modeled_location.temperature)*/

	update = TRUE

/datum/pipeline/proc/return_air()
	. = other_airs + air
	if(null in .)
		stack_trace("[src] has one or more null gas mixtures, which may cause bugs. Null mixtures will not be considered in reconcile_air().")
		return remove_nulls_from_list(.)

/// Called when the pipenet needs to update and mix together all the air mixes
/datum/pipeline/proc/reconcile_air()
	var/list/datum/gas_mixture/gas_mixture_list = list()
	var/list/datum/pipeline/pipeline_list = list()
	pipeline_list += src

	for(var/i = 1; i <= pipeline_list.len; i++) //can't do a for-each here because we may add to the list within the loop
		var/datum/pipeline/pipeline = pipeline_list[i]
		if(!pipeline)
			continue
		gas_mixture_list += pipeline.other_airs
		gas_mixture_list += pipeline.air
		for(var/obj/machinery/atmospherics/components/atmos_machine as anything in pipeline.other_atmos_machines)
			if(!atmos_machine.custom_reconcilation)
				continue
			pipeline_list |= atmos_machine.return_pipenets_for_reconcilation(src)
			gas_mixture_list |= atmos_machine.return_airs_for_reconcilation(src)

	equalize_gases(gas_mixture_list)


/proc/equalize_gases(list/datum/gas_mixture/gases)
	//Calculate totals from individual components
	var/total_volume = 0
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	var/list/total_gas = list()
	for(var/datum/gas_mixture/gasmix in gases)
		total_volume += gasmix.volume
		var/temp_heatcap = gasmix.heat_capacity()
		total_thermal_energy += gasmix.temperature * temp_heatcap
		total_heat_capacity += temp_heatcap
		for(var/g in gasmix.get_gases())
			total_gas[g] += gasmix.gas[g]

	if(total_volume > 0)
		var/datum/gas_mixture/combined = new(total_volume)
		combined.gas = total_gas

		//Calculate temperature
		if(total_heat_capacity > 0)
			combined.temperature = total_thermal_energy / total_heat_capacity
		combined.update_values()

		//Allow for reactions
		combined.react()

		//Average out the gases
		for(var/g in combined.get_gases())
			combined.gas[g] /= total_volume

		//Update individual gas_mixtures
		for(var/datum/gas_mixture/gasmix in gases)
			gasmix.gas = combined.gas.Copy()
			gasmix.temperature = combined.temperature
			gasmix.multiply(gasmix.volume)

	return 1
