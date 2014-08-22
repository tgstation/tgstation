/datum/disease2/effectholder
	var/name = "Holder"
	var/datum/disease2/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/cure = "" //Type of cure it requires
	var/happensonce = 0
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 0
	var/datum/disease2/disease/virus

/datum/disease2/effectholder/New(var/datum/disease2/disease/D)
	virus=D

/datum/disease2/effectholder/proc/runeffect(var/mob/living/carbon/human/mob,var/stage)
	if(happensonce > -1 && effect.stage <= stage && prob(chance))
		effect.activate(mob)
		if(happensonce == 1)
			happensonce = -1

/datum/disease2/effectholder/proc/getrandomeffect(var/badness = 1)
	if(effect)
		virus.log += "<br />[timestamp()] Effect [effect.name] [chance]% is now "
	else
		virus.log += "<br />[timestamp()] Added effect "
	var/list/datum/disease2/effect/list = list()
	for(var/e in (typesof(/datum/disease2/effect) - /datum/disease2/effect))
		var/datum/disease2/effect/f = new e
		if (f.badness > badness)	//we don't want such strong effects
			continue
		if(f.stage == src.stage)
			list += f
	effect = pick(list)
	chance = rand(1,6)
	virus.log += "[effect.name] [chance]%:"

/datum/disease2/effectholder/proc/minormutate()
	switch(pick(1,2,3,4,5))
		if(1)
			chance = rand(0,effect.chance_maxm)
		if(2)
			multiplier = rand(1,effect.maxm)

/datum/disease2/effectholder/proc/majormutate()
	getrandomeffect(2)

////////////////////////////////////////////////////////////////
////////////////////////EFFECTS/////////////////////////////////
////////////////////////////////////////////////////////////////

/datum/disease2/effect
	var/chance_maxm = 50
	var/name = "Blanking effect"
	var/stage = 4
	var/maxm = 1
	var/badness = 1
	proc/activate(var/mob/living/carbon/mob,var/multiplier)
	proc/deactivate(var/mob/living/carbon/mob)

////////////////////////SPECIAL/////////////////////////////////
/*/datum/disease2/effect/alien
	name = "Unidentified Foreign Body"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "\red You feel something tearing its way out of your stomach..."
		mob.adjustToxLoss(10)
		mob.updatehealth()
		if(prob(40))
			if(mob.client)
				mob.client.mob = new/mob/living/carbon/alien/larva(mob.loc)
			else
				new/mob/living/carbon/alien/larva(mob.loc)
			var/datum/disease2/disease/D = mob:virus2
			mob:gib()
			del D*/

/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		return



////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	stage = 4
	badness = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.gib()

/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	stage = 4
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.radiation += (2*multiplier)

/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.ear_deaf += 20

/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	stage = 4
	badness = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob,/mob/living/carbon/human))
			var/mob/living/carbon/human/h = mob
			h.monkeyize()

/datum/disease2/effect/catbeast
	name = "Kingston Syndrome"
	stage = 4
	badness = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob,/mob/living/carbon/human))
			var/mob/living/carbon/human/h = mob
			if(h.species.name != "Tajaran")
				if(h.set_species("Tajaran"))
					h.regenerate_icons()

/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	stage = 4
	badness = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		viewers(mob) << "\red <b>[mob.name] is holding \his breath. It looks like \he's trying to commit suicide.</b>"
		mob.adjustOxyLoss(175 - mob.getToxLoss() - mob.getFireLoss() - mob.getBruteLoss() - mob.getOxyLoss())
		mob.updatehealth()
		spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
			mob.suiciding = 0

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.adjustToxLoss(15*multiplier)

/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.bodytemperature = max(mob.bodytemperature, 350)
		scramble(0,mob,10)
		mob.apply_damage(10, CLONE)

/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			var/organ = pick(list("r_arm","l_arm","r_leg","r_leg"))
			var/datum/organ/external/E = H.organs_by_name[organ]
			if (!(E.status & ORGAN_DEAD))
				E.status |= ORGAN_DEAD
				H << "<span class='notice'>You can't feel your [E.display_name] anymore...</span>"
				for (var/datum/organ/external/C in E.children)
					C.status |= ORGAN_DEAD
			H.update_body(1)
			if(multiplier < 1) multiplier = 1
			H.adjustToxLoss(15*multiplier)
	vampire
		stage = 3


	deactivate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				E.status &= ~ORGAN_DEAD
				for (var/datum/organ/external/C in E.children)
					C.status &= ~ORGAN_DEAD
			H.update_body(1)




