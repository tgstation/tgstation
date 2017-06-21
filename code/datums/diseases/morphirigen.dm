/datum/disease/morph
	name = "Morphirigen"
	max_stages = 6
	spread_text = "Non-contagious"
	spread_flags = NON_CONTAGIOUS
	cure_text = "Death"
	cures = list()
	cure_chance = 0 //Only giveable through 20TC traitor item or admin shenanigans, uncureable
	agent = "Morph Spore"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST
	permeability_mod = 1
	severity = BIOHAZARD
  
/datum/disease/morph/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>You feel your insides shifting...</span>")
			if(prob(18))
				affected_mob.vomit(95) //no idea what the 95 does, I just copy/pasted
		if(3)
			if(prob(12))
				affected_mob.visible_message("<span class='danger'>[affected_mob]'s stomach uncontrollably sucks in and out!</span>", "<span class='danger'>Your stomach uncontrollably sucks in and out!</span>")
				affected_mob.vomit(80)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your insides shift violently! You can't take it!</span>")
				affected_mob.vomit(45)
				affected_mob.Weaken(rand(10,25))
		if(4)
			if(prob(20))
				affected_mob.visible_message("<span class='danger'>[affected_mob]'s muscles flex and shift violently!</span>", "<span class='danger'>All your muscles flex and shift violently!</span>")
				affected_mob.Weaken(rand(20,37))
				affected_mob.emote("scream")
		if(5)
			if(prob(13))
				to_chat(affected_mob, "<span class='danger'>You feel more at ease now...</span>")
			if(prob(17))
				to_chat(affected_mob, "<span class='danger'>A murderous hunger begins to creep into your mind...</span>")
		if(6)
			if(prob(50))
				to_chat(affected_mob, "<span class='danger'>You roar in pain as your body goes underforth a violent transformation...</span>")
				affected_mob.Weaken(50)
				affected_mob.emote("scream")
				affected_mob.emote("groan")
				to_chat(affected_mob, "<span class='cult'>Our weak, fragile, old body explodes into gore as we shift into our new, powerful body!</span>")
				var/mob/living/simple_animal/hostile/morph/NewMorph = new(get_turf(affected_mob)) 
				affected_mob.mind.transfer_to(NewMorph);
				affected_mob.gib()
    
      
