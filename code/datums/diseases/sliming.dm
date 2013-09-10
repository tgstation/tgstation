//Turning to slime

/datum/disease/sliming
	name = "Advanced Mutation Transformation"
	max_stages = 5
	spread = "Acute"
	spread_type = SPECIAL
	cure = "An injection of frost oil."
	cure_id = list("frostoil")
	cure_chance = 80
	agent = "Advanced Mutation Toxin"
	affected_species = list("Human", "Monkey", "Alien")
	desc = "This highly concentrated extract converts anything into more of itself."
	severity = "Major"
	stage_prob = 10

/datum/disease/sliming/stage_act()
	..()
	switch(stage)
		if(1)
			if (prob(10))
				affected_mob << "You don't feel very well."
			if(ishuman(affected_mob) && affected_mob.dna && affected_mob.dna.mutantrace == "slime")
				stage = 5
		if(2)
			if (prob(10))
				affected_mob << "You are turning a little green."
		if(3)
			if (prob(20))
				affected_mob << pick("\red Your limbs are getting oozy.", "\red Your skin begins to peel away.")
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(human.dna && !human.dna.mutantrace)
					human.dna.mutantrace = "slime"
					human.update_body()
					human.update_hair()
		if(4)
			if (prob(20))
				affected_mob << "\red You are turning into a slime."
		if(5)
			if(istype(affected_mob, /mob/living/carbon) && affected_mob.stat != DEAD)
				affected_mob <<"\red You have become a slime."
				if(affected_mob.monkeyizing)	return
				affected_mob.monkeyizing = 1
				affected_mob.canmove = 0
				affected_mob.icon = null
				affected_mob.overlays.Cut()
				affected_mob.invisibility = 101
				for(var/obj/item/W in affected_mob)
					if(istype(W, /obj/item/weapon/implant))
						del(W)
						continue
					W.layer = initial(W.layer)
					W.loc = affected_mob.loc
					W.dropped(affected_mob)
				var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(affected_mob.loc)
				new_mob.a_intent = "harm"
				new_mob.universal_speak = 1
				if(affected_mob.mind)
					affected_mob.mind.transfer_to(new_mob)
				else
					new_mob.key = affected_mob.key
				del(affected_mob)