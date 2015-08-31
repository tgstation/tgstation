/obj/machinery/plumbing
	name = "plumbing machinery"
	desc = "Some conglomeration of pipes. You don't know what it's for."
	icon = 'icons/obj/plumbing.dmi'
	icon_state = "base"
	anchored = 1
	density = 1
	use_power = 0

/obj/machinery/plumbing/chemical_synthesizer/water

/obj/machinery/plumbing/chemical_synthesizer/water/New()
	..()
	reagents.add_reagent("water", 50000)

/obj/machinery/plumbing/chemical_synthesizer
	name = "central plumbing synthesizer"
	desc = null //Different examine for plumbers
	icon_state = "synthesizer"
	var/reagent_id = "water"
	var/output_pressure = 15
	var/max_output_pressure = 100
	var/min_output_pressure = 0
	var/synth_speed = 100
	var/max_synth_speed = 1000
	var/min_synth_speed = 0

/obj/machinery/plumbing/chemical_synthesizer/New()
	..()
	create_reagents(100000) //100k - a lot!
	SSobj.processing |= src

/obj/machinery/plumbing/chemical_synthesizer/Destroy()
	SSobj.processing &= src

/obj/machinery/plumbing/chemical_synthesizer/process()
	reagents.add_reagent(reagent_id, synth_speed) //Takes a decent amount of time to fill up

/obj/machinery/plumbing/chemical_synthesizer/examine(mob/user)
	..()
	if(user.job == "Plumber")
		user << "A colossal piece of machinery used to synthesize and distribute reagents throughout the station's plumbing. It stabilizes the reagents within, preventing reactions."
		user << "A grimy dial stands at [output_pressure]."
		user << "A dirt-smeared meter is counting at [synth_speed]."
	else
		user << "A huge piece of machinery. You aren't sure what it does."
	if(synth_speed == max_synth_speed && output_pressure == max_output_pressure) //If it's all maxed out
		user << "<span class='warning'><b>The metal creaks and moans with strain!</b></span>"

/obj/machinery/plumbing/chemical_synthesizer/attack_hand(mob/user)
	if(user.job != "Plumber")
		user << "<span class='warning'>[src] is covered with random dials, valves, and screens. You aren't quite comfortable using it.</span>"
		return
	switch(input(user,"Control Terminal", "There are few options...") as null|anything in list("Change Output Pressure", "Change Synthesization Speed", "Exit"))
		if("Exit")
			return
		if("Change Output Pressure")
			output_pressure = (input(user, "Set a new pressure, from [min_output_pressure] to [max_output_pressure].", "Output Pressure", "[output_pressure]") as num)
			output_pressure = Clamp(output_pressure, min_output_pressure, max_output_pressure)
			return
		if("Change Synthesization Speed")
			synth_speed = (input(user, "Set a new synthesization speed, from [min_synth_speed] to [max_synth_speed].", "Synth Speed", "[synth_speed]") as num)
			synth_speed = Clamp(synth_speed, min_synth_speed, max_synth_speed)
			return

/obj/machinery/plumbing/chemical_synthesizer/attackby(obj/O, mob/user, params)
	if(O.reagents)
		if(!O.reagents.len)
			return
		var/list/new_possible_reagents
		for(var/datum/reagent/R in O.reagents)
			new_possible_reagents.Add(R.id)
		if(!new_possible_reagents.len)
			return ..()
		new_possible_reagents.Add("\[EXIT\]")
		var/choice = input(user, "Reagent Control", "Which reagent would you like to synthesize?") as null|anything in new_possible_reagents
		switch(choice)
			if("\[EXIT\]")
				return
			else
				reagent_id = choice
		return
	..()
