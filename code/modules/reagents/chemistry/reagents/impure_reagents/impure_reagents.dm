//Reagents produced by metabolising/reacting fermichems inoptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min


/datum/reagent/impurity
	name = "Impure reagent"
	description = "Impure reagents are created by either ingesting reagents - which will then split them, or some can be created as the result in a reaction."
	//by default, it will stay hidden on splitting, but take the name of the source on inverting. Cannot be fractioned down either if the reagent is somehow isolated.
	chemical_flags = REAGENT_INVISIBLE | REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT
	//Mostly to be safe - but above flags will take care of this. Also prevents it from showing these on reagent lookups
	impure_chem = null
	inverse_chem = null
	failed_chem = null
	can_synth = FALSE //Protected by default

////START SUBTYPES

///We don't want these to hide - they're helpful!
/datum/reagent/impurity/healing
	name = "Healing impure reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT

//// END SUBTYPES

//Causes slight liver damage, and that's it.
/datum/reagent/impurity/isomer
	name = "Chemical Isomers"
	description = "Impure chemical isomers made from inoptimal reactions. Causes mild liver damage"
	ph = 3	

/datum/reagent/impurity/isomer/on_mob_life(mob/living/carbon/C)
	var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
	if(!L)//Though, lets be safe
		C.adjustToxLoss(1, FALSE)//Incase of no liver!
		return ..()
	C.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5*REM)
	return ..()

//Does the same as above, but also causes toxin damage
/datum/reagent/impurity/isomer/toxic
	name = "Toxic sludge"
	description = "Toxic chemical isomers made from impure reactions. Causes toxin damage"
	ph = 2

/datum/reagent/impurity/isomer/toxic/on_mob_life(mob/living/carbon/C)
	C.adjustToxLoss(1, FALSE)
	return ..()

//technically not a impure chem, but it's here because it can only be made with a failed impure reaction
/datum/reagent/consumable/failed_reaction
	name = "Viscous sludge"
	description = "A off smelling sludge that's created when a reaction gets too impure."
	nutriment_factor = -1
	quality = -1
	ph = 1.5
	taste_description = "an awful, strongly chemical taste"
	color = "#270d03"


////////////////////MEDICINES///////////////////////////

//Catch all failed reaction for medicines - supposed to be non punishing
/datum/reagent/impurity/medicine_failure
	name = "Insolvent medicine precipitate"
	description = "A viscous mess of various medicines. Will heal a damage type at random"
	metabolization_rate = 1 * REM//This is fast
	can_synth = TRUE

//Random healing of the 4 main groups
/datum/reagent/impurity/medicine_failure/on_mob_life(mob/living/carbon/C)
	. = ..()
	var/pick = pick("brute", "burn", "tox", "oxy")
	switch(pick)
		if("brute")
			C.adjustBruteLoss(-1)
		if("burn")
			C.adjustFireLoss(-1)
		if("tox")
			C.adjustToxLoss(-1)
		if("oxy")
			C.adjustOxyLoss(-1)

////// C2 medications
//// Helbital

//Inverse:
/datum/reagent/impurity/helgrasp
	name = "Helgrasp"
	description = "This rare and forbidden concoction is thought to bring you closer to the grasp of the Norse goddess Hel."
	metabolization_rate = 1 //This is fast

//Warns you about the impenting hands
/datum/reagent/impurity/helgrasp/on_mob_add(mob/living/L, amount)
	. = ..()
	to_chat(L, "<span class='hierophant'>You hear laughter as malevolent hands apparate before you, eager to drag you down to hell...! Look out!</span>")
	playsound(L.loc, 'sound/chemistry/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready

//Sends hands after you for your hubris
/datum/reagent/impurity/helgrasp/on_mob_life(mob/living/carbon/owner)
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

//Should I make it so that OD on this literally drags you to hell (lavaland)?

////libital

//Impure

//Simply reduces your alcohol tolerance, kinda simular to prohol
/datum/reagent/impurity/libitoil
	name = "Libitoil"
	description = "Temporarilly interferes a patient's ability to process alcohol."
	chemical_flags = REAGENT_DONOTSPLIT
	can_synth = TRUE

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

/datum/reagent/impurity/probital_failed/overdose_start(mob/living/carbon/M)
	metabolization_rate = 4  * REAGENTS_METABOLISM

/datum/reagent/consumable/nutriment/peptides_failed
	name = "Prion peptides"
	taste_description = "spearmint frosting"
	description = "These inhibitory peptides slow down wound healing and also cost nutrition as well!"
	nutriment_factor = -10 * REAGENTS_METABOLISM 
	brute_heal = -1.5 //I halved it because I was concerned it might be too strong at 4 damage a tick.
	burn_heal = -0.5

////Lenturi

//impure
/datum/reagent/impurity/lentslurri //Okay maybe I should outsource names for these
	name = "lentslurri"//This is a really bad name please replace
	description = "A highly addicitive muscle relaxant that is made when Lenturi reactions go wrong."
	addiction_threshold = 7.5 //30u of 0.75 purity
	metabolization_rate = 0.25 * REM //25% as fast so 0.75 is normal function

/datum/reagent/impurity/lentslurri/on_mob_metabolize(mob/living/carbon/M)
	M.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return ..()

/datum/reagent/impurity/lentslurri/on_mob_end_metabolize(mob/living/carbon/M)
	M.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return ..()

/datum/reagent/impurity/lentslurri/addiction_act_stage1(mob/living/M)
	. = ..()
	to_chat(M, "<span class='notice'>Your muscles feel sore.... And that Lenturi was really moreish though. You should really get some more.</span>")
	addiction_stage = 10//So we jump right to stage 2
	M.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)

/datum/reagent/impurity/lentslurri/addiction_act_stage4(mob/living/M)
	. = ..()
	if(addiction_stage == 40)
		M.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
		to_chat(M, "<span class='notice'>Your muscles feel normal again.</span>")

//failed
/datum/reagent/impure/ichiyuri
	name = "Ichiyuri"
	description = "Prolonged exposure to this chemical can cause an overwhelming urge to itch oneself."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/resetting_probability = 0
	var/spammer = 0

//Just the removed itching mechanism - omage to it's origins.
/datum/reagent/impure/ichiyuri/on_mob_life(mob/living/carbon/M)
	if(prob(resetting_probability) && !(M.restrained() || M.incapacitated()))
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

//inverse
/datum/reagent/impurity/Aburi
	//sweat?
	

	new /datum/hallucination/fire(C, TRUE)
	C.adjust

////Multiver

//Inverse

//Reaction product when between 0.2 and 0.35 purity.
/datum/reagent/impurity/healing/monover
	name = "Monover"
	description = "A toxin treating reagent, that only is effective if it's the only reagent present in the patient."

//Heals toxins if it's the only thing present - kinda the oposite of multiver! Maybe that's why it's inverse!
/datum/reagent/medicine/c2/monover/on_mob_life(mob/living/carbon/M)
	if(M.reagents.reagent_list > 1)
		M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5) //Hey! It's everyone's favourite drawback from multiver!
		return ..()
	M.adjustToxLoss(-2*REM, 0)
	..()
	return TRUE