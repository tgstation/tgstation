/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 3
	cure_text = "Surgery"
	agent = "Shitty Appendix"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will become very weak, and may vomit often."
	severity = "Dangerous!"
	longevity = 1000
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/appendix)

/datum/disease/appendicitis/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/appendix/A = affected_mob.getorgan(/obj/item/organ/appendix)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'>You feel a stabbing pain in your abdomen!</span>")
				affected_mob.Stun(rand(2,3))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				affected_mob.vomit(95)
