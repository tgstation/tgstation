/datum/experiment_type/heat
	name = "Burn"

/datum/experiment/coffee/heater_fail
	weight = 20
	experiment_type = /datum/experiment_type/destroy
	base_points = 250
	valid_reagents = list("plasma","capsaicin","ethanol")

/datum/experiment/coffee/heater_fail/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(.)
		E.visible_message("<span class='warning'>[E]'s heating system gives off a small ding!</span>")
		playsound(E, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!