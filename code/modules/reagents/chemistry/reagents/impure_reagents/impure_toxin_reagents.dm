//Reagents produced by metabolising/reacting fermichems inoptimally these specifically are for toxins
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

////////////////////TOXINS///////////////////////////

//Lipolicide - Impure Version
/datum/reagent/impurity/ipecacide
	name = "Ipecacide"
	description = "An extremely gross substance that induces vomiting. It is produced when Lipolicide reactions are impure."
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/ipecacide/on_mob_add(mob/living/carbon/owner)
	if(owner.disgust >= DISGUST_LEVEL_GROSS)
		return ..()
	owner.adjust_disgust(50)
	..()


//Formaldehyde - Impure Version
/datum/reagent/impurity/methanol
	name = "Methanol"
	description = "A light, colourless liquid with a distinct smell. Ingestion can lead to blindness. It is a byproduct of organisms processing impure Formaldehyde."
	reagent_state = LIQUID
	color = "#aae7e4"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/methanol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/obj/item/organ/internal/eyes/eyes = affected_mob.getorganslot(ORGAN_SLOT_EYES)
	eyes?.applyOrganDamage(0.5 * REM * delta_time, required_organtype = affected_organtype)
	return ..()

//Chloral Hydrate - Impure Version
/datum/reagent/impurity/chloralax
	name = "Chloralax"
	description = "An oily, colorless and slightly toxic liquid. It is produced when impure choral hydrate is broken down inside an organism."
	reagent_state = LIQUID
	color = "#387774"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/chloralax/on_mob_life(mob/living/carbon/owner, delta_time)
	owner.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()


//Mindbreaker Toxin - Impure Version
/datum/reagent/impurity/rosenol
	name = "Rosenol"
	description = "A strange, blue liquid that is produced during impure mindbreaker toxin reactions. Historically it has been abused to write poetry."
	reagent_state = LIQUID
	color = "#0963ad"
	ph = 7
	liver_damage = 0
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/impurity/rosenol/on_mob_life(mob/living/carbon/owner, delta_time)
	var/obj/item/organ/internal/tongue/tongue = owner.getorganslot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return ..()
	if(DT_PROB(4.0, delta_time))
		owner.manual_emote("clicks with [owner.p_their()] tongue.")
		owner.say("Noice.", forced = /datum/reagent/impurity/rosenol)
	if(DT_PROB(2.0, delta_time))
		owner.say(pick("Ah! That was a mistake!", "Horrible.", "Watch out everybody, the potato is really hot.", "When I was six I ate a bag of plums.", "And if there is one thing I can't stand it's tomatoes.", "And if there is one thing I love it's tomatoes.", "We had a captain who was so strict, you weren't allowed to breathe in their station.", "The unrobust ones just used to keel over and die, you'd hear them going down behind you."), forced = /datum/reagent/impurity/rosenol)
	..()
