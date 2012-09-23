/obj/virus
	// a virus instance that is placed on the map, moves, and infects
	invisibility = INVISIBILITY_MAXIMUM

	var/datum/disease2/disease

	New()
		..()
		step_rand(src)
		step_rand(src)
		anchored = 1
		spawn(300) del(src)

/mob/living/carbon/proc/get_infection_chance()
	var/score = 0
	var/mob/living/carbon/M = src
	if(istype(M, /mob/living/carbon/human))
		if(M:gloves)
			score += 5
		if(istype(M:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(M:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(M:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(M.wear_mask)
		score += 5
		if(istype(M:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
			score += 10
		if(M.internal)
			score += 10

	if(score >= 30)
		return 0
	else if(score == 25 && prob(99))
		return 0
	else if(score == 20 && prob(95))
		return 0
	else if(score == 15 && prob(75))
		return 0
	else if(score == 10 && prob(55))
		return 0
	else if(score == 5 && prob(35))
		return 0

	return 1


/proc/infect_virus2(var/mob/living/carbon/M,var/datum/disease2/disease/disease,var/forced = 0)
	if(M.virus2)
		return
	if(!disease)
		return
	//immunity
	/*for(var/iii = 1, iii <= M.immunevirus2.len, iii++)
		if(disease.issame(M.immunevirus2[iii]))
			return*/

	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if(M.antibodies & disease.antigen != 0) return

	for(var/datum/disease2/resistance/res in M.resistances)
		if(res.resistsdisease(disease))
			return
	if(prob(disease.infectionchance) || forced)
		if(M.virus2)
			return
		else
			// certain clothes can prevent an infection
			if(!forced && !M.get_infection_chance())
				return

			M.virus2 = disease.getcopy()
			M.virus2.minormutate()

			for(var/datum/disease2/resistance/res in M.resistances)
				if(res.resistsdisease(M.virus2))
					M.virus2 = null



/datum/disease2/resistance
	var/list/datum/disease2/effect/resistances = list()

	proc/resistsdisease(var/datum/disease2/disease/virus2)
		var/list/res2 = list()
		for(var/datum/disease2/effect/e in resistances)
			res2 += e.type
		for(var/datum/disease2/effectholder/holder in virus2)
			if(!(holder.effect.type in res2))
				return 0
			else
				res2 -= holder.effect.type
		if(res2.len > 0)
			return 0
		else
			return 1

	New(var/datum/disease2/disease/virus2)
		for(var/datum/disease2/effectholder/h in virus2.effects)
			resistances += h.effect.type


/proc/infect_mob_random_lesser(var/mob/living/carbon/M)
	if(!M.virus2)
		M.virus2 = new /datum/disease2/disease
		M.virus2.makerandom()
		M.virus2.infectionchance = 1

/proc/infect_mob_random_greater(var/mob/living/carbon/M)
	if(!M.virus2)
		M.virus2 = new /datum/disease2/disease
		M.virus2.makerandom(1)

/datum/disease2/var/antigen = 0 // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here

/datum/disease2/disease
	var/infectionchance = 10
	var/speed = 1
	var/spreadtype = "Blood" // Can also be "Airborne"
	var/stage = 1
	var/stageprob = 10
	var/dead = 0
	var/clicks = 0

	var/uniqueID = 0
	var/list/datum/disease2/effectholder/effects = list()
	proc/makerandom(var/greater=0)
		var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
		holder.stage = 1
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		holder = new /datum/disease2/effectholder
		holder.stage = 2
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		holder = new /datum/disease2/effectholder
		holder.stage = 3
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		holder = new /datum/disease2/effectholder
		holder.stage = 4
		if(greater)
			holder.getrandomeffect_greater()
		else
			holder.getrandomeffect_lesser()
		effects += holder
		uniqueID = rand(0,10000)
		infectionchance = rand(1,10)
		// pick 2 antigens
		antigen |= text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))
		spreadtype = "Airborne"

	proc/makealien()
		var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
		holder.stage = 1
		holder.chance = 10
		holder.effect = new/datum/disease2/effect/lesser/gunck()
		effects += holder

		holder = new /datum/disease2/effectholder
		holder.stage = 2
		holder.chance = 10
		holder.effect = new/datum/disease2/effect/lesser/cough()
		effects += holder

		holder = new /datum/disease2/effectholder
		holder.stage = 3
		holder.chance = 10
		holder.effect = new/datum/disease2/effect/greater/toxins()
		effects += holder

		holder = new /datum/disease2/effectholder
		holder.stage = 4
		holder.chance = 10
		holder.effect = new/datum/disease2/effect/alien()
		effects += holder

		uniqueID = 896 // all alien diseases have the same ID
		infectionchance = 0
		spreadtype = "Airborne"

	proc/minormutate()
		var/datum/disease2/effectholder/holder = pick(effects)
		holder.minormutate()
		infectionchance = min(10,infectionchance + rand(0,1))

	proc/issame(var/datum/disease2/disease/disease)
		var/list/types = list()
		var/list/types2 = list()
		for(var/datum/disease2/effectholder/d in effects)
			types += d.effect.type
		var/equal = 1

		for(var/datum/disease2/effectholder/d in disease.effects)
			types2 += d.effect.type

		for(var/type in types)
			if(!(type in types2))
				equal = 0
		return equal

	proc/activate(var/mob/living/carbon/mob)
		if(dead)
			cure(mob)
			mob.virus2 = null
			return
		if(mob.stat == 2)
			return
		// with a certain chance, the mob may become immune to the disease before it starts properly
		if(stage <= 1 && clicks == 0)
			if(prob(20))
				mob.antibodies |= antigen // 20% immunity is a good chance IMO, because it allows finding an immune person easily
			else
		if(mob.radiation > 50)
			if(prob(1))
				majormutate()
		if(mob.reagents.has_reagent("spaceacillin"))
			mob.reagents.remove_reagent("spaceacillin",0.3)
			return
		if(mob.reagents.has_reagent("virusfood"))
			mob.reagents.remove_reagent("virusfood",0.1)
			clicks += 10
		if(clicks > stage*100 && prob(10))
			if(stage == 4)
				var/datum/disease2/resistance/res = new /datum/disease2/resistance(src)
				src.cure(mob)
				mob.resistances2 += res
				mob.antibodies |= src.antigen
				mob.virus2 = null
				del src
			stage++
			clicks = 0
		for(var/datum/disease2/effectholder/e in effects)
			e.runeffect(mob,stage)
		clicks+=speed

	proc/cure(var/mob/living/carbon/mob)
		var/datum/disease2/effectholder/E
		if(stage>1)
			E = effects[1]
			E.effect.deactivate(mob)
		if(stage>2)
			E = effects[2]
			E.effect.deactivate(mob)
		if(stage>3)
			E = effects[3]
			E.effect.deactivate(mob)
		if(stage>4)
			E = effects[4]
			E.effect.deactivate(mob)

	proc/cure_added(var/datum/disease2/resistance/res)
		if(res.resistsdisease(src))
			dead = 1

	proc/majormutate()
		var/datum/disease2/effectholder/holder = pick(effects)
		holder.majormutate()


	proc/getcopy()
//		world << "getting copy"
		var/datum/disease2/disease/disease = new /datum/disease2/disease
		disease.infectionchance = infectionchance
		disease.spreadtype = spreadtype
		disease.stageprob = stageprob
		disease.antigen   = antigen
		for(var/datum/disease2/effectholder/holder in effects)
	//		world << "adding effects"
			var/datum/disease2/effectholder/newholder = new /datum/disease2/effectholder
			newholder.effect = new holder.effect.type
			newholder.chance = holder.chance
			newholder.cure = holder.cure
			newholder.multiplier = holder.multiplier
			newholder.happensonce = holder.happensonce
			newholder.stage = holder.stage
			disease.effects += newholder
	//		world << "[newholder.effect.name]"
	//	world << "[disease]"
		return disease

/datum/disease2/effect
	var/chance_maxm = 100
	var/name = "Blanking effect"
	var/stage = 4
	var/maxm = 1
	proc/activate(var/mob/living/carbon/mob,var/multiplier)
	proc/deactivate(var/mob/living/carbon/mob)

/datum/disease2/effect/alien
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
			del D

/datum/disease2/effect/greater/gibbingtons
	name = "Gibbingtons Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.gib()

/datum/disease2/effect/greater/radian
	name = "Radian's syndrome"
	stage = 4
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.radiation += (2*multiplier)

/datum/disease2/effect/greater/toxins
	name = "Hyperacid Syndrome"
	stage = 3
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.adjustToxLoss((2*multiplier))

/datum/disease2/effect/greater/scream
	name = "Random screaming syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*scream")

/datum/disease2/effect/greater/drowsness
	name = "Automated sleeping syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.drowsyness += 10

/datum/disease2/effect/greater/shakey
	name = "World Shaking syndrome"
	stage = 3
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		shake_camera(mob,5*multiplier)

/datum/disease2/effect/greater/deaf
	name = "Hard of hearing syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.ear_deaf += 20

/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		return

/datum/disease2/effect/greater/telepathic
	name = "Telepathy Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.mutations |= 512

/*/datum/disease2/effect/greater/noface
	name = "Identity Loss syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.face_dmg++
	deactivate(var/mob/living/carbon/mob)
		mob.face_dmg--*/

/datum/disease2/effect/greater/monkey
	name = "Monkism syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		if(istype(mob,/mob/living/carbon/human))
			var/mob/living/carbon/human/h = mob
			h.monkeyize()

/datum/disease2/effect/greater/sneeze
	name = "Coldingtons Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*sneeze")

/datum/disease2/effect/greater/gunck
	name = "Flemmingtons"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "\red Mucous runs down the back of your throat."

/datum/disease2/effect/greater/killertoxins
	name = "Toxification syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.adjustToxLoss(15)

/*/datum/disease2/effect/greater/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.hallucination += 25*/

/datum/disease2/effect/greater/sleepy
	name = "Resting syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*collapse")

/datum/disease2/effect/greater/mind
	name = "Lazy mind syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.setBrainLoss(50)

/datum/disease2/effect/greater/suicide
	name = "Suicidal syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		viewers(mob) << "\red <b>[mob.name] is holding \his breath. It looks like \he's trying to commit suicide.</b>"
		mob.adjustOxyLoss(175 - mob.getToxLoss() - mob.getFireLoss() - mob.getBruteLoss() - mob.getOxyLoss())
		mob.updatehealth()
		spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
			mob.suiciding = 0

// lesser syndromes, partly just copypastes
/datum/disease2/effect/lesser/mind
	name = "Lazy mind syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.setBrainLoss(20)

/datum/disease2/effect/lesser/drowsy
	name = "Bedroom Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.drowsyness = 5

/datum/disease2/effect/lesser/deaf
	name = "Hard of hearing syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.ear_deaf = 5

/datum/disease2/effect/lesser/gunck
	name = "Flemmingtons"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob << "\red Mucous runs down the back of your throat."

/datum/disease2/effect/lesser/radian
	name = "Radian's syndrome"
	stage = 4
	maxm = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.radiation += 1

/datum/disease2/effect/lesser/sneeze
	name = "Coldingtons Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*sneeze")

