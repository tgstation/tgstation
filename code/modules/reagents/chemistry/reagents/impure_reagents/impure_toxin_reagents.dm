//Reagents produced by metabolising/reacting fermichems inoptimally these specifically are for toxins
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

////////////////////TOXINS///////////////////////////

//Lipolicide
//impure
/datum/reagent/impurity/ipecacide
	name = "Ipecacide"
	description = "An extremely gross substance that induces vomiting. It is produced when Lipolicide reactions are impure."
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/ipecacide/on_mob_metabolize(mob/living/carbon/owner)
	owner.adjust_disgust(100)
	return ..()


//Formaldehyde
//impure
/datum/reagent/impurity/methanol
	name = "Methanol"//Chemically related to formaldehyde, do not drink this
	description = "A light, colourless liquid with a distinct smell. Ingestion can lead to blindness. It is a byproduct of organisms processing impure Formaldehyde."
	reagent_state = LIQUID
	color = "#aae7e4"
	ph = 7

/datum/reagent/impurity/methanol/on_mob_life(mob/living/carbon/owner)
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	eyes.applyOrganDamage(0.5)
	return ..()


//Chloral Hydrate
//impure
/datum/reagent/impurity/chloral
	name = "Chloral"
	description = "An oily, colorless and slightly toxic liquid. It is produced when impure chloral hydrate is broken down inside an organism."
	reagent_state = LIQUID
	color = "#387774"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/chloral/on_mob_life(mob/living/carbon/owner, delta_time)
	owner.adjustToxLoss(1 * REM * delta_time, 0)
	return ..()


//Mindbreaker Toxin
//impure
/datum/reagent/impurity/rosenol
	name = "Rosenol"
	description = "A strange, blue liquid that is produced during impure mindbreaker toxin reactions. Historically it has been abused to write poetry."
	reagent_state = LIQUID
	color = "#0963ad"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/rosenol/on_mob_life(mob/living/carbon/owner, delta_time)
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	if(DT_PROB(4.0, delta_time))
		owner.manual_emote("clicks with [owner.p_their()] tongue.")
		owner.say("Noice.")
	if(DT_PROB(2.0, delta_time))
		owner.say(pick("Ah! That was a mistake!", "Horrible.", "Watch out everybody, the potato is really hot.", "When I was six I ate a bag of plums.", "And if there is one thing I can't stand its tomatoes.", "And if there is one thing I love its tomatoes.", "We had a captain who was so strict, you weren't allowed to breathe in their presence.", "The unrobust ones just used to keel over and die, you'd hear them going down behind you."), forced = /datum/reagent/impurity/rosenol)
	return ..()
