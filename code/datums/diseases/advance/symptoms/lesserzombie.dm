/datum/disease/lesserzombie
	name = "Andromeda blobitis"
	max_stages = 15
	spread_text = "Consumption of or contact with invasive organic material"
	cure_text = "Phenol and Mannitol, or Atropine"
	cures = list("phenol", "mannitol")
	cures = list("atropine")
	agent = "Haemophilic Andromeda Blobitic necrosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Related to mind control blob spores. The subject will slowly lose control of their body and mind to the virus, causing self inflicted harm, cognitive function, and lethal blood loss."
	severity = BIOHAZARD

/datum/disease/lesserzombie/stage_act()
	..()
	switch(stage)
		if(2,4,6)
			affected_mob << "<span class='notice'>[pick("You momentarily lose control of your eyebrows.", "You impulsively pinch yourself.", "You almost bite your tongue.", "You lick your lips, for no reason")]</span>"
		if(7)
			affected_mob << "<span class='notice'>Something is trying to control you.</span>"
		if(8)
			affected_mob << "<span class='warning'>You feel a numbing coldness and difficulty controlling your body, but you fight on.</span>"
		if(9,10)
			affected_mob.say(pick(list("Look at me!", "smh tbh fam", "yfw mfw tfw", "I'm an employee!", "Bonk!", "Hue... Hue hue", "Nothing to see here, just me!") ) )
			affected_mob.emote("wave")
			affected_mob.visible_message("<span class='danger'>[affected_mob] starts hurting themselves! It looks like they're losing control of themselves!</span>")
			affected_mob.adjustBruteLoss(10)
		if(11)
			affected_mob << "<span class='danger'>You begin to feel really numb, and [pick("unwilling to fight on", "start manually breathing")].</span>"
			affected_mob.adjustBruteLoss(10)
		if(12)
			affected_mob << "<span class='danger'>Small butterflies begin surrounding your vision, and you [pick("feel unable to control yourself", "start breathing, manually")].</span>"
			affected_mob.adjustBrainLoss(5)
			affected_mob.adjustBruteLoss(10)
		if(13)
			affected_mob << "<span class='userdanger'>You've almost lost control of yourself.</span>"
			affected_mob.adjustBrainLoss(20)
			affected_mob.adjustBruteLoss(10)
		if(14)
			affected_mob.say(pick(list("CAPTAIN. I CAN WALK!", "I live and die by your orders HOS", "Tell the RD to suck a lemon.", "CMO, I never asked for this", "Let the HOP decide ", "Chaplain... Don't scatter my ashes to the cold, heartless space", "Tell the CE to get the shuttle called!") ) )
			affected_mob.emote("salute")
			affected_mob.visible_message("<span class='notice'>[affected_mob] suddenly salutes!</span>")
			affected_mob.drop_item()
			affected_mob.emote("collapse")
			affected_mob.visible_message("<span class='danger'>[affected_mob] collapses and starts bleeding from the ears, eyes, and nose!</span>")
			affected_mob.reagents.add_reagent("heparin", 90)
			affected_mob.adjustBrainLoss(69)
			stage = 15
		if(15)
			affected_mob.adjustBruteLoss(200)
			if(affected_mob.stat == DEAD)
				affected_mob.visible_message("<span class='danger'>The corpse of [affected_mob] suddenly rises!</span>")
				var/mob/living/simple_animal/hostile/blob/blobspore/B = new(get_turf(affected_mob))
				B.Zombify(affected_mob)
				cure()