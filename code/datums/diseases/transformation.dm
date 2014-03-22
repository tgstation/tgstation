/datum/disease/transformation

	name = "Transformation"
	max_stages = 5
	spread = "Acute"
	spread_type = SPECIAL
	cure = "A coder's love (theoretical)."
	agent = "Shenanigans"
	affected_species = list("Human", "Monkey", "Alien")
	severity = "Major"
	stage_prob = 10
	hidden = list(1, 1)
	var/list/stage1 = list("You feel unremarkable.")
	var/list/stage2 = list("You feel boring.")
	var/list/stage3 = list("You feel utterly plain.")
	var/list/stage4 = list("You feel white bread.")
	var/list/stage5 = list("Oh the humanity!")
	var/new_form = /mob/living/carbon/human

/datum/disease/transformation/stage_act()
	..()
	switch(stage)
		if(1)
			if (prob(10) && stage1)
				affected_mob << pick(stage1)
		if(2)
			if (prob(10) && stage2)
				affected_mob << pick(stage2)
		if(3)
			if (prob(20) && stage3)
				affected_mob << pick(stage3)
		if(4)
			if (prob(20) && stage4)
				affected_mob << pick(stage4)
		if(5)
			if(istype(affected_mob, /mob/living/carbon) && affected_mob.stat != DEAD)
				if(stage5)
					affected_mob << pick(stage5)
				if(jobban_isbanned(affected_mob, new_form))
					affected_mob.death(1)
					return
				if(affected_mob.notransform)	return
				affected_mob.notransform = 1
				affected_mob.canmove = 0
				affected_mob.icon = null
				affected_mob.overlays.Cut()
				affected_mob.invisibility = 101
				for(var/obj/item/W in affected_mob)
					if(istype(W, /obj/item/weapon/implant))
						qdel(W)
						continue
					W.layer = initial(W.layer)
					W.loc = affected_mob.loc
					W.dropped(affected_mob)
				var/mob/living/new_mob = new new_form(affected_mob.loc)
				if(istype(new_mob))
					new_mob.a_intent = "harm"
					new_mob.universal_speak = 1
					if(affected_mob.mind)
						affected_mob.mind.transfer_to(new_mob)
					else
						new_mob.key = affected_mob.key
				qdel(affected_mob)


/datum/disease/transformation/robot

	name = "Robotic Transformation"
	cure = "An injection of copper."
	cure_id = list("copper")
	cure_chance = 5
	agent = "R2D2 Nanomachines"
	desc = "This disease, actually acute nanomachine infection, converts the victim into a cyborg."
	hidden = list(0, 0)
	stage1	= list("")
	stage2	= list("Your joints feel stiff.", "\red Beep...boop..")
	stage3	= list("\red Your joints feel very stiff.", "Your skin feels loose.", "\red You can feel something move...inside.")
	stage4	= list("\red Your skin feels very loose.", "\red You can feel... something...inside you.")
	stage5	= list("\red Your skin feels as if it's about to burst off!")
	new_form = /mob/living/silicon/robot

/datum/disease/transformation/robot/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.Paralyse(2)
		if(4)
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))


/datum/disease/transformation/xeno

	name = "Xenomorph Transformation"
	cure = "Spaceacillin & Glycerol"
	cure_id = list("spaceacillin", "glycerol")
	cure_chance = 5
	agent = "Rip-LEY Alien Microbes"
	hidden = list(0, 0)
	stage1	= list("")
	stage2	= list("Your throat feels scratchy.", "\red Kill...")
	stage3	= list("\red Your throat feels very scratchy.", "Your skin feels tight.", "\red You can feel something move...inside.")
	stage4	= list("\red Your skin feels very tight.", "\red Your blood boils!", "\red You can feel... something...inside you.")
	stage5	= list("\red Your skin feels as if it's about to burst off!")
	new_form = /mob/living/carbon/alien/humanoid/hunter

/datum/disease/transformation/xeno/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.Paralyse(2)
		if(4)
			if (prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))


/datum/disease/transformation/slime
	name = "Advanced Mutation Transformation"
	cure = "frost oil"
	cure_id = list("frostoil")
	cure_chance = 80
	agent = "Advanced Mutation Toxin"
	desc = "This highly concentrated extract converts anything into more of itself."
	hidden = list(0, 0)
	stage1	= list("You don't feel very well.")
	stage2	= list("You are turning a little green.")
	stage3	= list("\red Your limbs are getting oozy.", "\red Your skin begins to peel away.")
	stage4	= list("\red You are turning into a slime.")
	stage5	= list("\red You have become a slime.")
	new_form = /mob/living/carbon/slime

/datum/disease/transformation/slime/stage_act()
	..()
	switch(stage)
		if(1)
			if(ishuman(affected_mob) && affected_mob.dna && affected_mob.dna.mutantrace == "slime")
				stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(human.dna && !human.dna.mutantrace)
					human.dna.mutantrace = "slime"
					human.update_body()


/datum/disease/transformation/corgi
	name = "The Barkening"
	cure = "Death"
	agent = "Fell Doge Majicks"
	hidden = list(0, 0)
	stage1	= list("BARK.")
	stage2	= list("You feel the need to wear silly hats.")
	stage3	= list("\red Must... eat... chocolate....", "\red YAP")
	stage4	= list("\red Visions of washing machines assail your mind!")
	stage5	= list("\red AUUUUUU!!!")
	new_form = /mob/living/simple_animal/corgi

/datum/disease/transformation/corgi/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(8))
				affected_mob.say(pick("YAP", "Woof!"))
		if(4)
			if (prob(20))
				affected_mob.say(pick("Bark!", "AUUUUUU"))
