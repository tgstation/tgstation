#define NANITE_SLURRY_ORGANIC_PURGE_RATE 4
#define NANITE_SLURRY_ORGANIC_VOMIT_CHANCE 25

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	process_flags = ORGANIC | SYNTHETIC //Let's not cripple synth ops

/datum/reagent/medicine/stimulants
	process_flags = ORGANIC | SYNTHETIC //Syndicate developed 'accelerants' for synths?

/datum/reagent/medicine/leporazine
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/flightpotion
	process_flags = ORGANIC | SYNTHETIC

// REAGENTS FOR SYNTHS

/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "Neutralizes harmful chemical compounds inside synthetic systems and refreshes system software."
	reagent_state = LIQUID
	color = "#F1C40F"
	taste_description = "ethanol"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	process_flags = SYNTHETIC

/datum/reagent/medicine/system_cleaner/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	affected_mob.adjustToxLoss(-2 * REM * seconds_per_tick, 0)
	affected_mob.adjust_disgust(-5 * REM * seconds_per_tick)
	var/remove_amount = 1 * REM * seconds_per_tick;
	for(var/thing in affected_mob.reagents.reagent_list)
		var/datum/reagent/reagent = thing
		if(reagent != src)
			affected_mob.reagents.remove_reagent(reagent.type, remove_amount)
	..()
	return TRUE

/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	description = "Repairs brain damage in synthetics."
	reagent_state = LIQUID
	color = "#727272"
	taste_description = "metal"
	process_flags = SYNTHETIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3 * REM * seconds_per_tick)
	if(prob(10))
		affected_mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	return ..()

/datum/reagent/medicine/nanite_slurry
	name = "Nanite Slurry"
	description = "A localized swarm of nanomachines specialized in repairing mechanical parts. Concentrated amounts in a synthetic host will rapidly repair organ damage, damaging their exterior and overheating them. Otherwise they will safely purge from an organic host"
	reagent_state = LIQUID
	color = "#cccccc"
	overdose_threshold = 10
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	process_flags = SYNTHETIC | ORGANIC
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// How much brute and burn individually is healed per tick
	var/healing = 2
	/// How much body temperature is increased by per overdose cycle on robotic bodyparts.
	var/temperature_change = 50


/datum/reagent/medicine/nanite_slurry/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick)
	var/heal_amount = healing * REM * seconds_per_tick
	affected_mob.heal_bodypart_damage(heal_amount, heal_amount, required_bodytype = BODYTYPE_ROBOTIC)
	return ..()

/datum/reagent/medicine/nanite_slurry/overdose_start(mob/living/affected_mob)
	if(affected_mob.mob_biotypes & MOB_ROBOTIC)
		to_chat(affected_mob, span_danger("Your interior systems are overheating as they're being repaired!"))
	else
		to_chat(affected_mob, span_danger("Your stomach lurches as concentrations of nanites begin disposing of themselves."))

/datum/reagent/medicine/nanite_slurry/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) // Mostly to treat a synthetic being EMP'd
	if(affected_mob.mob_biotypes & MOB_ROBOTIC)
		affected_mob.adjust_bodytemperature(temperature_change * REM * seconds_per_tick) // Overheats
		affected_mob.adjustOrganLoss(pick(ORGAN_SLOT_EYES,ORGAN_SLOT_EARS,ORGAN_SLOT_HEART,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_LIVER),(-5 * REM * seconds_per_tick) * 1.5) // 30 units do ~ 70 brute and 20 burn and heal 240 organ damage (mostly used after being EMP'd)
		affected_mob.take_bodypart_damage(brute = (healing * REM * seconds_per_tick) * 1.5) // Damages at half healing rate
		return ..()
	affected_mob.reagents.remove_reagent(type, NANITE_SLURRY_ORGANIC_PURGE_RATE) //gets removed from organics very fast
	if(prob(NANITE_SLURRY_ORGANIC_VOMIT_CHANCE))
		affected_mob.vomit(vomit_type = /obj/effect/decal/cleanable/chem_pile)
	return TRUE

#undef NANITE_SLURRY_ORGANIC_PURGE_RATE
#undef NANITE_SLURRY_ORGANIC_VOMIT_CHANCE


/datum/reagent/medicine/taste_suppressor
	name = "Taste Suppressor"
	description = "A colorless medicine aimed to dull the sense of taste of those that consumed it, as long as it's in their system."
	color = "#AAAAAA77"
	reagent_state = LIQUID
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/medicine/taste_suppressor/on_mob_metabolize(mob/living/affected_mob)
	. = ..()

	ADD_TRAIT(affected_mob, TRAIT_AGEUSIA, "reagent")


/datum/reagent/medicine/taste_suppressor/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()

	REMOVE_TRAIT(affected_mob, TRAIT_AGEUSIA, "reagent")
