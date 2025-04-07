/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC //Let's not cripple synth ops

/datum/reagent/medicine/stimulants
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC //Syndicate developed 'accelerants' for synths?

/datum/reagent/medicine/leporazine
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/flightpotion
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC


//Lidocaine
/datum/reagent/medicine/lidocaine
	name = "Lidocaine"
	description = "A numbing agent used often for surgeries, metabolizes slower than most medicines, and when combined with epinephrine metabolizes extremely slowly."
	color = "#6dbdbd" // 109, 189, 189
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20
	ph = 6.09
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/lidocaine
	metabolized_traits = list(TRAIT_ANALGESIA)
	taste_description = "a stinging sensation that quickly numbs"

/datum/reagent/medicine/lidocaine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..() //I've nerfed the metabolization rate of lidocaine, but by giving epinephrine for just a tick you can quadruple it to being better than before
	if(holder.has_reagent(/datum/reagent/medicine/epinephrine))
		metabolization_rate = 0.125 * REAGENTS_METABOLISM

/datum/chemical_reaction/lidocaine
	results = list(/datum/reagent/medicine/lidocaine = 3)
	required_reagents = list(/datum/reagent/nitrous_oxide = 2, /datum/reagent/diethylamine = 3, /datum/reagent/medicine/salglu_solution = 1 )
	required_temp = 400 //hee hee be careful dont mindlessly set to 1000k or you'll blow up your nitrous
	mix_message = "The mixture crystalizes into a salt like solute that immediately dissolves into the saline."
	mix_sound = 'sound/effects/bubbles/bubbles2.ogg'
	optimal_temp = 530
	optimal_ph_min = 4.0
	optimal_ph_max = 6.9
	ph_exponent_factor = 0.25
	determin_ph_range = 5
	H_ion_release = -0.05 //All this is pretty helpful to make ph-balancing easier, the difficulty is meant to be the compound steps and that you'll probably blow up Nitrous
	reaction_tags = REACTION_TAG_HARD | REACTION_TAG_DRUG //I think |most| chems should be harder to make personally. Making this hard also still encourages the use of Deforest despite my rebellion against it

/datum/reagent/medicine/lidocaine/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART,3 * REM * seconds_per_tick, 80)

/datum/reagent/inverse/lidocaine
	name = "Lidopaine"
	description = "A paining agent used often for... being a jerk, metabolizes faster than lidocaine."
	color = "#85111f" // 133, 17, 31
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	ph = 6.09
	tox_damage = 0

/datum/reagent/inverse/lidocaine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	to_chat(affected_mob, span_userdanger("Your body aches with unimaginable pain!"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART,3 * REM * seconds_per_tick, 85)
	affected_mob.adjustStaminaLoss(5 * REM * seconds_per_tick, 0)
	if(prob(30))
		INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), "scream")

//Medigun Clotting Medicine
/datum/reagent/medicine/coagulant/fabricated
	name = "fabricated coagulant"
	description = "A synthesized coagulant created by Mediguns."
	color = "#ff7373" //255, 155. 155
	clot_rate = 0.15 //Half as strong as standard coagulant
	passive_bleed_modifier = 0.5 // around 2/3 the bleeding reduction


// REAGENTS FOR SYNTHS
/datum/chemical_reaction/system_cleaner
	results = list(/datum/reagent/medicine/system_cleaner = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 1, /datum/reagent/phenol = 2, /datum/reagent/potassium = 1)

/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "Neutralizes harmful chemical compounds inside synthetic systems and refreshes system software."
	color = "#F1C40F"
	taste_description = "ethanol"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	process_flags = REAGENT_SYNTHETIC

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

/datum/chemical_reaction/liquid_solder
	results = list(/datum/reagent/medicine/liquid_solder = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/copper = 1, /datum/reagent/silver = 1)
	required_temp = 370
	mix_message = "The mixture becomes a metallic slurry."

