//Reagents produced by metabolising/reacting fermichems inoptimally these specifically are for medicines
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

////START SUBTYPES

///We don't want these to hide - they're helpful!
/datum/reagent/impurity/healing
	name = "Healing impure reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT
	addiction_types = list(/datum/addiction/medicine = 3.5)
	liver_damage = 0

/datum/reagent/inverse/healing
	name = "Healing inverse reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT
	addiction_types = list(/datum/addiction/medicine = 3)
	tox_damage = 0

//// END SUBTYPES

////////////////////MEDICINES///////////////////////////

//Catch all failed reaction for medicines - supposed to be non punishing
/datum/reagent/impure/healing/medicine_failure
	name = "Insolvent medicinal precipitate"
	description = "A viscous mess of various medicines. Will heal a damage type at random"
	metabolization_rate = 1 * REM//This is fast
	addiction_types = list(/datum/addiction/medicine = 7.5)
	ph = 11

//Random healing of the 4 main groups
/datum/reagent/impure/healing/medicine_failure/on_mob_life(mob/living/carbon/C)
	. = ..()
	var/pick = pick("brute", "burn", "tox", "oxy")
	switch(pick)
		if("brute")
			C.adjustBruteLoss(-0.5)
		if("burn")
			C.adjustFireLoss(-0.5)
		if("tox")
			C.adjustToxLoss(-0.5)
		if("oxy")
			C.adjustOxyLoss(-0.5)

////// C2 medications
//// Helbital

//Inverse:
datum/reagent/inverse/helgrasp
	name = "Helgrasp"
	description = "This rare and forbidden concoction is thought to bring you closer to the grasp of the Norse goddess Hel."
	metabolization_rate = 1*REM //This is fast
	tox_damage = 0.25
	ph = 14

//Warns you about the impenting hands
datum/reagent/inverse/helgrasp/on_mob_add(mob/living/L, amount)
	. = ..()
	to_chat(L, "<span class='hierophant'>You hear laughter as malevolent hands apparate before you, eager to drag you down to hell...! Look out!</span>")
	playsound(L.loc, 'sound/chemistry/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready

//Sends hands after you for your hubris
datum/reagent/inverse/helgrasp/on_mob_life(mob/living/carbon/owner)
	. = ..()
	//Adapted from the end of the curse - but lasts a short time
	var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 8)//Larger range so you have more time to dodge
	if(!spawn_turf)
		return
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
	var/obj/projectile/curse_hand/hel/hand = new (spawn_turf)
	hand.preparePixelProjectile(owner, spawn_turf)
	hand.fire()

////libital

//Impure

//Simply reduces your alcohol tolerance, kinda simular to prohol
/datum/reagent/impurity/libitoil
	name = "Libitoil"
	description = "Temporarilly interferes a patient's ability to process alcohol."
	chemical_flags = REAGENT_DONOTSPLIT
	ph = 13.5
	liver_damage = 0.1
	addiction_types = list(/datum/addiction/medicine = 4)

/datum/reagent/impurity/libitoil/on_mob_add(mob/living/L, amount)
	. = ..()
	var/mob/living/carbon/carbmob = L
	if(!carbmob)
		return
	var/obj/item/organ/liver/this_liver = carbmob.getorganslot(ORGAN_SLOT_LIVER)
	this_liver.alcohol_tolerance *= 2

/datum/reagent/impurity/libitoil/on_mob_delete(mob/living/L)
	. = ..()
	var/mob/living/carbon/carbmob = L
	if(!carbmob)
		return
	var/obj/item/organ/liver/this_liver = carbmob.getorganslot(ORGAN_SLOT_LIVER)
	this_liver.alcohol_tolerance /= 2


////probital

/datum/reagent/impurity/probital_failed//Basically crashed out failed metafactor
	name = "Mitogen Metabolic Inhibition Factor"
	description = "This enzyme catalyzes crashes the conversion of nutricious food into healing peptides."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	reagent_state = SOLID
	color = "#b3ff00"
	overdose_threshold = 10
	ph = 1
	addiction_types = list(/datum/addiction/medicine = 5)
	liver_damage = 0

/datum/reagent/impurity/probital_failed/overdose_start(mob/living/carbon/M)
	metabolization_rate = 4  * REAGENTS_METABOLISM

/datum/reagent/peptides_failed
	name = "Prion peptides"
	taste_description = "spearmint frosting"
	description = "These inhibitory peptides slow down wound healing and also cost nutrition as well!"
	ph = 2.1

/datum/reagent/peptides_failed/on_mob_life(mob/living/carbon/owner)
	owner.adjustFireLoss(-0.5)
	owner.adjustBruteLoss(-1.5)
	owner.adjust_nutrition(-5 * REAGENTS_METABOLISM)
	. = ..()

////Lenturi

//impure
/datum/reagent/impurity/lentslurri //Okay maybe I should outsource names for these
	name = "Lentslurri"//This is a really bad name please replace
	description = "A highly addicitive muscle relaxant that is made when Lenturi reactions go wrong."
	addiction_types = list(/datum/addiction/medicine = 8)
	liver_damage = 0

