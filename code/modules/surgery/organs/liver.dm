#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.005 //lower values lower how harmful toxins are to the liver
#define LIVER_FAILURE_STAGE_SECONDS 60 //amount of seconds before liver failure reaches a new stage
/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = "Pairing suggestion: chianti and fava beans."

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY // smack in the middle of decay times

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)
	grind_results = list(/datum/reagent/consumable/nutriment/peptides = 5)

	var/alcohol_tolerance = ALCOHOL_RATE//affects how much damage the liver takes from alcohol
	/// The maximum volume of toxins the liver will quickly purge
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE
	/// Scaling factor for how much damage toxins deal to the liver
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY
	var/filterToxins = TRUE //whether to filter toxins

/obj/item/organ/liver/Initialize(mapload)
	. = ..()
	// If the liver handles foods like a clown, it honks like a bike horn
	// Don't think about it too much.
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_COMEDY_METABOLISM), .proc/on_add_comedy_metabolism)

/* Signal handler for the liver gaining the TRAIT_COMEDY_METABOLISM trait
 *
 * Adds the "squeak" component, so clown livers will act just like their
 * bike horns, and honk when you hit them with things, or throw them
 * against things, or step on them.
 *
 * The removal of the component, if this liver loses that trait, is handled
 * by the component itself.
 */
/obj/item/organ/liver/proc/on_add_comedy_metabolism()
	SIGNAL_HANDLER

	// Are clown "bike" horns made from the livers of ex-clowns?
	// Would that make the clown more or less likely to honk it
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50, falloff_exponent = 20)

/obj/item/organ/liver/examine(mob/user)
	. = ..()

	if(HAS_TRAIT(user, TRAIT_ENTRAILS_READER) || (user.mind && HAS_TRAIT(user.mind, TRAIT_ENTRAILS_READER)) || isobserver(user))
		if(HAS_TRAIT(src, TRAIT_LAW_ENFORCEMENT_METABOLISM))
			. += "Fatty deposits and sprinkle residue, imply that this is the liver of someone in <em>security</em>."
		if(HAS_TRAIT(src, TRAIT_CULINARY_METABOLISM))
			. += "The high iron content and slight smell of garlic, implies that this is the liver of a <em>cook</em>."
		if(HAS_TRAIT(src, TRAIT_COMEDY_METABOLISM))
			. += "A smell of bananas, a slippery sheen and [span_clown("honking")] when depressed, implies that this is the liver of a <em>clown</em>."
		if(HAS_TRAIT(src, TRAIT_MEDICAL_METABOLISM))
			. += "Marks of stress and a faint whiff of medicinal alcohol, imply that this is the liver of a <em>medical worker</em>."
		if(HAS_TRAIT(src, TRAIT_ENGINEER_METABOLISM))
			. += "Signs of radiation exposure and space adaption, implies that this is the liver of an <em>engineer</em>."

		// royal trumps pretender royal
		if(HAS_TRAIT(src, TRAIT_ROYAL_METABOLISM))
			. += "A rich diet of luxury food, suppleness from soft beds, implies that this is the liver of a <em>head of staff</em>."
		else if(HAS_TRAIT(src, TRAIT_PRETENDER_ROYAL_METABOLISM))
			. += "A diet of imitation caviar, and signs of insomnia, implies that this is the liver of <em>someone who wants to be a head of staff</em>."



#define HAS_SILENT_TOXIN 0 //don't provide a feedback message if this is the only toxin present
#define HAS_NO_TOXIN 1
#define HAS_PAINFUL_TOXIN 2

/obj/item/organ/liver/on_life(delta_time, times_fired)
	var/mob/living/carbon/liver_owner = owner
	..() //perform general on_life()
	if(istype(liver_owner))
		if(!(organ_flags & ORGAN_FAILING) && !HAS_TRAIT(liver_owner, TRAIT_NOMETABOLISM))//can't process reagents with a failing liver

			var/provide_pain_message = HAS_NO_TOXIN
			var/obj/belly = liver_owner.getorganslot(ORGAN_SLOT_STOMACH)
			if(filterToxins && !HAS_TRAIT(owner, TRAIT_TOXINLOVER))
				//handle liver toxin filtration
				for(var/datum/reagent/toxin/toxin in liver_owner.reagents.reagent_list)
					var/thisamount = liver_owner.reagents.get_reagent_amount(toxin.type)
					if(belly)
						thisamount += belly.reagents.get_reagent_amount(toxin.type)
					if (thisamount && thisamount <= toxTolerance * (maxHealth - damage) / maxHealth ) //toxTolerance is effectively multiplied by the % that your liver's health is at
						liver_owner.reagents.remove_reagent(toxin.type, 0.5 * delta_time)
					else
						damage += (thisamount * toxLethality * delta_time)
						if(provide_pain_message != HAS_PAINFUL_TOXIN)
							provide_pain_message = toxin.silent_toxin ? HAS_SILENT_TOXIN : HAS_PAINFUL_TOXIN

			//metabolize reagents
			liver_owner.reagents.metabolize(liver_owner, delta_time, times_fired, can_overdose=TRUE)

			if(provide_pain_message && damage > 10 && DT_PROB(damage/6, delta_time)) //the higher the damage the higher the probability
				to_chat(liver_owner, span_warning("You feel a dull pain in your abdomen."))


	if(damage > maxHealth)//cap liver damage
		damage = maxHealth

/obj/item/organ/liver/handle_failing_organs(delta_time)
	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_NOMETABOLISM))
		return
	return ..()

