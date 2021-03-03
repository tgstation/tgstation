//Reagents produced by metabolising/reacting fermichems inoptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion

//Causes slight liver damage, and that's it.
/datum/reagent/impurity
	name = "Chemical Isomers"
	description = "Impure chemical isomers made from inoptimal reactions. Causes mild liver damage"
	//by default, it will stay hidden on splitting, but take the name of the source on inverting. Cannot be fractioned down either if the reagent is somehow isolated.
	chemical_flags = REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT | REAGENT_CAN_BE_SYNTHESIZED //impure can be synthed, and is one of the only ways to get almost pure impure
	ph = 3
	impure_chem = null
	inverse_chem = null
	failed_chem = null
	metabolization_rate = 0.1 * REM //default impurity is 0.75, so we get 25% converted. Default metabolisation rate is 0.4, so we're 4 times slower.
	var/liver_damage = 0.5

/datum/reagent/impurity/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
	if(!L)//Though, lets be safe
		C.adjustToxLoss(1 * REM * delta_time, FALSE)//Incase of no liver!
		return ..()
	C.adjustOrganLoss(ORGAN_SLOT_LIVER, liver_damage * REM * delta_time)
	return ..()

//Basically just so people don't forget to adjust metabolization_rate
/datum/reagent/inverse
	name = "Toxic monomers"
	description = "Inverse reagents are created when a reagent's purity is below it's inverse threshold. The are created either during ingestion - which will then replace their associated reagent, or some can be created during the reaction process."
	ph = 2
	chemical_flags = REAGENT_SNEAKYNAME | REAGENT_DONOTSPLIT //Inverse generally cannot be synthed - they're difficult to get
	//Mostly to be safe - but above flags will take care of this. Also prevents it from showing these on reagent lookups in the ui
	impure_chem = null
	inverse_chem = null
	failed_chem = null
	///how much this reagent does for tox damage too
	var/tox_damage = 1


/datum/reagent/inverse/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	C.adjustToxLoss(tox_damage * REM * delta_time, FALSE)
	return ..()

//Failed chems - generally use inverse if you want to use a impure subtype for it
//technically not a impure chem, but it's here because it can only be made with a failed impure reaction
/datum/reagent/consumable/failed_reaction
	name = "Viscous sludge"
	description = "A off smelling sludge that's created when a reaction gets too impure."
	nutriment_factor = -1
	quality = -1
	ph = 1.5
	taste_description = "an awful, strongly chemical taste"
	color = "#270d03"