/datum/reagent/impurity/lentslurri/on_mob_metabolize(mob/living/carbon/M)
	M.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return

/datum/reagent/impurity/lentslurri/on_mob_end_metabolize(mob/living/carbon/M)
	M.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return

//failed
/datum/reagent/inverse/ichiyuri
	name = "Ichiyuri"
	description = "Prolonged exposure to this chemical can cause an overwhelming urge to itch oneself."
	reagent_state = LIQUID
	color = "#C8A5DC"
	ph = 1.7
	addiction_types = list(/datum/addiction/medicine = 2.5)
	tox_damage = 0.1
	///Probability of scratch - increases as a function of time
	var/resetting_probability = 0
	///Prevents message spam
	var/spammer = 0

//Just the removed itching mechanism - omage to it's origins.
/datum/reagent/inverse/ichiyuri/on_mob_life(mob/living/carbon/M)
	if(prob(resetting_probability) && !(HAS_TRAIT(M, TRAIT_RESTRAINED) || M.incapacitated()))
		if(spammer < world.time)
			to_chat(M,"<span class='warning'>You can't help but itch yourself.</span>")
			spammer = world.time + (10 SECONDS)
		var/scab = rand(1,7)
		M.adjustBruteLoss(scab*REM)
		M.bleed(scab)
		resetting_probability = 0
	resetting_probability += (5*(current_cycle/10)) // 10 iterations = >51% to itch
	..()
	return TRUE

////Aiuri

//impure
/datum/reagent/impurity/aiuri
	name = "Aivime"
	description = "This reagent is known to interfere with the eyesight of a patient."
	ph = 3.1
	addiction_types = list(/datum/addiction/medicine = 1.5)
	liver_damage = 0.1
	//blurriness at the start of taking the med
	var/cached_blurriness

/datum/reagent/impurity/aiuri/on_mob_add(mob/living/owner, amount)
	. = ..()
	cached_blurriness = owner.eye_blurry
	owner.set_blurriness(((creation_purity*10)*(volume/metabolization_rate)) + cached_blurriness)

/datum/reagent/impurity/aiuri/on_mob_delete(mob/living/owner, amount)
	. = ..()
	if(owner.eye_blurry <= cached_blurriness)
		return
	owner.set_blurriness(cached_blurriness)

////Hercuri

//inverse
/datum/reagent/inverse/hercuri
	name = "Herignis"
	description = "This reagent causes a dramatic raise in a patient's body temperature."
	ph = 0.8
	tox_damage = 0
	addiction_types = list(/datum/addiction/medicine = 2.5)

/datum/reagent/inverse/hercuri/on_mob_life(mob/living/carbon/owner)
	. = ..()
	var/heating = rand(creation_purity*10, creation_purity*30)
	owner.reagents?.chem_temp += (heating*REM)*normalise_creation_purity()
	owner.adjust_bodytemperature(heating * (TEMPERATURE_DAMAGE_COEFFICIENT*REM), 50)
	if(ishuman(owner))
		var/mob/living/carbon/human/humi = owner
		humi.adjust_coretemperature(heating * (TEMPERATURE_DAMAGE_COEFFICIENT*REM), 50)


/datum/reagent/inverse/hercuri/expose_mob(mob/living/carbon/exposed_mob, methods=VAPOR, reac_volume)
	. = ..()
	if(!(methods & VAPOR))
		return
	exposed_mob.adjust_bodytemperature((reac_volume*creation_purity) * TEMPERATURE_DAMAGE_COEFFICIENT, 50)


/datum/reagent/inverse/healing/tirimol
	name = "Super Melatonin"//It's melatonin, but super!
	description = "This will send the patient to sleep, adding a bonus to the efficacy of all reagents administered."
	ph = 12.5 //sleeping is a basic need of all lifeforms
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 5)

//Makes patients fall asleep, then boosts the purirty of their medicine reagents if they're asleep
/datum/reagent/inverse/healing/tirimol/on_mob_life(mob/living/carbon/owner)
	switch(current_cycle)
		if(1 to 10)//same delay as chloral hydrate
			if(prob(50))
				owner.emote("yawn")
		if(10 to INFINITY)
			owner.Sleeping(40)
			. = 1
			if(owner.IsSleeping() && !cached_reagent_list)
				for(var/datum/reagent/reagent as anything in owner.reagents.reagent_list)
					if(istype(reagent, /datum/reagent/medicine))
						if(!(reagent.creation_purity > reagent.inverse_chem_val))//Only affect pure types
							continue
						reagent.creation_purity *= 1.25
						cached_reagent_list += reagent

			else if(!owner.IsSleeping() && cached_reagent_list)
				for(var/datum/reagent/reagent as anything in cached_reagent_list)
					if(!reagent)
						continue
					reagent.creation_purity *= 0.8
				cached_reagent_list = list()
	..()

/datum/reagent/inverse/healing/tirimol/on_mob_delete(mob/living/owner)
	if(owner.IsSleeping())
		owner.visible_message("<span class='notice'>[icon2html(owner, viewers(DEFAULT_MESSAGE_RANGE, src))] [owner] lets out a hearty snore!</span>")//small way of letting people know the supersnooze is ended
	..()

