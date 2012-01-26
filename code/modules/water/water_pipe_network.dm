var/global/list/datum/water/pipe_network/water_pipe_networks = list()

/datum/water/pipe_network
	var/list/datum/reagents/reagents = list() //All of the gas_mixtures continuously connected in this network

	var/list/obj/machinery/water/normal_members = list()
	var/list/datum/water/pipeline/line_members = list()
		//membership roster to go through for updates and what not

	var/update = 1
	var/datum/reagents/reagents_transient = null
	var/max_pressure_transient = 3*ONE_ATMOSPHERE

	New()
		reagents_transient = new()

		..()

	proc/process()
		//Equalize gases amongst pipe if called for
		if(update)
			update = 0
			reconcile_reagents()

		// release pipe leaks
		var/dirs
		for(var/datum/water/pipeline/P in line_members)
			for(var/obj/machinery/water/pipe/E in P.edges)
				dirs = E.initialize_directions
				for(var/C in E.pipeline_expansion())
					if(C) // a connection, remove dir from possibilities
						dirs &= ~(get_dir(E, C))
				if(dirs > 0) // there was a disconnect, release half of volume
					P.mingle_with_turf(get_turf(E), \
						P.reagents.total_volume / P.reagents.maximum_volume * E.max_volume / 2, \
						dirs)

	proc/build_network(obj/machinery/water/start_normal, obj/machinery/water/reference)
		//Purpose: Generate membership roster
		//Notes: Assuming that members will add themselves to appropriate roster in network_expand()

		if(!start_normal)
			del(src)

		start_normal.network_expand(src, reference)

		update_network_reagents()

		if((normal_members.len>0)||(line_members.len>0))
			water_pipe_networks += src
		else
			del(src)

	proc/merge(datum/water/pipe_network/giver)
		if(giver==src) return 0

		normal_members -= giver.normal_members
		normal_members += giver.normal_members

		line_members -= giver.line_members
		line_members += giver.line_members

		for(var/obj/machinery/water/normal_member in giver.normal_members)
			normal_member.reassign_network(giver, src)

		for(var/datum/water/pipeline/line_member in giver.line_members)
			line_member.network = src

		del(giver)

		update_network_reagents()
		return 1

	proc/update_network_reagents()
		//Go through membership roster and make sure reagents is up to date

		reagents = list()

		for(var/obj/machinery/water/normal_member in normal_members)
			var/result = normal_member.return_network_reagents(src)
			if(result) reagents += result

		for(var/datum/water/pipeline/line_member in line_members)
			reagents += line_member.reagents

	proc/reconcile_reagents()
		//Perfectly equalize all reagent members instantly

		reagents_transient = new(0)
		reagents_transient.my_atom = new/obj()

		// it's more efficient to avoid .add_reagent, etc more then once per reagent type
		for(var/datum/reagents/R in reagents)
			// add in each reagents
			reagents_transient.maximum_volume += R.maximum_volume

			for (var/datum/reagent/re in R.reagent_list)
				var/datum/reagent/rr = reagents_transient.has_reagent(re.id)
				if(!rr)
					reagents_transient.add_reagent(re.id, re.volume, re.data)
				else
					rr.volume += re.volume
		reagents_transient.update_total()

		if(reagents_transient.total_volume > 0)
			update = 1

			//Update individual reagents by volume ratio
			for(var/datum/reagents/R in reagents)
				for(var/datum/reagent/re in reagents_transient.reagent_list)
					var/datum/reagent/rr = R.has_reagent(re.id)
					if(!rr)
						R.add_reagent(re.id, re.volume \
							* R.maximum_volume \
							/ reagents_transient.maximum_volume, re.data)
					else
						rr.volume = re.volume \
							* R.maximum_volume \
							/ reagents_transient.maximum_volume
				R.update_total()
		return 1

	proc/return_pressure_transient()
		return reagents_transient.total_volume / reagents_transient.maximum_volume * max_pressure_transient



proc/mingle_outflow_with_turf(turf/simulated/target, mingle_volume, dir = 0, datum/water/pipeline/pipeline = null, datum/water/pipe_network/network = null, datum/reagents/reagents = null, pressure = 0)
	if(pipeline)
		network = pipeline.network
		if(!reagents)
			reagents = pipeline.reagents
		if(!pressure)
			pressure = pipeline.return_pressure()
	else
		if(!reagents)
			reagents = network.reagents_transient
		if(!pressure)
			pressure = network.return_pressure_transient()

	mingle_volume = min(mingle_volume, reagents.total_volume)
	var/num_spots = round(pressure / 10)

	if(mingle_volume < num_spots)
		return

	var/datum/reagents/mingle = new(mingle_volume)
	mingle.my_atom = target
	reagents.trans_to(mingle, mingle_volume)

	var/turf/T1
	var/turf/T2
	if(dir == 0)
		T1 = get_step(target, NORTH)
		T1 = get_step(T1, EAST)

		T2 = get_step(target, SOUTH)
		T2 = get_step(T2, WEST)
	else
		T1 = get_step(target, turn(dir, -90))
		T1 = get_step(T1, dir)

		T2 = get_step(target, turn(dir, 90))
		for(var/i = 1 to 5)
			T2 = get_step(T2, dir)

	var/box = block(T1, T2)

	for(var/i = 1 to num_spots)
		spawn(0)
			var/obj/effect/effect/water/W = new /obj/effect/effect/water(get_turf(target))
			var/turf/my_target = pick(box)
			var/datum/reagents/R = new(mingle_volume/num_spots)
			if(!W) return
			W.reagents = R
			R.my_atom = W
			if(!W || !src) return
			mingle.trans_to(W,mingle_volume/num_spots)
			for(var/b=0, b<5, b++)
				step_towards(W,my_target)
				if(!W) return
				W.reagents.reaction(get_turf(W))
				for(var/atom/atm in get_turf(W))
					if(!W) return
					W.reagents.reaction(atm)
				if(W.loc == my_target) break

	if(network)
		network.update = 1

proc/equalize_reagents(var/list/datum/reagents/reagents)
	//Perfectly equalize all reagent members instantly

	//Calculate totals from individual components
	var/datum/reagents/reagents_transient = new(0)
	reagents_transient.my_atom = new/obj()

	// it's more efficient to avoid .add_reagent, etc more then once per reagent type
	for(var/datum/reagents/R in reagents)
		// add in each reagents
		reagents_transient.maximum_volume += R.maximum_volume

		for (var/datum/reagent/re in R.reagent_list)
			var/datum/reagent/rr = reagents_transient.has_reagent(re.id)
			if(!rr)
				reagents_transient.add_reagent(re.id, re.volume, re.data)
			else
				rr.volume += re.volume
	reagents_transient.update_total()

	if(reagents_transient.total_volume > 0)
		//Update individual reagents by volume ratio
		for(var/datum/reagents/R in reagents)
			for(var/datum/reagent/re in reagents_transient.reagent_list)
				var/datum/reagent/rr = R.has_reagent(re.id)
				if(!rr)
					R.add_reagent(re.id, re.volume \
						* R.maximum_volume \
						/ reagents_transient.maximum_volume, re.data)
				else
					rr.volume = re.volume \
						* R.maximum_volume \
						/ reagents_transient.maximum_volume
			R.update_total()
	return 1
