/datum/relic_effect/automatic
	var/active = TRUE

/datum/relic_effect/automatic/apply_to_component(obj/item/A,datum/component/relic/comp)
	..()
	comp.add_process(CALLBACK(src, .proc/process, A))

/datum/relic_effect/automatic/process(obj/item/A)
	return active

/datum/relic_effect/automatic/refuel
	var/list/fuel_values
	var/list/possible_fuels = list("welding_fuel","plasma","oil","clf3","phlogiston","napalm","hydrogen","charcoal")

/datum/relic_effect/automatic/refuel/init()
	var/times = rand(1,possible_fuels.len)
	for(var/i in 1 to times)
		fuel_values[pick_n_take(possible_fuels)] = rand(1,200)

/datum/relic_effect/automatic/refuel/process(obj/item/A)
	if(!..() || !A.reagents || !A.reagents.total_volume)
		return
	var/list/cached_reagents = A.reagents.reagent_list
	for(var/datum/reagent/R in cached_reagents)
		if(possible_fuels[R.id] > 0)
			//give power here and increase temp of the mix
			A.reagents.remove_reagent(R.id, R.metabolization_rate)

/datum/relic_effect/automatic/refuel/biofuels
	possible_fuels = list("blood","milk","carbon","corn_oil","soy_milk","nutriment","sugar")

/datum/relic_effect/automatic/refuel/water
	possible_fuels = list("water","ice","holywater","unholywater","hell_water")

/datum/relic_effect/automatic/refuel/blood
	possible_fuels = list("blood","liquidgibs","synthflesh")

/datum/relic_effect/automatic/recharge_apc
	var/power_output

/datum/relic_effect/automatic/recharge_apc/init()
	power_output = rand(1,12) * 500

/datum/relic_effect/automatic/recharge_apc/process(obj/item/A)
	if(!..())
		return
	var/area/W = get_area(A)
	for (var/obj/machinery/power/apc/APC in W)
		var/obj/item/stock_parts/cell/C = APC.get_cell()
		if(C)
			C.give(power_output)

/datum/relic_effect/automatic/gas_producer
	var/spawn_id
	var/produced_moles
	var/produced_temp
	var/max_pressure
	var/static/list/valid_types = list("o2","n2","co2","plasma","n2o","bz","tritium","water_vapor","no2")

/datum/relic_effect/automatic/gas_producer/init()
	spawn_id = pick(valid_types)
	produced_moles = rand(1,20)
	produced_temp = T20C
	max_pressure = rand(ONE_ATMOSPHERE*1000,ONE_ATMOSPHERE*25000)/1000

/datum/relic_effect/automatic/gas_producer/process(obj/item/A)
	if(!..())
		return
	var/datum/gas_mixture/environment = A.return_air()
	if(environment && environment.return_pressure() < max_pressure)
		var/datum/gas_mixture/merger = new
		merger.assert_gas(spawn_id)
		merger.gases[spawn_id][MOLES] = produced_moles
		merger.temperature = produced_temp
		A.assume_air(merger) //should update hopefully

/datum/relic_effect/automatic/chem_producer
	var/produced_chems
	var/produced_amt

/datum/relic_effect/automatic/chem_producer/init()
	var/times = rand(1,3)
	for(var/i in 1 to times)
		produced_chems[get_random_reagent_id()] += rand(1,100) / 100
	produced_amt = rand(1,25)

/datum/relic_effect/automatic/chem_producer/process(obj/item/A)
	if(!..())
		return
	if(A.reagents && A.reagents.total_volume < A.reagents.maximum_volume - produced_amt)
		for(var/id in produced_chems)
			A.reagents.add_reagent(id,produced_chems[id]*produced_amt)