datum/water/pipeline
	var/datum/reagents/reagents
	var/max_pressure

	var/list/obj/machinery/water/pipe/members
	var/list/obj/machinery/water/pipe/edges //Used for building networks

	var/datum/water/pipe_network/network

	var/alert_pressure = 0

	Del()
		if(network)
			del(network)

		if(reagents && reagents.total_volume)
			temporarily_store_reagents()
			del(reagents)

		..()

	proc/process()//This use to be called called from the pipe networks
		//Check to see if pressure is within acceptable limits
		var/pressure = return_pressure()
		if(pressure > alert_pressure)
			for(var/obj/machinery/water/pipe/member in members)
				if(!member.check_pressure(pressure))
					break //Only delete 1 pipe per process

		//Allow for reactions
		//air.react() //Should be handled by pipe_network now

	proc/temporarily_store_reagents()
		//Update individual gas_mixtures by volume ratio

		for(var/obj/machinery/water/pipe/member in members)
			member.reagents_temporary = new(member.max_volume)
			member.reagents_temporary.my_atom = member

			for(var/datum/reagent/re in reagents.reagent_list)
				re.volume = \
					reagents.get_reagent_amount(re.id) \
					* member.max_volume \
					/ reagents.maximum_volume

	proc/build_pipeline(obj/machinery/water/pipe/base)
		var/list/possible_expansions = list(base)
		members = list(base)
		edges = list()

		var/volume = base.max_volume
		base.parent = src
		alert_pressure = base.alert_pressure

		if(base.reagents_temporary)
			reagents = base.reagents_temporary
			base.reagents_temporary = null
		else
			reagents = new(base.max_volume)
			reagents.my_atom = base
		max_pressure = base.max_pressure
		var/PT = 1

		while(possible_expansions.len>0)
			for(var/obj/machinery/water/pipe/borderline in possible_expansions)

				var/list/result = borderline.pipeline_expansion()
				var/edge_check = result.len

				if(result.len>0)
					for(var/obj/machinery/water/pipe/item in result)
						if(!members.Find(item))
							members += item
							possible_expansions += item

							volume += item.max_volume
							max_pressure += item.max_pressure
							PT++
							item.parent = src

							alert_pressure = min(alert_pressure, item.alert_pressure)

							if(item.reagents_temporary)
								item.reagents_temporary.copy_to(reagents, item.reagents_temporary.total_volume)

						edge_check--

				if(edge_check>0)
					edges += borderline

				possible_expansions -= borderline

		reagents.maximum_volume = volume
		max_pressure /= PT

	proc/network_expand(datum/water/pipe_network/new_network, obj/machinery/water/pipe/reference)

		if(new_network.line_members.Find(src))
			return 0

		new_network.line_members += src

		network = new_network

		for(var/obj/machinery/water/pipe/edge in edges)
			for(var/obj/machinery/water/result in edge.pipeline_expansion())
				if(!istype(result,/obj/machinery/water/pipe) && (result!=reference))
					result.network_expand(new_network, edge)

		return 1

	proc/return_network(obj/machinery/water/reference)
		if(!network)
			network = new /datum/water/pipe_network()
			network.build_network(src, null)
				//technically passing these parameters should not be allowed
				//however pipe_network.build_network(..) and pipeline.network_extend(...)
				//		were setup to properly handle this case

		return network

	proc/return_pressure()
		return reagents.total_volume / reagents.maximum_volume * max_pressure

	proc/mingle_with_turf(turf/simulated/target, mingle_volume, dir = 0)
		// dump all of section's volume
		mingle_outflow_with_turf(target, mingle_volume, dir, pipeline=src)