/datum/experiment_type/poke
	name = "Poke"

/datum/experiment/lash
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/lash/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] malfunctions and destroys [O], lashing its arms out at nearby people!</span>")
	for(var/mob/living/m in oview(1, E))
		m.apply_damage(15, BRUTE, pick("head","chest","groin"))
		E.investigate_log("[E] dealt minor brute to [m].", INVESTIGATE_EXPERIMENTOR)
		. = TRUE
	E.destroyItem()

/datum/experiment/instead_obliterate
	weight = 35
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/instead_obliterate/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[src] malfunctions!</span>")
	E.perform_experiment(/datum/experiment_type/destroy)

/datum/experiment/throw_item
	weight = 50
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/throw_item/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] malfunctions, throwing the [O]!</span>")
	var/mob/living/target = locate(/mob/living) in oview(7,E)
	if(target)
		E.investigate_log("[E] has thrown [O] at [target]", INVESTIGATE_EXPERIMENTOR)
		E.ejectItem()
		O.throw_at(target, 10, 1)