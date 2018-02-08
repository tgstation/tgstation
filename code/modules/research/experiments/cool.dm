/datum/experiment_type/cool
	name = "Freeze"

/datum/experiment/coffee/coolant_fail
	weight = 20
	experiment_type = /datum/experiment_type/cool
	base_points = 250
	valid_reagents = list("uranium","frostoil","ephedrine")

/datum/experiment/coffee/coolant_fail/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(.)
		E.visible_message("<span class='warning'>[E]'s emergency coolant system gives off a small ding!</span>")
		playsound(E, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!

/datum/experiment/destroy/frost_cloud
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/cool

/datum/experiment/destroy/frost_cloud/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(.)
		E.visible_message("<span class='danger'>[E] malfunctions, shattering [O] and releasing a dangerous cloud of coolant!</span>")
		E.investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
		E.create_reagents(50)
		E.reagents.add_reagent("frostoil" , 50)
		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(E.reagents, 0, E, silent = 1)
		playsound(E, 'sound/effects/smoke.ogg', 50, 1, -3)
		smoke.start()
		qdel(E.reagents)

/datum/experiment/destroy/cold_gas
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/cool

/datum/experiment/destroy/cold_gas/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(.)
		E.visible_message("<span class='warning'>[E] malfunctions, shattering [O] and leaking cold air!</span>")
		E.investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
		var/datum/gas_mixture/env = E.return_air()
		var/transfer_moles = 0.25 * env.total_moles()
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		if(removed)
			var/heat_capacity = removed.heat_capacity()
			if(heat_capacity)
				removed.temperature = max((removed.temperature*heat_capacity - 75000)/heat_capacity,T0C - 150)
		env.merge(removed)
		E.air_update_turf()