/datum/disease2/effect/lesser/cough
	name = "Anima Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*cough")

/*/datum/disease2/effect/lesser/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.hallucination += 5*/

/*/datum/disease2/effect/lesser/arm
	name = "Disarming Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		var/datum/organ/external/org = mob.organs["r_arm"]
		org.take_damage(3,0,0,0)
		mob << "\red You feel a sting in your right arm."*/

/datum/disease2/effect/lesser/hungry
	name = "Appetiser Effect"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.nutrition = max(0, mob.nutrition - 200)

/datum/disease2/effect/lesser/groan
	name = "Groaning Syndrome"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*groan")

/datum/disease2/effect/lesser/scream
	name = "Loudness Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*scream")

/datum/disease2/effect/lesser/drool
	name = "Saliva Effect"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*drool")

/datum/disease2/effect/lesser/fridge
	name = "Refridgerator Syndrome"
	stage = 2
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*shiver")

/datum/disease2/effect/lesser/twitch
	name = "Twitcher"
	stage = 1
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*twitch")

/*Removed on request by Spaceman, due to it being detrimental to RP. -CN
/datum/disease2/effect/lesser/deathgasp
	name = "Zombie Syndrome"
	stage = 4
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*deathgasp")*/

/datum/disease2/effect/lesser/giggle
	name = "Uncontrolled Laughter Effect"
	stage = 3
	activate(var/mob/living/carbon/mob,var/multiplier)
		mob.say("*giggle")


