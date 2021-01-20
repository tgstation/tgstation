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
