#define REGENERATION_DELAY 5 SECONDS  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/mutant
	name = "High-Functioning mutant"
	id = SPECIES_MUTANT
	say_mod = "moans"
	meat = /obj/item/food/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD,NOZOMBIE,HAS_FLESH,HAS_BONE,NOEYESPRITES,LIPS,HAIR)
	inherent_traits = list(TRAIT_NODISMEMBER,TRAIT_ADVANCEDTOOLUSER,TRAIT_NOMETABOLISM,TRAIT_TOXIMMUNE,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NOCLONELOSS)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/tongue/zombie
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | ERT_SPAWN
	bodytemp_normal = T0C // They have no natural body heat, the environment regulates body temp
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // Take damage at fire temp
	bodytemp_cold_damage_limit = MINIMUM_TEMPERATURE_TO_MOVE // take damage below minimum movement temp
	limbs_icon = 'modular_skyrat/modules/mutants/icons/mutant_parts_greyscale.dmi'

/datum/species/mutant/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/mob/living/carbon/human/species/mutant
	race = /datum/species/mutant

/mob/living/carbon/human/species/mutant/infectious
	race = /datum/species/mutant/infectious

/datum/species/mutant/infectious
	name = "Mutated Abomination"
	mutanthands = /obj/item/mutant_hand
	speedmod = 1
	armor = 10
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	/// The rate the mutants regenerate at
	var/heal_rate = 1
	/// The cooldown before the mutant can start regenerating
	COOLDOWN_DECLARE(regen_cooldown)

/datum/species/mutant/infectious/fast
	name = "Fast Mutated Abomination"
	mutanthands = /obj/item/mutant_hand/fast
	armor = 0
	/// The rate the mutants regenerate at
	heal_rate = 0.5
	speedmod = 0.5

/datum/species/mutant/infectious/slow
	name = "Slow Mutated Abomination"
	armor = 15
	speedmod = 1.5
	/// The rate the mutants regenerate at
	heal_rate = 1.5

/// mutants do not stabilize body temperature they are the walking dead and are cold blooded
/datum/species/mutant/body_temperature_core(mob/living/carbon/human/humi, delta_time, times_fired)
	return

/datum/species/mutant/infectious/check_roundstart_eligible()
	return FALSE

/datum/species/mutant/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/mutant/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, spread_damage = FALSE, forced = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE)
	. = ..()
	if(.)
		COOLDOWN_START(src, regen_cooldown, REGENERATION_DELAY)

/datum/species/mutant/infectious/spec_life(mob/living/carbon/C, delta_time, times_fired)
	. = ..()
	C.set_combat_mode(TRUE) // THE SUFFERING MUST FLOW

	//mutants never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(COOLDOWN_FINISHED(src, regen_cooldown))
		var/heal_amt = heal_rate
		if(HAS_TRAIT(C, TRAIT_CRITICAL_CONDITION))
			heal_amt *= 2
		C.heal_overall_damage(heal_amt * delta_time, heal_amt * delta_time)
		C.adjustStaminaLoss(-heal_amt * delta_time)
		C.adjustToxLoss(-heal_amt * delta_time)
		for(var/i in C.all_wounds)
			var/datum/wound/iter_wound = i
			if(DT_PROB(2-(iter_wound.severity/2), delta_time))
				iter_wound.remove_wound()
	if(!HAS_TRAIT(C, TRAIT_CRITICAL_CONDITION) && DT_PROB(2, delta_time))
		playsound(C, pick(spooks), 50, TRUE, 10)

#undef REGENERATION_DELAY

/mob/living/carbon/human/canBeHandcuffed()
	if(is_species(src, /datum/species/mutant/infectious))
		return FALSE
	else
		. = ..()

/obj/item/mutant_hand
	name = "mutant claw"
	desc = "A mutant's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the mutant, smashing open airlock doors and opening \
		child-safe caps on bottles."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 26
	sharpness = SHARP_EDGED
	wound_bonus = -20
	damtype = BRUTE

/obj/item/mutant_hand/fast
	name = "weak mutant claw"
	force = 21
	sharpness = NONE
	wound_bonus = -40

/obj/item/mutant_hand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mutant_hand/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/mutant_hand/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	else if(isliving(target))
		if(ishuman(target))
			try_to_mutant_infect(target, user = user)
		else
			check_feast(target, user)

#define INFECT_CHANCE 70

/proc/try_to_mutant_infect(mob/living/carbon/human/target, forced = FALSE, mob/user)
	CHECK_DNA_AND_SPECIES(target)

	if(forced)
		target.AddComponent(/datum/component/mutant_infection)
		return TRUE

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// mutants)
		return FALSE

	if(target.GetComponent(/datum/component/mutant_infection))
		return FALSE

	if(!target.can_inject(user))
		return FALSE

	if(prob(INFECT_CHANCE))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_MUTANT_IMMUNE))
		return FALSE

	target.AddComponent(/datum/component/mutant_infection)
	return TRUE

#undef INFECT_CHANCE

/proc/try_to_mutant_cure(mob/living/carbon/target) //For things like admin procs
	var/datum/component/mutant_infection/infection = target.GetComponent(/datum/component/mutant_infection)
	if(infection)
		qdel(infection)

/obj/item/mutant_hand/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.gib()
		// zero as argument for no instant health update
		user.adjustBruteLoss(-hp_gained, 0)
		user.adjustToxLoss(-hp_gained, 0)
		user.adjustFireLoss(-hp_gained, 0)
		user.adjustCloneLoss(-hp_gained, 0)
		user.updatehealth()
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))