/datum/disease2/effect/lesser
	chance_maxm = 10

/datum/disease2/effectholder
	var/name = "Holder"
	var/datum/disease2/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/cure = "" //Type of cure it requires
	var/happensonce = 0
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 0

	proc/runeffect(var/mob/living/carbon/human/mob,var/stage)
		if(happensonce > -1 && effect.stage <= stage && prob(chance))
			effect.activate(mob)
			if(happensonce == 1)
				happensonce = -1

	proc/getrandomeffect_greater()
		var/list/datum/disease2/effect/list = list()
		for(var/e in (typesof(/datum/disease2/effect/greater) - /datum/disease2/effect/greater))
		//	world << "Making [e]"
			var/datum/disease2/effect/f = new e
			if(f.stage == src.stage)
				list += f
		effect = pick(list)
		chance = rand(1,6)

	proc/getrandomeffect_lesser()
		var/list/datum/disease2/effect/list = list()
		for(var/e in (typesof(/datum/disease2/effect/lesser) - /datum/disease2/effect/lesser))
			var/datum/disease2/effect/f = new e
			if(f.stage == src.stage)
				list += f
		effect = pick(list)
		chance = rand(1,6)

	proc/minormutate()
		switch(pick(1,2,3,4,5))
			if(1)
				chance = rand(0,effect.chance_maxm)
			if(2)
				multiplier = rand(1,effect.maxm)
	proc/majormutate()
		getrandomeffect_greater()

/proc/dprob(var/p)
	return(prob(sqrt(p)) && prob(sqrt(p)))