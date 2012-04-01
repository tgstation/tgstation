/mob/living/Life()
	// Putting this here because after initiation, another check per living mob isn't going to be that heavy, and other than that, christ.  There's no single unifing place to make sure stuff is initiated.
	// All mobs will have a Sexuality, and if its gender is initalized, we can assume we're done here.

	if(config.allow_ERP)
		if(!src.sexuality.gender || src.sexuality.gender == "None")
			if(gender)
				if(gender == MALE)
					makeMale()

				else if(gender == FEMALE)
					makeFemale()

				else if(gender == NEUTER && (istype(src , /mob/living/carbon/alien/)))
					makeHerm()

				else if(gender == NEUTER && (istype(src , /mob/living/carbon/monkey/)))
					if(prob(50))
						makeMale()
					else
						makeFemale()

				else
					sexuality.gender = "None"

		if(gender != sexuality.gender) // Sex change!
			sexuality.gender = null	// Todo, handle better later.
			return

		if(src.sexuality.gender == FEMALE || sexuality.gender == "Herm")
			if (sexuality.vagina.womb_fluid_contents.len)  // Handles stuff leaking out of her womb and pregnancy chance
				handleWombContents()

			if (sexuality.vagina.fluid_contents.len)  	  // Handles any cocks or toys inside of her
				handleVaginaContents()

			if(sexuality.vagina.pregnancy)
				handlePregnancy()
		//	else
		//		handleMenstrationChance()     // Menstration sucks.




	// While I'm doing a terriblly lazy way of initalizing things, why don't I make it so people's preferences tag along with them.  This could be useful in fixing the fucking cloned-as-unknown thing, making me not have to dynamically load them during tensioner, and of course, storing metadata.

	if(!src.storedpreferences)
		src.storedpreferences = new
		storedpreferences.savefile_load(src, 0)



	..()
	return


/mob/living/verb/succumb()
	set hidden = 1
	if ((src.health < 0 && src.health > -95.0))
		src.adjustOxyLoss(src.health + 200)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		src << "\blue You have given up life and succumbed to death."


/mob/living/proc/updatehealth()
	if(!src.nodamage)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss() - src.getCloneLoss() -src.halloss
	else
		src.health = 100
		src.stat = 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if (src.mutations & COLD_RESISTANCE) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))
				extradam = 0
			else
				extradam += divided_damage
		H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (src.mutations & COLD_RESISTANCE) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature

/mob/proc/get_contents()

/mob/living/get_contents()
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in src.contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/mob/living/proc/check_contents_for(A)
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in src.contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/revive()
	//src.fireloss = 0
	src.setToxLoss(0)
	//src.bruteloss = 0
	src.setOxyLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	//src.health = 100
	src.heal_overall_damage(1000, 1000)
	src.buckled = initial(src.buckled)
	src.handcuffed = initial(src.handcuffed)
	if(src.stat > 1) src.stat = CONSCIOUS
	..()
	return

/mob/living/proc/UpdateDamageIcon()
		return

/mob/living/proc/check_if_buckled()
	if (buckled)
		if(buckled == /obj/structure/stool/bed || istype(buckled, /obj/machinery/conveyor))
			lying = 1
		if(lying)
			var/h = hand
			hand = 0
			drop_item()
			hand = 1
			drop_item()
			hand = h
		density = 1
	else
		density = !lying