/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				if (E.status & ORGAN_BROKEN && prob(30))
					E.status ^= ORGAN_BROKEN
		var/heal_amt = -5*multiplier
		mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

	deactivate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			H << "<span class='notice'>You suddenly feel hurt and old...</span>"
			H.age += 8
		var/backlash_amt = 5*multiplier
		mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)


/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				E.min_broken_damage = max(5, E.min_broken_damage - 30)

	deactivate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				E.min_broken_damage = initial(E.min_broken_damage)

/datum/disease2/effect/scc
	name = "Spontaneous Cellular Collapse"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		//
		var/mob/living/carbon/human/H = mob
		mob.reagents.add_reagent("pacid", 10)
		mob << "<span class = 'warning'> Your body burns as your cells break down.</span>"
		shake_camera(mob,5*multiplier)

		for (var/datum/organ/external/E in H.organs)
			if(pick(1,0))
				//
				E.createwound(CUT, pick(2,4,6,8,10))
				E.fracture()





/datum/disease2/effect/necrosis
	name = "Necrosis"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		//
		var/mob/living/carbon/human/H = mob
			//
		var/inst = pick(1,2,3)
		switch(inst)
			if(1)
				mob << "<span class = 'warning'>A chunk of meat falls off you!</span>"
				var/totalslabs = 1
				var/obj/item/weapon/reagent_containers/food/snacks/meat/allmeat[totalslabs]
				if( istype(mob, /mob/living/carbon/human/) )
						//
					var/sourcename = mob.real_name
					var/sourcejob = mob.job
					var/sourcenutriment = mob.nutrition / 15
					//var/sourcetotalreagents = mob.reagents.total_volume

					for(var/i=1 to totalslabs)
						var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new
						newmeat.name = sourcename + newmeat.name
						newmeat.subjectname = sourcename
						newmeat.subjectjob = sourcejob
						newmeat.reagents.add_reagent("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
						//src.occupant.reagents.trans_to(newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
						allmeat[i] = newmeat



						var/obj/item/meatslab = allmeat[i]
						var/turf/Tx = locate(mob.x, mob.y, mob.z)
						meatslab.loc = mob.loc
						meatslab.throw_at(Tx,i,3)
						if (!Tx.density)
							new /obj/effect/decal/cleanable/blood/gibs(Tx,i)


			if(2)
				//mob << "\red i dont think i need this here"

				for (var/datum/organ/external/E in H.organs)
					if(pick(1,0))
						E.droplimb(1)


			if(3)
				if(H.species.name != "Skellington")
					mob << "<span class = 'warning'> Your necrotic skin ruptures!</span>"


					for (var/datum/organ/external/E in H.organs)
						if(pick(1,0))
							E.createwound(CUT, pick(2,4,6,8,10))


					if(prob(30))
						//

						if(H.species.name != "Skellington")
							if(H.set_species("Skellington"))
								mob << "<span class = 'warning'> A massive amount of flesh sloughs off your bones!</span>"
								H.regenerate_icons()
				else
					return





/datum/disease2/effect/fizzle
	name = "Fizzle Effect"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.emote("me",1,pick("sniffles...", "clears their throat..."))





/datum/disease2/effect/spawn
	name = "Arachnogenesis Effect"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		//var/mob/living/carbon/human/H = mob
		var/placemob = locate(mob.x + pick(1,-1), mob.y, mob.z)
		playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)

		new /mob/living/simple_animal/hostile/giant_spider/spiderling(placemob)
		mob.emote("me",1,"vomits up a live spiderling!")



/datum/disease2/effect/orbweapon
	name = "Biolobulin Effect"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		//

		var/obj/item/toy/snappop/virus = new /obj/item/toy/snappop/virus
		mob.equip_to_slot(virus, slot_l_hand)



/obj/item/clothing/mask/gas/virusclown_hat

	dropped(mob/user as mob)
		canremove = 1
		..()

	equipped(var/mob/user, var/slot)
		if (slot == slot_l_hand)
			canremove = 1		//curses!
		..()




/datum/disease2/effect/plasma
	name = "Toxin Sublimation"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		//var/src = mob
		var/hack = mob.loc
		var/turf/simulated/T = get_turf(hack)
		if(!T)
			return
		var/datum/gas_mixture/GM = new
		if(prob(10))
			GM.toxins += 100
			//GM.temperature = 1500+T0C //should be enough to start a fire
			mob << "\red You exhale a large plume of toxic gas!"
		else
			GM.toxins += 10
			GM.temperature = istype(T) ? T.air.temperature : T20C
			mob << "<span class = 'warning'> A toxic gas emanates from your pores!</span>"
		T.assume_air(GM)
		return





