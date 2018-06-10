/datum/experiment/destroy/summon_pet
	is_bad = TRUE
	var/pet_path = /mob/living/simple_animal/pet
	var/mob/living/simple_animal/pet/tracked

/datum/experiment/destroy/summon_pet/init()
	tracked = locate(pet_path) in GLOB.mob_living_list

/datum/experiment/destroy/summon_pet/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/turf/T = get_turf(E)
	E.throw_smoke(T,0)
	if(!QDELETED(tracked))
		E.throw_smoke(get_turf(tracked),0)
		tracked.forceMove(T)
		E.investigate_log("Experimentor has stolen [tracked]!", INVESTIGATE_EXPERIMENTOR)
	else
		tracked = null
		var/mob/living/simple_animal/pet = new pet_path(T)
		E.investigate_log("Experimentor has spawned a new [pet].", INVESTIGATE_EXPERIMENTOR)

/datum/experiment/destroy/summon_pet/ian
	weight = 20
	experiment_type = /datum/experiment_type
	pet_path = /mob/living/simple_animal/pet/dog/corgi

/datum/experiment/destroy/summon_pet/ian/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] melts [O], ianizing the air around it!</span>")
	. = FALSE

/datum/experiment/destroy/summon_pet/runtime
	weight = 20
	experiment_type = /datum/experiment_type
	pet_path = /mob/living/simple_animal/pet/cat

/datum/experiment/destroy/summon_pet/runtime/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] encounters a run-time error!</span>")
	. = FALSE

/datum/experiment/power_drain
	weight = 20
	experiment_type = /datum/experiment_type
	is_bad = TRUE
	power_use = 500000

/datum/experiment/power_drain/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.throw_smoke(get_turf(E),0)
	E.visible_message("<span class='warning'>[E] begins to smoke and hiss, shaking violently!</span>")
	E.investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)
	. = FALSE

/datum/experiment/failure
	weight = 80
	experiment_type = /datum/experiment_type
	is_bad = TRUE

/datum/experiment/failure/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	var/a = pick("rumbles","shakes","vibrates","shudders")
	var/b = pick("crushes","spins","viscerates","smashes","insults")
	E.visible_message("<span class='warning'>[E] [a], and [b] [O], the experiment was a failure.</span>")
	. = FALSE

/datum/experiment/blood_drain
	weight = 10
	experiment_type = /datum/experiment_type
	is_bad = TRUE

/datum/experiment/blood_drain/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	. = FALSE
	E.visible_message("<span class='warning'>[E] draws the life essence of those nearby!</span>")
	base_points = 50
	for(var/mob/living/m in oview(4,E))
		to_chat(m, "<span class='danger'>You feel your flesh being torn from you, mists of blood drifting to [E]!</span>")
		m.apply_damage(50, BRUTE, "chest")
		m.blood_volume = CLAMP(m.blood_volume - 100, 0, BLOOD_VOLUME_MAXIMUM)
		E.investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", INVESTIGATE_EXPERIMENTOR)
		base_points += 250 * log(base_points) //Blood sacrifice used to vastly increase the tech level on an item, let's bring back nostalgic powergaming
		. = TRUE
	if(!.)
		E.visible_message("<span class='notice'>...but nothing happened.</span>")

/datum/experiment/destroy/transform/grenade
	weight = 5
	experiment_type = /datum/experiment_type
	is_bad = TRUE
	var/list/blacklist = list(/obj/item/grenade/chem_grenade,/obj/item/grenade,/obj/item/grenade/chem_grenade,/obj/item/grenade/chem_grenade/adv_release,/obj/item/grenade/chem_grenade/cryo,/obj/item/grenade/chem_grenade/pyro, /obj/item/grenade/chem_grenade/tuberculosis)

/datum/experiment/destroy/transform/grenade/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	E.investigate_log("Experimentor has transformed an [O] into a grenade", INVESTIGATE_EXPERIMENTOR)
	. = ..()

/datum/experiment/destroy/transform/grenade/make_transform_item(atom/location)
	var/pickedtype = pick(typesof(/obj/item/grenade) - blacklist)
	var/obj/item/grenade/G = new pickedtype(location)
	addtimer(CALLBACK(G, /obj/item/grenade.proc/prime), 5)
	return G

/datum/experiment/destroy/transform/food
	weight = 5
	experiment_type = /datum/experiment_type
	is_bad = TRUE

/datum/experiment/destroy/transform/food/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	E.investigate_log("Experimentor has transformed an [O] into food", INVESTIGATE_EXPERIMENTOR)
	. = ..()

/datum/experiment/destroy/transform/food/make_transform_item(atom/location)
	var/pickedtype = get_random_food()
	return new pickedtype(location)

/datum/experiment/destroy/transform/stock_part
	weight = 5
	experiment_type = /datum/experiment_type
	is_bad = TRUE
	var/list/blacklist = list(/obj/item/stock_parts,/obj/item/stock_parts/subspace)

/datum/experiment/destroy/transform/stock_part/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	E.investigate_log("Experimentor has transformed an [O] into a stock part", INVESTIGATE_EXPERIMENTOR)
	. = ..()

/datum/experiment/destroy/transform/stock_part/make_transform_item(atom/location)
	var/pickedtype = pick(typesof(/obj/item/stock_parts) - blacklist)
	var/obj/item/stock_parts/G = new pickedtype(location)
	return G