/obj/item/organ/liver/organ_failure(delta_time)

	switch(failure_time/LIVER_FAILURE_STAGE_SECONDS)
		if(1)
			to_chat(owner, span_userdanger("You feel stabbing pain in your abdomen!"))
		if(2)
			to_chat(owner, span_userdanger("You feel a burning sensation in your gut!"))
			owner.vomit()
		if(3)
			to_chat(owner, span_userdanger("You feel painful acid in your throat!"))
			owner.vomit(blood = TRUE)
		if(4)
			to_chat(owner, span_userdanger("Overwhelming pain knocks you out!"))
			owner.vomit(blood = TRUE, distance = rand(1,2))
			owner.emote("Scream")
			owner.AdjustUnconscious(2.5 SECONDS)
		if(5)
			to_chat(owner, span_userdanger("You feel as if your guts are about to melt!"))
			owner.vomit(blood = TRUE,distance = rand(1,3))
			owner.emote("Scream")
			owner.AdjustUnconscious(5 SECONDS)

	switch(failure_time)
			//After 60 seconds we begin to feel the effects
		if(1 * LIVER_FAILURE_STAGE_SECONDS to 2 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.2 * delta_time,forced = TRUE)
			owner.adjust_disgust(0.1 * delta_time)

		if(2 * LIVER_FAILURE_STAGE_SECONDS to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.4 * delta_time,forced = TRUE)
			owner.adjust_drowsyness(0.25 * delta_time)
			owner.adjust_disgust(0.3 * delta_time)

		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.6 * delta_time,forced = TRUE)
			owner.adjustOrganLoss(pick(ORGAN_SLOT_HEART,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_EYES,ORGAN_SLOT_EARS),0.2 * delta_time)
			owner.adjust_drowsyness(0.5 * delta_time)
			owner.adjust_disgust(0.6 * delta_time)

			if(DT_PROB(1.5, delta_time))
				owner.emote("drool")

		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			owner.adjustToxLoss(0.8 * delta_time,forced = TRUE)
			owner.adjustOrganLoss(pick(ORGAN_SLOT_HEART,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_EYES,ORGAN_SLOT_EARS),0.5 * delta_time)
			owner.adjust_drowsyness(0.8 * delta_time)
			owner.adjust_disgust(1.2 * delta_time)

			if(DT_PROB(3, delta_time))
				owner.emote("drool")

/obj/item/organ/liver/on_owner_examine(datum/source, mob/user, list/examine_list)
	if(!ishuman(owner) || !(organ_flags & ORGAN_FAILING))
		return

	var/mob/living/carbon/human/humie_owner = owner
	if(!humie_owner.getorganslot(ORGAN_SLOT_EYES) || humie_owner.is_eyes_covered())
		return
	switch(failure_time)
		if(0 to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_notice("[owner]'s eyes are slightly yellow.")
		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_notice("[owner]'s eyes are completely yellow, and he is visibly suffering.")
		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			examine_list += span_danger("[owner]'s eyes are completely yellow and swelling with pus. [owner.p_they()] don't look like they will be alive for much longer.")

/obj/item/organ/liver/on_death(delta_time, times_fired)
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	if(!owner)//If we're outside of a mob
		return
	if(!iscarbon(carbon_owner))
		CRASH("on_death() called for [src] ([type]) with invalid owner ([isnull(owner) ? "null" : owner.type])")
	if(carbon_owner.stat != DEAD)
		CRASH("on_death() called for [src] ([type]) with not-dead owner ([owner])")
	if((organ_flags & ORGAN_FAILING) && HAS_TRAIT(carbon_owner, TRAIT_NOMETABOLISM))//can't process reagents with a failing liver
		return
	for(var/datum/reagent/chem as anything in carbon_owner.reagents.reagent_list)
		chem.on_mob_dead(carbon_owner, delta_time)

#undef HAS_SILENT_TOXIN
#undef HAS_NO_TOXIN
#undef HAS_PAINFUL_TOXIN
#undef LIVER_FAILURE_STAGE_SECONDS

/obj/item/organ/liver/get_availability(datum/species/species)
	return !(TRAIT_NOMETABOLISM in species.inherent_traits)

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	icon_state = "liver-p"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."

/obj/item/organ/liver/alien
	name = "alien liver" // doesnt matter for actual aliens because they dont take toxin damage
	icon_state = "liver-x" // Same sprite as fly-person liver.
	desc = "A liver that used to belong to a killer alien, who knows what it used to eat."
	toxLethality = 2.5 * LIVER_DEFAULT_TOX_LETHALITY // rejects its owner early after too much punishment
	toxTolerance = 15 // complete toxin immunity like xenos have would be too powerful

/obj/item/organ/liver/cybernetic
	name = "basic cybernetic liver"
	icon_state = "liver-c"
	desc = "A very basic device designed to mimic the functions of a human liver. Handles toxins slightly worse than an organic liver."
	organ_flags = ORGAN_SYNTHETIC
	toxTolerance = 2
	toxLethality = 1.1 * LIVER_DEFAULT_TOX_LETHALITY
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5

	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/liver/cybernetic/tier2
	name = "cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An electronic device designed to mimic the functions of a human liver. Handles toxins slightly better than an organic liver."
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 5 //can shrug off up to 5u of toxins
	toxLethality = 0.8 * LIVER_DEFAULT_TOX_LETHALITY //20% less damage than a normal liver
	emp_vulnerability = 40

/obj/item/organ/liver/cybernetic/tier3
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u2"
	desc = "An upgraded version of the cybernetic liver, designed to improve further upon organic livers. It is resistant to alcohol poisoning and is very robust at filtering toxins."
	alcohol_tolerance = 0.001
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 10 //can shrug off up to 10u of toxins
	toxLethality = 0.8 * LIVER_DEFAULT_TOX_LETHALITY //20% less damage than a normal liver
	emp_vulnerability = 20

/obj/item/organ/liver/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.adjustToxLoss(10)
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.