////////////////////////STAGE 3/////////////////////////////////





/datum/disease2/effect/toxins
	name = "Hyperacidity"
	stage = 3
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.adjustToxLoss((2*multiplier))

/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	stage = 3
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		shake_camera(mob,5*multiplier)

/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.dna.check_integrity()
		mob.dna.SetSEState(REMOTETALKBLOCK,1)
		domutcheck(mob, null)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			var/datum/organ/internal/brain/B = H.internal_organs["brain"]
			B.take_damage(5)
		else
			mob.setBrainLoss(50)

/datum/disease2/effect/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.hallucination += 25

/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.ear_deaf = 5

/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*giggle")

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>"
		mob.confused += 10

/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.apply_damage(2, CLONE)


/datum/disease2/effect/groan
	name = "Groaning Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*groan")





/datum/disease2/effect/sweat
	name = "Hyper-perspiration Effect"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(prob(30))
			mob.emote("me",1,"is sweating profusely!")

			if(istype(mob.loc,/turf/simulated))
				var/turf/simulated/T = mob.loc
				if(T.wet < 1)
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay
					spawn(800)
						if (istype(T) && T.wet < 2)
							T.wet = 0
							if(T.wet_overlay)
								T.overlays -= T.wet_overlay
								T.wet_overlay = null







/datum/disease2/effect/elvis
	name = "Elvisism"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		//
		var/obj/item/clothing/glasses/virussunglasses = new /obj/item/clothing/glasses/virussunglasses
		mob.equip_to_slot(virussunglasses, slot_glasses)
		mob.confused += 10




		if(pick(0,1))
			mob.say(pick("Uh HUH!", "Thank you, Thank you very much...", "I ain't nothin' but a hound dog!", "Swing low, sweet chariot!"))
		else
			mob.emote("me",1,pick("curls his lip!", "gyrates his hips!", "thrusts his hips!"))

		if(istype(mob, /mob/living/carbon/human))

			var/mob/living/carbon/human/H = mob
			if(H.species.name == "Human" && !(H.f_style == "Pompadour"))
				spawn(50)
					H.h_style = "Pompadour"
					H.update_hair()



			if(H.species.name == "Human" && !(H.f_style == "Elvis Sideburns"))
				spawn(50)
					H.f_style = "Elvis Sideburns"
					H.update_hair()



/obj/item/clothing/glasses/virussunglasses

	dropped(mob/user as mob)
		canremove = 1
		..()

	equipped(var/mob/user, var/slot)
		if (slot == slot_glasses)
			canremove = 0		//curses!
		..()








/datum/disease2/effect/pthroat
	name = "Pierrot's Throat"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		//
		var/obj/item/clothing/mask/gas/virusclown_hat = new /obj/item/clothing/mask/gas/virusclown_hat
		mob.equip_to_slot(virusclown_hat, slot_wear_mask)
		mob.reagents.add_reagent("psilocybin", 20)
		mob.say(pick("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk..."))



/obj/item/clothing/mask/gas/virusclown_hat

	dropped(mob/user as mob)
		canremove = 1
		..()

	equipped(var/mob/user, var/slot)
		if (slot == slot_wear_mask)
			canremove = 0		//curses!
		..()





var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
/datum/disease2/effect/horsethroat
	name = "Horse Throat"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)


		if(!(mob.type in compatible_mobs))
			return


		var/obj/item/clothing/mask/horsehead/magic/magichead = new /obj/item/clothing/mask/horsehead/magic
		mob.equip_to_slot(magichead, slot_wear_mask)
		mob << "<span class='warning'>You feel a little horse!</span>"


/obj/item/clothing/mask/horsehead/magic
	//flags_inv = null	//so you can still see their face... no. How can you recognize someone when their face is completely different?
	voicechange = 1		//NEEEEIIGHH

	dropped(mob/user as mob)
		canremove = 1
		..()

	equipped(var/mob/user, var/slot)
		if (slot == slot_wear_mask)
			canremove = 0		//curses!
		..()





/datum/disease2/effect/spaceadapt
	name = "Space Adaptation Effect"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		var/mob/living/carbon/human/H = mob
		if (mob.reagents.get_reagent_amount("dexalinp") < 10)
			mob.reagents.add_reagent("dexalinp", 4)
		if (mob.reagents.get_reagent_amount("leporazine") < 10)
			mob.reagents.add_reagent("leporazine", 4)
		if (mob.reagents.get_reagent_amount("bicaridine") < 10)
			mob.reagents.add_reagent("bicaridine", 4)
		if (mob.reagents.get_reagent_amount("dermaline") < 10)
			mob.reagents.add_reagent("dermaline", 4)
		mob.emote("me",1,"exhales slowly.")

		var/datum/organ/external/chest/chest = H.get_organ("chest")
		for(var/datum/organ/internal/I in chest.internal_organs)
			I.damage = 0


