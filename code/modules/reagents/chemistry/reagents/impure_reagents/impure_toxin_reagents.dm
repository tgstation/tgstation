//Reagents produced by metabolising/reacting fermichems inoptimally these specifically are for toxins
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

//START SUBTYPES

//We don't want these to hide - they're helpful!


// END SUBTYPES

////////////////////TOXINS///////////////////////////


//Lipolicide
//impure
/datum/reagent/impurity/ipecacide
	name = "Ipecacide"
	description = "An extremely gross substance that induces vomiting. It is produced when Lipolicide reacts with an impurity."
	ph = 7

/datum/reagent/impurity/ipecacide/on_mob_metabolize(mob/living/carbon/owner)
	owner.adjust_disgust(100)
	return ..()


//Formaldehyde
//impure
/datum/reagent/impurity/methanol
	name = "Methanol"//Chemically related to formaldehyde, do not drink this
	description = "A light, colourless liquid with a distinct smell. Ingestion can lead to blindness. It is a byproduct of impure Formaldehyde reactions."
	reagent_state = LIQUID
	color = "#aae7e4"
	ph = 7

/datum/reagent/impurity/methanol/on_mob_metabolize(mob/living/carbon/owner)
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
		eyes.applyOrganDamage(1)
	return ..()


//Chloral Hydrate
//impure
/datum/reagent/impurity/chloral
	name = "Chloral"
	description = "An oily, colorless and slightly toxic liquid. It is produced when impure chloral hydrate is broken down inside an organism."
	reagent_state = LIQUID
	color = "#387774"
	ph = 7

/datum/reagent/impurity/chloral/on_mob_metabolize(mob/living/carbon/owner, delta_time)
	owner.adjustToxLoss(1 * REM * delta_time, 0)
	return ..()
