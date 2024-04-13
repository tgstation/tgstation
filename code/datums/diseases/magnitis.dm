/datum/disease/magnitis
	name = "Magnitis"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Iron"
	cures = list(/datum/reagent/iron)
	agent = "Fukkos Miracos"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	spreading_modifier = 0.75
	desc = "This disease disrupts the magnetic field of your body, making it act as if a powerful magnet. Injections of iron help stabilize the field."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC|MOB_ROBOTIC
	bypasses_immunity = TRUE
	process_dead = TRUE


/datum/disease/magnitis/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your skin tingles with energy."))
			if(SPT_PROB(1, seconds_per_tick))
				for(var/obj/nearby_object in orange(2, affected_mob))
					if(nearby_object.anchored || !(nearby_object.obj_flags & CONDUCTS_ELECTRICITY))
						continue
					var/move_dir = get_dir(nearby_object, affected_mob)
					nearby_object.Move(get_step(nearby_object, move_dir), move_dir)
				for(var/mob/living/silicon/nearby_silicon in orange(2, affected_mob))
					if(isAI(nearby_silicon))
						continue
					var/move_dir = get_dir(nearby_silicon, affected_mob)
					nearby_silicon.Move(get_step(nearby_silicon, move_dir), move_dir)
		if(3)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your hair stands on end."))
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel a light shock course through your body."))
				for(var/obj/nearby_object in orange(4, affected_mob))
					if(nearby_object.anchored || !(nearby_object.obj_flags & CONDUCTS_ELECTRICITY))
						continue
					for(var/i in 1 to rand(1, 2))
						nearby_object.throw_at(affected_mob, 4, 3)
				for(var/mob/living/silicon/nearby_silicon in orange(4, affected_mob))
					if(isAI(nearby_silicon))
						continue
					for(var/i in 1 to rand(1, 2))
						nearby_silicon.throw_at(affected_mob, 4, 3)
		if(4)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("You query upon the nature of miracles."))
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_danger("You feel a powerful shock course through your body."))
				for(var/obj/nearby_object in orange(6, affected_mob))
					if(nearby_object.anchored || !(nearby_object.obj_flags & CONDUCTS_ELECTRICITY))
						continue
					for(var/i in 1 to rand(1, 3))
						nearby_object.throw_at(affected_mob, 6, 5) // I really wanted to use addtimers to stagger out when everything gets thrown but it would probably cause a lot of lag.
				for(var/mob/living/silicon/nearby_silicon in orange(6, affected_mob))
					if(isAI(nearby_silicon))
						continue
					for(var/i in 1 to rand(1, 3))
						nearby_silicon.throw_at(affected_mob, 6, 5)
