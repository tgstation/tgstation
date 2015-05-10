/datum/pipe_network
	var/list/datum/gas_mixture/gases = list() //All of the gas_mixtures continuously connected in this network

	var/list/obj/machinery/atmospherics/normal_members = list()
	var/list/datum/pipeline/line_members = list()
		//membership roster to go through for updates and what not

	var/update = 1
	var/datum/gas_mixture/air_transient = null
	var/datum/gas_mixture/radiate = null

/datum/pipe_network/New()

	air_transient = new()

	..()

/datum/pipeline/Del()
	pipe_networks -= src
	..()

/datum/pipe_network/Destroy()
	for(var/datum/pipeline/pipeline in line_members) //This will remove the pipeline references for us
		pipeline.network = null
	for(var/obj/machinery/atmospherics/objects in normal_members) //Procs for the different bases will remove the references
		objects.unassign_network(src)

/datum/pipe_network/resetVariables()
	..("gases", "normal_members", "line_members")
	gases = list()
	normal_members = list()
	line_members = list()

/datum/pipe_network/proc/process()
	//Equalize gases amongst pipe if called for
	if(update)
		update = 0
		reconcile_air() //equalize_gases(gases)
		radiate = null //Reset our last ticks calculation for the post-radiate() gases inside a thermal plate

#ifdef ATMOS_PIPELINE_PROCESSING
	//Give pipelines their process call for pressure checking and what not. Have to remove pressure checks for the time being as pipes dont radiate heat - Mport
	for(var/datum/pipeline/line_member in line_members)
		line_member.process()
#endif

/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	//Purpose: Generate membership roster
	//Notes: Assuming that members will add themselves to appropriate roster in network_expandz()

	if(!start_normal)
		returnToDPool(src)
		return

	start_normal.network_expand(src, reference)

	update_network_gases()

	if((normal_members.len>0)||(line_members.len>0))
		pipe_networks |= src
	else
		returnToDPool(src)
		return
	return 1

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver==src) return 0

	normal_members |= giver.normal_members

	line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member in giver.line_members)
		line_member.network = src


	update_network_gases()
	return 1

/datum/pipe_network/proc/update_network_gases()
	//Go through membership roster and make sure gases is up to date

	gases = list()

	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		var/result = normal_member.return_network_air(src)
		if(result) gases += result

	for(var/datum/pipeline/line_member in line_members)
		gases += line_member.air

/datum/pipe_network/proc/reconcile_air()
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	//air_transient.volume = 0
	var/air_transient_volume = 0

	for(var/gasid in air_transient.gases)
		air_transient.set_gas(gasid, 0, 0) //sets them all to 0

	for(var/datum/gas_mixture/gas in gases)
		air_transient_volume += gas.volume
		var/temp_heatcap = gas.heat_capacity
		total_thermal_energy += gas.temperature*temp_heatcap
		total_heat_capacity += temp_heatcap

		air_transient.add(gas)

	air_transient.set_volume(air_transient_volume)

	if(air_transient_volume > 0)

		if(total_heat_capacity > 0)
			air_transient.set_temperature(total_thermal_energy/total_heat_capacity)

			//Allow air mixture to react
			if(air_transient.react())
				update = 1

		else
			air_transient.set_temperature(0)

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas in gases)
			var/volume_ratio = gas.volume / air_transient.volume

			gas.copy_from(air_transient)
			gas.multiply(volume_ratio)

	return 1

proc/equalize_gases(list/datum/gas_mixture/gases)
	//Perfectly equalize all gases members instantly

	var/datum/gas_mixture/total = new
	var/total_volume = 0
	var/total_thermal_energy = 0

	for(var/datum/gas_mixture/gas in gases)
		total_volume += gas.volume
		total_thermal_energy += gas.temperature*gas.heat_capacity

		total.add(gas)


	if(total_volume > 0)

		//Calculate temperature
		var/temperature = 0

		if(total.heat_capacity > 0)
			temperature = total_thermal_energy/total.heat_capacity

		//Update individual gas_mixtures by volume ratio
		for(var/gasid in total.gases) //for each gas in the gas mix in our list of gas mixes
			var/total_gas = total.gases[gasid]
			for(var/datum/gas_mixture/gas_mix in gases)
				gas_mix.set_gas(gasid, total_gas * gas_mix.volume / total_volume)

		for(var/datum/gas_mixture/gas_mix in gases) //cheaper to set here
			gas_mix.set_temperature(temperature)

	return 1