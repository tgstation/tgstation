/datum/disease/magnitis
	name = "Magnitis"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Iron"
	cures = list(/datum/reagent/iron)
	agent = "Fukkos Miracos"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 0.75
	desc = "This disease disrupts the magnetic field of your body, making it act as if a powerful magnet. Injections of iron help stabilize the field."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC|MOB_ROBOTIC
	process_dead = TRUE


/datum/disease/magnitis/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a slight shock course through your body.</span>")
			if(DT_PROB(1, delta_time))
				for(var/obj/nearby_object in orange(2, affected_mob))
					if(nearby_object.anchored || !(nearby_object.flags_1 & CONDUCT_1))
						continue
					var/move_dir = get_dir(nearby_object, affected_mob)
					nearby_object.Move(get_step(nearby_object, move_dir), move_dir)
				for(var/mob/living/silicon/nearby_silicon in orange(2, affected_mob))
					if(isAI(nearby_silicon))
						continue
					var/move_dir = get_dir(nearby_silicon, affected_mob)
					nearby_silicon.Move(get_step(nearby_silicon, move_dir), move_dir)
		if(3)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a strong shock course through your body.</span>")
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel like clowning around.</span>")
			if(DT_PROB(2, delta_time))
				for(var/obj/nearby_object in orange(4, affected_mob))
					if(nearby_object.anchored || !(nearby_object.flags_1 & CONDUCT_1))
						continue
					for(var/i in 1 to rand(1, 2))
						var/move_dir = get_dir(nearby_object, affected_mob)
						if(!nearby_object.Move(get_step(nearby_object, move_dir), move_dir))
							break
				for(var/mob/living/silicon/nearby_silicon in orange(4, affected_mob))
					if(isAI(nearby_silicon))
						continue
					for(var/i in 1 to rand(1, 2))
						var/move_dir = get_dir(nearby_silicon, affected_mob)
						if(!nearby_silicon.Move(get_step(nearby_silicon, move_dir), move_dir))
							break
		if(4)
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You feel a powerful shock course through your body.</span>")
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, "<span class='danger'>You query upon the nature of miracles.</span>")
			if(DT_PROB(4, delta_time))
				for(var/obj/nearby_object in orange(6, affected_mob))
					if(nearby_object.anchored || !(nearby_object.flags_1 & CONDUCT_1))
						continue
					for(var/i in 1 to rand(1, 3))
						var/move_dir = get_dir(nearby_object, affected_mob)
						if(!nearby_object.Move(get_step(nearby_object, move_dir), move_dir))
							break
				for(var/mob/living/silicon/nearby_silicon in orange(6, affected_mob))
					if(isAI(nearby_silicon))
						continue
					for(var/i in 1 to rand(1, 3))
						var/move_dir = get_dir(nearby_silicon, affected_mob)
						if(!nearby_silicon.Move(get_step(nearby_silicon, move_dir), move_dir))
							break
