/datum/experiment/destroy/summon_pet
	is_bad = TRUE
	var/pet_path = /mob/living/simple_animal/pet
	var/mob/living/simple_animal/pet/tracked

/datum/experiment/destroy/summon_pet/init()
	pet_path = locate(pet_path) in GLOB.mob_living_list

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

/datum/experiment/destroy/summon_pet/runtime
	weight = 20
	experiment_type = /datum/experiment_type
	pet_path = /mob/living/simple_animal/pet/cat

/datum/experiment/destroy/summon_pet/runtime/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] encounters a run-time error!</span>")

/datum/experiment/power_drain
	is_bad = TRUE
	power_cost = 500000

/datum/experiment/power_drain/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.throw_smoke(get_turf(E),0)
	E.visible_message("<span class='warning'>[E] begins to smoke and hiss, shaking violently!</span>")
	E.investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)

/datum/experiment/blood_drain
	is_bad = TRUE

/datum/experiment/blood_drain/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	. = FALSE
	visible_message("<span class='warning'>Experimentor draws the life essence of those nearby!</span>")
	for(var/mob/living/m in oview(4,E))
		to_chat(m, "<span class='danger'>You feel your flesh being torn from you, mists of blood drifting to [E]!</span>")
		m.apply_damage(50, BRUTE, "chest")
		E.investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", INVESTIGATE_EXPERIMENTOR)
		. = TRUE
