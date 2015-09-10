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
	required_organs = list(/obj/item/organ/internal/appendix)

/datum/disease/appendicitis/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/internal/appendix/A = affected_mob.getorgan(/obj/item/organ/internal/appendix)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				affected_mob << "<span class='warning'>You feel a stabbing pain in your abdomen!</span>"
				affected_mob.Stun(rand(2,3))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				if (affected_mob.nutrition > 100)
					affected_mob.Stun(rand(4,6))
					affected_mob.visible_message("<span class='danger'>[affected_mob] throws up!</span>", \
												"<span class='userdanger'>[affected_mob] throws up!</span>")
					playsound(affected_mob.loc, 'sound/effects/splat.ogg', 50, 1)
					var/turf/location = affected_mob.loc
					if(istype(location, /turf/simulated))
						location.add_vomit_floor(affected_mob)
					affected_mob.nutrition -= 95
					affected_mob.adjustToxLoss(-1)
				else
					affected_mob << "<span class='userdanger'>You gag as you want to throw up, but there's nothing in your stomach!</span>"
					affected_mob.Weaken(10)
					affected_mob.adjustToxLoss(3)