////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*scream")

/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.drowsyness += 10

/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*collapse")

/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.eye_blind = max(mob.eye_blind, 4)

/datum/disease2/effect/cough
	name = "Anima Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*cough")
		for(var/mob/living/carbon/M in oview(2,mob))
			mob.spread_disease_to(M)

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.nutrition = max(0, mob.nutrition - 200)

/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*shiver")

/datum/disease2/effect/hair
	name = "Hair Loss"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			if(H.species.name == "Human" && !(H.h_style == "Bald") && !(H.h_style == "Balding Hair"))
				H << "<span class='danger'>Your hair starts to fall out in clumps...</span>"
				spawn(50)
					H.h_style = "Balding Hair"
					H.update_hair()

/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class='notice'>You feel a rush of energy inside you!</span>"
		if (mob.reagents.get_reagent_amount("hyperzine") < 10)
			mob.reagents.add_reagent("hyperzine", 4)
		if (prob(30))
			mob.jitteriness += 10

/datum/disease2/effect/drunk
	name = "Glasgow Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class='notice'>You feel like you had one hell of a party!</span>"
		if (mob.reagents.get_reagent_amount("ethanol") < 325)
			mob.reagents.add_reagent("ethanol", 5*multiplier)

/datum/disease2/effect/gaben
	name = "Gaben Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class='notice'>Your clothing fits a little tighter!!</span>"
		if (prob(10))
			mob.reagents.add_reagent("nutriment", 1000)
			mob.overeatduration = 1000



/datum/disease2/effect/beard
	name = "Bearding"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			if(H.species.name == "Human" && !(H.f_style == "Full Beard"))
				H << "<span class='warning'>Your chin and neck itch!.</span>"
				spawn(50)
					H.f_style = "Full Beard"
					H.update_hair()






/datum/disease2/effect/bloodynose
	name = "Intranasal Hemorrhage"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		if (prob(30))
			var/obj/effect/decal/cleanable/blood/D= locate(/obj/effect/decal/cleanable/blood) in get_turf(mob)
			if(D==null)
				D = new(get_turf(mob))

			D.virus2 |= virus_copylist(mob.virus2)







/datum/disease2/effect/viralsputum
	name = "Respiratory Putrification"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)

		if (prob(30))
			mob.say("*cough")
			var/obj/effect/decal/cleanable/blood/viralsputum/D= locate(/obj/effect/decal/cleanable/blood/viralsputum) in get_turf(mob)
			if(D==null)
				D = new(get_turf(mob))

			D.virus2 |= virus_copylist(mob.virus2)




/datum/disease2/effect/lantern
	name = "Lantern Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.SetLuminosity(4)
		mob << "<span class = 'notice'>You are glowing!</span>"



////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*sneeze")
		if (prob(50))
			var/obj/effect/decal/cleanable/mucus/M= locate(/obj/effect/decal/cleanable/mucus) in get_turf(mob)
			if(M==null)
				M = new(get_turf(mob))
			else
				if(M.dry)
					M.dry=0
			M.virus2 |= virus_copylist(mob.virus2)

/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class = 'notice'> Mucous runs down the back of your throat.</span>"

/datum/disease2/effect/drool
	name = "Saliva Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*drool")

/datum/disease2/effect/twitch
	name = "Twitcher"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*twitch")

/datum/disease2/effect/headache
	name = "Headache"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class = 'notice'> Your head hurts a bit</span>"

/datum/disease2/effect/itching
	name = "Itching"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class='warning'>Your skin itches!</span>"

/datum/disease2/effect/drained
	name = "Drained Feeling"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class='warning'>You feel drained.</span>"

/datum/disease2/effect/eyewater
	name = "Watery Eyes"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<SPAN CLASS='warning'>Your eyes sting and water!</SPAN>"

/datum/disease2/effect/wheeze
	name = "Wheezing"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.emote("me",1,"wheezes.")


/datum/disease2/effect/optimistic
	name = "Full Glass Syndrome"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "<span class = 'notice'> You feel optimistic!</span>"
		if (mob.reagents.get_reagent_amount("tricordrazine") < 1)
			mob.reagents.add_reagent("tricordrazine", 1)