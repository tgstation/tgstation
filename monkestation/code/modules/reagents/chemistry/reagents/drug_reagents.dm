/datum/reagent/drug/krokodil // Needed to modularize due to original TG krokodil having a fermi-chem purity requirement for making krokodil zombies.
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage."
	reagent_state = LIQUID
	color = "#0064B4"
	overdose_threshold = 20
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 18) //7.2 per 2 seconds


/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))
	affected_mob.add_mood_event("smacked out", /datum/mood_event/narcotic_heavy, name)
	if(current_cycle == 35) // Previously required a chem purity of 0.6 or lower to create krokodil zombies w/ fermi-chem.
		if(!istype(affected_mob.dna.species, /datum/species/human/krokodil_addict))
			to_chat(affected_mob, span_userdanger("Your skin falls off easily!"))
			var/mob/living/carbon/human/affected_human = affected_mob
			affected_human.facial_hairstyle = "Shaved"
			affected_human.hairstyle = "Bald"
			affected_human.update_body_parts() // makes you loose hair as well
			affected_mob.set_species(/datum/species/human/krokodil_addict)
			affected_mob.adjustBruteLoss(50 * REM, FALSE, required_bodytype = affected_bodytype) // holy shit your skin just FELL THE FUCK OFF
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * seconds_per_tick, required_organtype = affected_organtype)
	affected_mob.adjustToxLoss(0.25 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE


