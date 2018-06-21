/datum/experiment_type/gas
	name = "Gas"

/datum/experiment/plasma_mix
	weight = 20
	experiment_type = /datum/experiment_type/gas
	base_points = 2500
	critical = TRUE

/datum/experiment/plasma_mix/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("[E] achieves the perfect mix!")
	new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,E))))

/datum/experiment/destroy/gas_cloud
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/gas

/datum/experiment/destroy/gas_cloud/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/chosen_chem = pick("carbon","radium","toxin","condensedcapsaicin","mushroomhallucinogen","space_drugs","ethanol","beepskysmash")
	E.visible_message("<span class='danger'>[E] destroys [O], leaking dangerous gas!</span>")
	E.investigate_log("Experimentor has released [chosen_chem] smoke.", INVESTIGATE_EXPERIMENTOR)
	E.create_reagents(50)
	E.reagents.add_reagent(chosen_chem , 50)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(E.reagents, rand(0,9), E, silent = 1)
	playsound(E, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.start()
	qdel(E.reagents)

/datum/experiment/chemical_leak
	weight = 30
	is_bad = TRUE
	experiment_type = /datum/experiment_type/gas

/datum/experiment/chemical_leak/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/chosen_chem = pick("mutationtoxin","nanomachines","sacid")
	E.visible_message("<span class='danger'>[E]'s chemical chamber has sprung a leak!</span>")
	E.investigate_log("Experimentor has released <font color='red'>[chosen_chem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)
	E.create_reagents(50)
	E.reagents.add_reagent(chosen_chem , 50)
	var/datum/effect_system/foam_spread/foam = new
	foam.set_up(2, E, E.reagents)
	foam.start()
	playsound(E, 'sound/effects/splat.ogg', 50, 1, -3)
	qdel(E.reagents)

/datum/experiment/destroy/emp
	weight = 10
	is_bad = TRUE
	experiment_type = /datum/experiment_type/gas

/datum/experiment/destroy/emp/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] melts [O], ionizing the air around it!</span>")
	E.investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
	empulse(get_turf(E), 4, 6)

/datum/experiment/burp
	weight = 30
	is_bad = TRUE
	experiment_type = /datum/experiment_type/gas

/datum/experiment/burp/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	. = FALSE
	E.create_reagents(10)
	E.visible_message("<span class='danger'>[E] burps. Disgusting!</span>")
	for(var/mob/living/m in oview(1, E))
		E.reagents.add_reagent("spewium", 10)
		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(E.reagents, 0, m, silent = 1)
		playsound(E, 'sound/effects/smoke.ogg', 50, 1, -3)
		smoke.start()
		E.investigate_log("Experimentor burped at [m].", INVESTIGATE_EXPERIMENTOR)
		. = TRUE
	qdel(E.reagents)
