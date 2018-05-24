/datum/experiment_type/cool
	name = "Freeze"

/datum/experiment/coffee/coolant_fail
	weight = 20
	experiment_type = /datum/experiment_type/cool
	base_points = 2500
	critical = TRUE
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
	immune_flags = FREEZE_PROOF | INDESTRUCTIBLE

/datum/experiment/destroy/frost_cloud/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
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
	weight = 30
	is_bad = TRUE
	experiment_type = /datum/experiment_type/cool
	immune_flags = FREEZE_PROOF | INDESTRUCTIBLE

/datum/experiment/destroy/cold_gas/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
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

/datum/experiment/freeze_item
	weight = 50
	is_bad = TRUE
	experiment_type = /datum/experiment_type/cool

/datum/experiment/freeze_item/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(O.resistance_flags & FREEZE_PROOF)
		. = FALSE

/datum/experiment/freeze_item/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] malfunctions, releasing a flurry of chilly air as [O] pops out!</span>")
	E.investigate_log("Experimentor has frozen [O].", INVESTIGATE_EXPERIMENTOR)
	O.make_frozen_visual()
	E.eject_item()

/datum/experiment/cool_container
	weight = 80
	experiment_type = /datum/experiment_type/cool

/datum/experiment/cool_container/init()
	valid_types = typecacheof(/obj/item/reagent_containers) //Only works on containers

/datum/experiment/cool_container/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(!O.reagents || O.reagents.total_volume <= 0)
		. = FALSE

/datum/experiment/cool_container/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] cools [O].</span>")
	E.investigate_log("Experimentor has cooled [O].", INVESTIGATE_EXPERIMENTOR)
	O.reagents.expose_temperature(50,0.5)

/datum/experiment/snowstorm
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/cool

/datum/experiment/snowstorm/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/turf/use_turf = get_turf(E)
	var/area/use_area = get_area(E)
	E.visible_message("<span class='warning'>[E] malfunctions, reversing the direction of cooling!</span>") //nevermind I retract the griff statement, snowstorms do nothing and they're invisible reeee
	E.investigate_log("Experimentor has caused a snowstorm.", INVESTIGATE_EXPERIMENTOR)
	var/datum/weather/A = new /datum/weather/snow_storm(list(use_turf.z))
	A.name = "cold exhaust"
	A.area_type = use_area.type
	A.telegraph_duration = 5
	A.end_duration = 100
	A.telegraph()