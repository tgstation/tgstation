#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.01 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
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
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE//maximum amount of toxins the liver can just shrug off
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY//affects how much damage toxins do to the liver
	var/filterToxins = TRUE //whether to filter toxins

/obj/item/organ/liver/Initialize()
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
			. += "A smell of bananas, a slippery sheen and <span class='clown'>honking</span> when depressed, implies that this is the liver of a <em>clown</em>."
		if(HAS_TRAIT(src, TRAIT_MEDICAL_METABOLISM))
			. += "Marks of stress and a faint whiff of medicinal alcohol, imply that this is the liver of a <em>medical worker</em>."
		if(HAS_TRAIT(src, TRAIT_GREYTIDE_METABOLISM))
			. += "Greyer than most with electrical burn marks, this is the liver of an <em>assistant</em>."
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

/obj/item/organ/liver/on_life()
	var/mob/living/carbon/C = owner
	..() //perform general on_life()
	if(istype(C))
		if(!(organ_flags & ORGAN_FAILING) && !HAS_TRAIT(C, TRAIT_NOMETABOLISM))//can't process reagents with a failing liver

			var/provide_pain_message = HAS_NO_TOXIN
			var/obj/belly = C.getorganslot(ORGAN_SLOT_STOMACH)
			if(filterToxins && !HAS_TRAIT(owner, TRAIT_TOXINLOVER))
				//handle liver toxin filtration
				for(var/datum/reagent/toxin/T in C.reagents.reagent_list)
					var/thisamount = C.reagents.get_reagent_amount(T.type)
					if(belly)
						thisamount += belly.reagents.get_reagent_amount(T.type)
					if (thisamount && thisamount <= toxTolerance * (maxHealth - damage) / maxHealth ) //toxTolerance is effectively multiplied by the % that your liver's health is at
						C.reagents.remove_reagent(T.type, 1)
					else
						damage += (thisamount*toxLethality)
						if(provide_pain_message != HAS_PAINFUL_TOXIN)
							provide_pain_message = T.silent_toxin ? HAS_SILENT_TOXIN : HAS_PAINFUL_TOXIN

			//metabolize reagents
			C.reagents.metabolize(C, can_overdose=TRUE)

			if(provide_pain_message && damage > 10 && prob(damage/3))//the higher the damage the higher the probability
				to_chat(C, "<span class='warning'>You feel a dull pain in your abdomen.</span>")

		else //for when our liver's failing
			C.liver_failure()

	if(damage > maxHealth)//cap liver damage
		damage = maxHealth

/obj/item/organ/liver/on_death()
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
	for(var/reagent in carbon_owner.reagents.reagent_list)
		var/datum/reagent/R = reagent
		R.on_mob_dead(carbon_owner)

#undef HAS_SILENT_TOXIN
#undef HAS_NO_TOXIN
#undef HAS_PAINFUL_TOXIN

/obj/item/organ/liver/get_availability(datum/species/S)
	return !(TRAIT_NOMETABOLISM in S.inherent_traits)

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	icon_state = "liver-p"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."

/obj/item/organ/liver/alien
	name = "alien liver" // doesnt matter for actual aliens because they dont take toxin damage
	icon_state = "liver-x" // Same sprite as fly-person liver.
	desc = "A liver that used to belong to a killer alien, who knows what it used to eat."
	toxLethality = LIVER_DEFAULT_TOX_LETHALITY * 2.5 // rejects its owner early after too much punishment
	toxTolerance = 15 // complete toxin immunity like xenos have would be too powerful

/obj/item/organ/liver/cybernetic
	name = "basic cybernetic liver"
	icon_state = "liver-c"
	desc = "A very basic device designed to mimic the functions of a human liver. Handles toxins slightly worse than an organic liver."
	organ_flags = ORGAN_SYNTHETIC
	toxTolerance = 2
	toxLethality = 0.011
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5

	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/liver/cybernetic/tier2
	name = "cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An electronic device designed to mimic the functions of a human liver. Handles toxins slightly better than an organic liver."
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 5 //can shrug off up to 5u of toxins
	toxLethality = 0.008 //20% less damage than a normal liver
	emp_vulnerability = 40

/obj/item/organ/liver/cybernetic/tier3
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u2"
	desc = "An upgraded version of the cybernetic liver, designed to improve further upon organic livers. It is resistant to alcohol poisoning and is very robust at filtering toxins."
	alcohol_tolerance = 0.001
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 10 //can shrug off up to 10u of toxins
	toxLethality = 0.008 //20% less damage than a normal liver
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
