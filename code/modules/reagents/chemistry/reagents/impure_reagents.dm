//Reagents produced by metabolising/reacting fermichems inoptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion

//Causes slight liver damage, and that's it.
/datum/reagent/impurity
	name = "Chemical Isomers"
	description = "Impure chemical isomers made from inoptimal reactions. Causes mild liver damage"
	//by default, it will stay hidden on splitting, but take the name of the source on inverting. Cannot be fractioned down either if the reagent is somehow isolated.
	chemical_flags = REAGENT_INVISIBLE | REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT 
	ph = 3
	overdose_threshold = 0 //So that they're shown as a problem (?)


/datum/reagent/impurity/on_mob_life(mob/living/carbon/C)
	var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
	if(!L)//Though, lets be safe
		C.adjustToxLoss(1, FALSE)//Incase of no liver!
		return ..()
	C.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5*REM)
	return ..()

/datum/reagent/impurity/toxic
	name = "Toxic sludge"
	description = "Toxic chemical isomers made from impure reactions. Causes toxin damage"
	ph = 2

/datum/reagent/impurity/toxic/on_mob_life(mob/living/carbon/C)
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