/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	description = "Repairs brain damage in synthetics."
	color = "#727272"
	taste_description = "metal"
	process_flags = REAGENT_SYNTHETIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3 * REM * seconds_per_tick)
	if(prob(10))
		affected_mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	return ..()

#define NANITE_SLURRY_ORGANIC_PURGE_RATE 4
#define NANITE_SLURRY_ORGANIC_VOMIT_CHANCE 25

/datum/chemical_reaction/nanite_slurry
	results = list(/datum/reagent/medicine/nanite_slurry = 3)
	required_reagents = list(/datum/reagent/foaming_agent = 1, /datum/reagent/gold = 1, /datum/reagent/iron = 1)
	mix_message = "The mixture becomes a metallic slurry."

/datum/reagent/medicine/nanite_slurry
	name = "Nanite Slurry"
	description = "A localized swarm of nanomachines specialized in repairing mechanical parts. Due to the nanites needing to interface with the host's systems to repair them, a surplus of them will cause them to overheat, or for the swarm to forcefully eject out of the mouth of organics for safety."
	color = "#cccccc"
	overdose_threshold = 20
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	process_flags = REAGENT_SYNTHETIC | REAGENT_ORGANIC
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// How much brute and burn individually is healed per tick
	var/healing = 3
	/// How much body temperature is increased by per overdose cycle on robotic bodyparts.
	var/temperature_change = 50

/datum/reagent/medicine/nanite_slurry/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick)
	var/heal_amount = healing * REM * seconds_per_tick
	affected_mob.heal_bodypart_damage(heal_amount, heal_amount, required_bodytype = BODYTYPE_ROBOTIC)
	return ..()

/datum/reagent/medicine/nanite_slurry/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(affected_mob.mob_biotypes & MOB_ROBOTIC)
		affected_mob.adjust_bodytemperature(temperature_change * REM * seconds_per_tick)
		return ..()
	affected_mob.reagents.remove_reagent(type, NANITE_SLURRY_ORGANIC_PURGE_RATE) //gets removed from organics very fast
	if(prob(NANITE_SLURRY_ORGANIC_VOMIT_CHANCE))
		affected_mob.vomit(vomit_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM), vomit_type = /obj/effect/decal/cleanable/vomit/nanites)
	return TRUE

#undef NANITE_SLURRY_ORGANIC_PURGE_RATE
#undef NANITE_SLURRY_ORGANIC_VOMIT_CHANCE

/datum/chemical_reaction/medicine/taste_suppressor
	results = list(/datum/reagent/medicine/taste_suppressor = 3)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/sulfur = 1, /datum/reagent/water = 1)
	mix_message = "The mixture becomes clear like water."

/datum/chemical_reaction/medicine/taste_suppressor/maint
	results = list(/datum/reagent/medicine/taste_suppressor = 3, /datum/reagent/chlorine = 1) // The chlorine dissociated from the sodium to allow for the synthesis of the taste suppressor
	required_reagents = list(/datum/reagent/consumable/salt = 2, /datum/reagent/sulfur = 1, /datum/reagent/water = 1)
	required_temp = 300

/datum/reagent/medicine/taste_suppressor
	name = "Taste Suppressor"
	description = "A colorless medicine aimed to dull the sense of taste of those that consumed it, as long as it's in their system."
	color = "#AAAAAA77"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	chemical_flags_doppler = REAGENT_BLOOD_REGENERATING // It has REAGENT_BLOOD_REGENERATING only because it makes it so Hemophages can safely drink it, which makes complete sense considering this is meant to suppress their tumor's reactiveness to anything that doesn't regenerate blood.

/datum/reagent/medicine/taste_suppressor/on_mob_metabolize(mob/living/affected_mob)
	. = ..()

	ADD_TRAIT(affected_mob, TRAIT_AGEUSIA, REF(src))

/datum/reagent/medicine/taste_suppressor/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()

	REMOVE_TRAIT(affected_mob, TRAIT_AGEUSIA, REF(src))
