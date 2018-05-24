/datum/experiment_type/heat
	name = "Burn"

/datum/experiment/coffee/heater_fail
	weight = 20
	experiment_type = /datum/experiment_type/heat
	base_points = 2500
	critical = TRUE
	valid_reagents = list("plasma","capsaicin","ethanol")

/datum/experiment/coffee/heater_fail/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(.)
		E.visible_message("<span class='warning'>[E]'s heating system gives off a small ding!</span>")
		playsound(E, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!

/datum/experiment/destroy/fire_burst
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/heat
	immune_flags = FIRE_PROOF | INDESTRUCTIBLE

/datum/experiment/destroy/fire_burst/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] malfunctions, melting [O] and leaking hot air!</span>")
	E.investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
	explosion(E, -1, 0, 0, 0, 0, flame_range = 4)

/datum/experiment/fireball
	weight = 30
	is_bad = TRUE
	experiment_type = /datum/experiment_type/heat

/datum/experiment/fireball/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] dangerously overheats, launching a flaming fuel orb!</span>")
	var/turf/start = get_turf(E)
	var/mob/living/target = locate(/atom) in oview(7,E)
	if(target)
		var/turf/end = get_turf(target)
		var/obj/item/projectile/magic/aoe/fireball/FB = new /obj/item/projectile/magic/aoe/fireball(start)
		FB.preparePixelProjectile(end, start)
		FB.fire()
		E.investigate_log("Experimentor has shot a fireball at [target]", INVESTIGATE_EXPERIMENTOR)


/datum/experiment/destroy/hot_gas
	weight = 50
	is_bad = TRUE
	experiment_type = /datum/experiment_type/heat
	immune_flags = FIRE_PROOF | INDESTRUCTIBLE

/datum/experiment/destroy/hot_gas/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] malfunctions, melting [O] and leaking hot air!</span>")
	E.investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
	var/datum/gas_mixture/env = E.return_air()
	var/transfer_moles = 0.25 * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(removed)
		var/heat_capacity = removed.heat_capacity()
		if(heat_capacity)
			removed.temperature = min((removed.temperature*heat_capacity + 100000)/heat_capacity,4000)
	env.merge(removed)
	E.air_update_turf()

/datum/experiment/burn_people
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/heat

/datum/experiment/burn_people/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	. = FALSE
	E.visible_message("<span class='warning'>[E] malfunctions, activating its emergency coolant systems!</span>")
	E.throw_smoke(get_turf(E),3)
	for(var/mob/living/m in oview(1, E))
		m.apply_damage(5, BURN, pick("head","chest","groin"))
		E.investigate_log("Experimentor dealt minor burn to [m].", INVESTIGATE_EXPERIMENTOR)
		. = TRUE
	E.eject_item()

/datum/experiment/heat_container
	weight = 80
	experiment_type = /datum/experiment_type/heat

/datum/experiment/heat_container/init()
	valid_types = typecacheof(/obj/item/reagent_containers) //Only works on containers

/datum/experiment/heat_container/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(!O.reagents || O.reagents.total_volume <= 0)
		. = FALSE

/datum/experiment/heat_container/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] heats up [O].</span>")
	E.investigate_log("Experimentor has heated [O].", INVESTIGATE_EXPERIMENTOR)
	O.reagents.expose_temperature(1000,0.5)

/datum/experiment/microwave
	weight = 80
	experiment_type = /datum/experiment_type/heat

/datum/experiment/microwave/init()
	valid_types = typecacheof(/obj/item/reagent_containers/food/snacks) //Only works on food

/datum/experiment/microwave/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] begins cooking [O].</span>")
	E.investigate_log("Experimentor has microwaved [O].", INVESTIGATE_EXPERIMENTOR)
	O.microwave_act()
	addtimer(CALLBACK(src, .proc/eject, E), E.reset_time)

/datum/experiment/microwave/proc/eject(obj/machinery/rnd/experimentor/E)
	E.eject_item()
	playsound(E, 'sound/machines/ding.ogg', 50, 1)