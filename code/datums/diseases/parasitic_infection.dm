/datum/disease/parasite
	form = "Parasite"
	name = "Parasitic Infection"
	max_stages = 4
	cure_text = "Surgical removal of the liver."
	agent = "Consuming Live Parasites"
	spread_text = "Non-Biological"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will passively lose nutrients, and eventually lose their liver."
	severity = DISEASE_SEVERITY_HARMFUL
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	required_organs = list(/obj/item/organ/liver)
	bypasses_immunity = TRUE

/datum/disease/parasite/stage_act()
	. = ..()
	var/mob/living/carbon/C = affected_mob
	var/obj/item/organ/liver/L = C.getorgan(/obj/item/organ/liver)
	if(!L)
		src.cure()
		C.visible_message("<span class='notice'><B>[C]'s liver is covered in tiny larva! They quickly shrivel and die after being exposed to the open air.</B></span>")
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			if(prob(10))
				if(prob(50))
					to_chat(affected_mob, "<span class='notice'>You feel the weight loss already!</span>")
				affected_mob.adjust_nutrition(-3)
		if(3)
			if(prob(20))
				if(prob(20))
					to_chat(affected_mob, "<span class='notice'>You're... REALLY starting to feel the weight loss.</span>")
				affected_mob.adjust_nutrition(-6)
		if(4)
			if(prob(30))
				if(affected_mob.nutrition >= 100)
					if(prob(10))
						to_chat(affected_mob, "<span class='warning'>You feel like your body's shedding weight rapidly!</span>")
					affected_mob.adjust_nutrition(-12)
				else
					var/turf/T = get_turf(C)
					to_chat(affected_mob, "<span class='warning'>You feel much, MUCH lighter!</span>")
					affected_mob.vomit(20, TRUE)
					L.Remove(C)
					L.forceMove(T)
					src.cure()
