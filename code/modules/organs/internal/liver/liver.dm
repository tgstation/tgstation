
/datum/organ/internal/liver
	name = "liver"
	parent_organ = LIMB_CHEST
	var/process_accuracy = 10
	var/efficiency = 1

	var/reagent_efficiencies=list(
		// REAGENT = 2,
	)
	removed_type = /obj/item/organ/liver

/datum/organ/internal/liver/Copy()
	var/datum/organ/internal/liver/I = ..()
	I.process_accuracy = process_accuracy
	return I

/datum/organ/internal/liver/process()
	..()
	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			owner << "<span class='warning'>Your skin itches.</span>"
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % process_accuracy == 0)
		if(src.damage < 0)
			src.damage = 0

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent(ANTI_TOXIN))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * process_accuracy
			//Damaged one shares the fun
			else
				var/datum/organ/internal/O = pick(owner.internal_organs)
				if(O)
					O.damage += 0.2  * process_accuracy

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent(ANTI_TOXIN))
			src.damage -= 0.2 * process_accuracy

		// Damaged liver means some chemicals are very dangerous
		if(src.damage >= src.min_bruised_damage)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/ethanol))
					owner.adjustToxLoss(0.1 * process_accuracy)

			// Can't cope with toxins at all
			for(var/toxin in list(TOXIN, PLASMA, SACID, PACID, CYANIDE, LEXORIN, AMATOXIN, CHLORALHYDRATE, CARPOTOXIN, ZOMBIEPOWDER, MINDBREAKER))
				if(owner.reagents.has_reagent(toxin))
					owner.adjustToxLoss(0.3 * process_accuracy)

/datum/organ/internal/liver/proc/metabolize_reagent(var/reagent_id, var/metabolism)
	var/mob/living/carbon/human/H=owner
	var/reagent_efficiency = 1
	if(reagent_id in reagent_efficiencies)
		reagent_efficiency = reagent_efficiencies[reagent_id]
	H.reagents.remove_reagent(reagent_id, metabolism * efficiency * reagent_efficiency)