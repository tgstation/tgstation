//Reagents produced by metabolising/reacting fermichems inoptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion

//Causes slight liver damage, and that's it.
/datum/reagent/impure
	name = "Chemical Isomers"
	description = "Impure chemical isomers made from inoptimal reactions. Causes mild liver damage"
	chemical_flags = REAGENT_INVISIBLE | REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT //by default, it will stay hidden on splitting, but take the name of the source on inverting. Cannot be fractioned down either
	pH = 3

/datum/reagent/impure/on_mob_life(mob/living/carbon/C)
	var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
	if(!L)//Though, lets be safe
		C.adjustToxLoss(2)//Incase of no liver!
		return ..()
	C.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5*REM)
	..()

/datum/reagent/impure/toxic
	name = "Toxic sludge"
	description = "Toxic chemical isomers made from impure reactions. Causes toxin damage"
	pH = 2

/datum/reagent/impure/toxic/on_mob_life(mob/living/carbon/C)
	C.adjustToxLoss(1)
	..()

//technically not a impure chem, but it's here because it can only be made with a failed impure reaction
/datum/reagent/consumable/failed_reaction
	name = "Viscous sludge"
	description = "A off smelling sludge that's created when a reaction gets too impure."
	nutriment_factor = -1
	quality = -1
	pH = 1.5
	taste_description = "an awful, strongly chemical taste"
	color = "#270d03"
	