//seiver
////Inverse
//Allows the scanner to detect organ health to the nearest 1% (similar use to irl) and upgrates the scan to advanced
/datum/reagent/inverse/technetium
	name = "Technetium 99"
	description = "A radioactive tracer agent that can improve a scanner's ability to detect internal organ damage. Has a very low metabolism rate and will irradiate the patient when present, purging is recommended after use."
	metabolization_rate = 0.01 * REM
	chemical_flags = REAGENT_DONOTSPLIT //Do show this on scanner
	tox_damage = 0

/datum/reagent/inverse/technetium/on_mob_life(mob/living/carbon/owner)
	owner.radiation += creation_purity // 0 - 1

//Kind of a healing effect, Presumably you're using syrinver to purge so this helps that
/datum/reagent/inverse/healing/syriniver
	name = "Syrinifergus"
	description = "This reagent reduces the impurity of all non medicines within the patient, reducing their negative effects."
	///The list of reagents we've affected
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 1.75)

/datum/reagent/inverse/healing/syriniver/on_mob_add(mob/living/living_mob)
	if(!(iscarbon(living_mob)))
		return ..()
	var/mob/living/carbon/owner = living_mob
	for(var/datum/reagent/reagent as anything in owner.reagents.reagent_list)
		if(!(istype(reagent, /datum/reagent/medicine)))
			continue
		if(!(reagent.creation_purity > reagent.inverse_chem_val))//Only affect pure types
			continue
		reagent.creation_purity *= 0.8
		cached_reagent_list += reagent
	..()

/datum/reagent/inverse/healing/syriniver/on_mob_delete(mob/living/living_mob)
	if(!(iscarbon(living_mob)))
		return ..()
	if(!cached_reagent_list)
		return ..()
	for(var/datum/reagent/reagent as anything in cached_reagent_list)
		if(!reagent)
			continue
		reagent.creation_purity *= 1.25
	cached_reagent_list = null

////Multiver
//Inverse
//Reaction product when between 0.2 and 0.35 purity.
/datum/reagent/inverse/healing/monover
	name = "Monover"
	description = "A toxin treating reagent, that only is effective if it's the only reagent present in the patient."
	ph = 0.5
	addiction_types = list(/datum/addiction/medicine = 3.5)

//Heals toxins if it's the only thing present - kinda the oposite of multiver! Maybe that's why it's inverse!
/datum/reagent/inverse/healing/monover/on_mob_life(mob/living/carbon/M)
	if(M.reagents.reagent_list > 1)
		M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5) //Hey! It's everyone's favourite drawback from multiver!
		return ..()
	M.adjustToxLoss((-2*REM)*creation_purity, 0)
	..()
	return TRUE

///Can bring a corpse back to life temporarily (if heart is intact)
///Makes wounds bleed more, if it brought someone back, they take additional brute and heart damage
///They can't die during this, but if they're past crit then take increasing stamina damage
///If they're past fullcrit, their movement is slowed by half
///If they OD, their heart explodes (if they were brought back from the dead)
/datum/reagent/inverse/penthrite
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart."
	ph = 14
	metabolization_rate = 1 * REM
	addiction_types = list(/datum/addiction/medicine = 12)
	overdose_threshold = 20
	///If we brought someone back from the dead
	var/back_from_the_dead

/datum/reagent/inverse/penthrite/on_mob_dead(mob/living/carbon/owner)
	var/obj/item/organ/heart/heart = owner.getorganslot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		return ..()
	ADD_TRAIT(owner, TRAIT_STABLEHEART, type)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, type)
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, type)
	ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, type)
	owner.stat = CONSCIOUS
	back_from_the_dead = TRUE
	owner.emote("gasp")

/datum/reagent/inverse/penthrite/on_mob_life(mob/living/carbon/owner)
	owner.playsound_local(owner, 'sound/health/slowbeat.ogg', 40)
	if(back_from_the_dead)
		owner.adjustBruteLoss(5*(1-creation_purity))
		owner.adjustOrganLoss(ORGAN_SLOT_HEART, 2.5*(1-creation_purity))
	for(var/datum/wound/iter_wound as anything in owner.all_wounds)
		iter_wound.blood_flow += (1-creation_purity)
	if(owner.health < HEALTH_THRESHOLD_CRIT)
		owner.adjustStaminaLoss((-owner.health)/10)
	if(owner.health < HEALTH_THRESHOLD_FULLCRIT)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)

/datum/reagent/inverse/penthrite/on_mob_delete(mob/living/carbon/owner)
	REMOVE_TRAIT(owner, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, type)
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, type)
	REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, type)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)
	. = ..()

/datum/reagent/inverse/penthrite/overdose_process(mob/living/carbon/owner)
	if(!back_from_the_dead)
		return ..()
	var/obj/item/organ/heart/heart = owner.getorganslot(ORGAN_SLOT_HEART)
	explosion(owner, 1, 0, 1)
	qdel(heart)
	owner.visible_message("<span class='boldwarning'>[owner]'s heart explodes!</span>")
	. = ..()
