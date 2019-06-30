/datum/reagent/holywater/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M) && is_vampire(M) && prob(80))
		var/datum/antagonist/vampire/V = M.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V.get_ability(/datum/vampire_passive/full))
			switch(current_cycle)
				if(1 to 4)
					to_chat(M, "<span class='warning'>Something sizzles in your veins!</span>")
					M.adjustFireLoss(0.5)
				if(5 to 12)
					to_chat(M, "<span class='danger'>You feel an intense burning inside of you!</span>")
					M.adjustFireLoss(1)
				if(13 to INFINITY)
					M.visible_message("<span class='danger'>[M] suddenly bursts into flames!<span>", "<span class='userdanger'>You suddenly ignite in a holy fire!</span>")
					M.adjust_fire_stacks(3)
					M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					M.adjustFireLoss(3)		//Hence the other damages... ain't I a bastard?

/datum/reagent/cluwnification
	name = "Cluwne Tears"
	description = "Tears from thousands of cluwnes compressed into a dangerous cluwnification virus."
	color = "#535E66" // rgb: 62, 224, 33
	can_synth = FALSE
	taste_description = "something funny"

/datum/reagent/cluwnification/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/cluwnification(), FALSE, TRUE)
