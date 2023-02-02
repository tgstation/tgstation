

//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	taste_description = "bitterness"

/datum/reagent/medicine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	current_cycle++
	if(length(reagent_removal_skip_list))
		return
	holder.remove_reagent(type, metabolization_rate * delta_time / affected_mob.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	description = "Leporazine will effectively regulate a patient's body temperature, ensuring it never leaves safe levels."
	ph = 8.4
	color = "#DB90C6"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/target_temp = affected_mob.get_body_temp_normal(apply_change = FALSE)
	if(affected_mob.bodytemperature > target_temp)
		affected_mob.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, target_temp)
	else if(affected_mob.bodytemperature < (target_temp + 1))
		affected_mob.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 0, target_temp)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/affected_human = affected_mob
		if(affected_human.coretemperature > target_temp)
			affected_human.adjust_coretemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, target_temp)
		else if(affected_human.coretemperature < (target_temp + 1))
			affected_human.adjust_coretemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 0, target_temp)
	..()

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#E0BB00" //golden for the gods
	taste_description = "badmins"
	chemical_flags = REAGENT_DEAD_PROCESS
	/// Flags to fullheal every metabolism tick
	var/full_heal_flags = ~(HEAL_BRUTE|HEAL_BURN|HEAL_TOX|HEAL_RESTRAINTS)

// The best stuff there is. For testing/debugging.
/datum/reagent/medicine/adminordrazine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!check_tray(chems, mytray))
		return

	mytray.adjust_waterlevel(round(chems.get_reagent_amount(type)))
	mytray.adjust_plant_health(round(chems.get_reagent_amount(type)))
	mytray.adjust_pestlevel(-rand(1,5))
	mytray.adjust_weedlevel(-rand(1,5))
	if(chems.has_reagent(type, 3))
		switch(rand(100))
			if(66  to 100)
				mytray.mutatespecie()
			if(33 to 65)
				mytray.mutateweed()
			if(1   to 32)
				mytray.mutatepest(user)
			else
				if(prob(20))
					mytray.visible_message(span_warning("Nothing happens..."))

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.heal_bodypart_damage(5 * REM * delta_time, 5 * REM * delta_time, 0, FALSE, affected_bodytype)
	affected_mob.adjustToxLoss(-5 * REM * delta_time, FALSE, TRUE, affected_biotype)
	// Heal everything! That we want to. But really don't heal reagents. Otherwise we'll lose ... us.
	affected_mob.fully_heal(full_heal_flags & ~HEAL_ALL_REAGENTS)
	return ..()

/datum/reagent/medicine/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Rare and experimental particles, that apparently swap the user's body with one from an alternate dimension where it's completely healthy."
	taste_description = "science"
	full_heal_flags = ~(HEAL_ADMIN|HEAL_BRUTE|HEAL_BURN|HEAL_TOX|HEAL_RESTRAINTS|HEAL_ALL_REAGENTS)

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	description = "Increases resistance to stuns as well as reducing drowsiness and hallucinations."
	color = "#FF00FF"
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	affected_mob.AdjustStun(-20 * REM * delta_time)
	affected_mob.AdjustKnockdown(-20 * REM * delta_time)
	affected_mob.AdjustUnconscious(-20 * REM * delta_time)
	affected_mob.AdjustImmobilized(-20 * REM * delta_time)
	affected_mob.AdjustParalyzed(-20 * REM * delta_time)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5 * REM * delta_time)
	affected_mob.adjust_hallucinations(-20 SECONDS * REM * delta_time)
	if(DT_PROB(16, delta_time))
		affected_mob.adjustToxLoss(1, FALSE, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109
	ph = 5.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5 * REM * delta_time)
	if(holder.has_reagent(/datum/reagent/toxin/histamine))
		holder.remove_reagent(/datum/reagent/toxin/histamine, 5 * REM * delta_time)
	affected_mob.adjust_hallucinations(-20 SECONDS * REM * delta_time)
	if(DT_PROB(16, delta_time))
		affected_mob.adjustToxLoss(1, FALSE, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the patient's body temperature must be under 270K for it to metabolise correctly."
	color = "#0000C8"
	taste_description = "blue"
	ph = 11
	burning_temperature = 20 //cold burning
	burning_volume = 0.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (affected_mob.bodytemperature ** 2) + 0.5)
	if(affected_mob.bodytemperature >= T0C || !HAS_TRAIT(affected_mob, TRAIT_KNOCKEDOUT))
		..()
		return
	var/power = -0.00003 * (affected_mob.bodytemperature ** 2) + 3
	affected_mob.adjustOxyLoss(-3 * power * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustBruteLoss(-power * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-power * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustToxLoss(-power * REM * delta_time, FALSE, TRUE, affected_biotype) //heals TOXINLOVERs
	affected_mob.adjustCloneLoss(-power * REM * delta_time, FALSE, affected_biotype)
	for(var/i in affected_mob.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.on_xadone(power * REAGENTS_EFFECT_MULTIPLIER * delta_time)
	REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
	..()
	return TRUE

// Healing
/datum/reagent/medicine/cryoxadone/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!check_tray(chems, mytray))
		return

	mytray.adjust_plant_health(round(chems.get_reagent_amount(type) * 3))
	mytray.adjust_toxic(-round(chems.get_reagent_amount(type) * 3))

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	description = "A chemical that derives from Cryoxadone. It specializes in healing clone damage, but nothing else. Requires very cold temperatures to properly metabolize, and metabolizes quicker than cryoxadone."
	color = "#3D3DC6"
	taste_description = "muscle"
	ph = 13
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.bodytemperature < T0C)
		affected_mob.adjustCloneLoss((0.00006 * (affected_mob.bodytemperature ** 2) - 6) * REM * delta_time, FALSE)
		REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = TRUE
	metabolization_rate = REAGENTS_METABOLISM * (0.000015 * (affected_mob.bodytemperature ** 2) + 0.75)
	..()

/datum/reagent/medicine/pyroxadone
	name = "Pyroxadone"
	description = "A mixture of cryoxadone and slime jelly, that apparently inverses the requirement for its activation."
	color = "#f7832a"
	taste_description = "spicy jelly"
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/pyroxadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		var/power = 0
		switch(affected_mob.bodytemperature)
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
				power = 2
			if(400 to 460)
				power = 3
			else
				power = 5
		if(affected_mob.on_fire)
			power *= 2

		affected_mob.adjustOxyLoss(-2 * power * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustBruteLoss(-power * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustFireLoss(-1.5 * power * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustToxLoss(-power * REM * delta_time, FALSE, TRUE, affected_biotype)
		affected_mob.adjustCloneLoss(-power * REM * delta_time, FALSE, required_biotype = affected_biotype)
		for(var/i in affected_mob.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = TRUE
	..()

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds and restoring corpses husked by burns. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30
	ph = 12.2
	taste_description = "fish"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that. // No such luck so far
	affected_mob.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
	REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)
	..()
	. = TRUE

/datum/reagent/medicine/rezadone/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.set_dizzy_if_lower(10 SECONDS * REM * delta_time)
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/medicine/rezadone/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return

	var/mob/living/carbon/patient = exposed_mob
	if(reac_volume >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, BURN) && patient.getFireLoss() < UNHUSK_DAMAGE_THRESHOLD) //One carp yields 12u rezadone.
		patient.cure_husk(BURN)
		patient.visible_message(span_nicegreen("[patient]'s body rapidly absorbs moisture from the environment, taking on a more healthy appearance."))

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	description = "Spaceacillin will provide limited resistance against disease and parasites. Also reduces infection in serious burns."
	color = "#E1F2E6"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	ph = 8.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//Goon Chems. Ported mainly from Goonstation. Easily mixable (or not so easily) and provide a variety of effects.

/datum/reagent/medicine/oxandrolone
	name = "Oxandrolone"
	description = "Stimulates the healing of severe burns. Extremely rapidly heals severe burns and slowly heals minor ones. Overdose will worsen existing burns."
	reagent_state = LIQUID
	color = "#1E8BFF"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 10.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/oxandrolone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getFireLoss() > 25)
		affected_mob.adjustFireLoss(-4 * REM * delta_time, FALSE, required_bodytype = affected_bodytype) //Twice as effective as AIURI for severe burns
	else
		affected_mob.adjustFireLoss(-0.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype) //But only a quarter as effective for more minor ones
	..()
	. = TRUE

/datum/reagent/medicine/oxandrolone/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(affected_mob.getFireLoss()) //It only makes existing burns worse
		affected_mob.adjustFireLoss(4.5 * REM * delta_time, FALSE, FALSE, BODYTYPE_ORGANIC) // it's going to be healing either 4 or 0.5
		. = TRUE
	..()

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	description = "Has a 33% chance per metabolism cycle to heal brute and burn damage. Can be used as a temporary blood substitute, as well as slowly speeding blood regeneration."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	taste_description = "sweetness and salt"
	var/last_added = 0
	var/maximum_reachable = BLOOD_VOLUME_NORMAL - 10 //So that normal blood regeneration can continue with salglu active
	var/extra_regen = 0.25 // in addition to acting as temporary blood, also add about half this much to their actual blood per second
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(last_added)
		affected_mob.blood_volume -= last_added
		last_added = 0
	if(affected_mob.blood_volume < maximum_reachable) //Can only up to double your effective blood level.
		var/amount_to_add = min(affected_mob.blood_volume, 5*volume)
		var/new_blood_level = min(affected_mob.blood_volume + amount_to_add, maximum_reachable)
		last_added = new_blood_level - affected_mob.blood_volume
		affected_mob.blood_volume = new_blood_level + (extra_regen * REM * delta_time)
	if(DT_PROB(18, delta_time))
		affected_mob.adjustBruteLoss(-0.5, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustFireLoss(-0.5, FALSE, required_bodytype = affected_bodytype)
		. = TRUE
	..()

/datum/reagent/medicine/salglu_solution/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(1.5, delta_time))
		to_chat(affected_mob, span_warning("You feel salty."))
		holder.add_reagent(/datum/reagent/consumable/salt, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	else if(DT_PROB(1.5, delta_time))
		to_chat(affected_mob, span_warning("You feel sweet."))
		holder.add_reagent(/datum/reagent/consumable/sugar, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	if(DT_PROB(18, delta_time))
		affected_mob.adjustBruteLoss(0.5, FALSE, FALSE, BODYTYPE_ORGANIC)
		affected_mob.adjustFireLoss(0.5, FALSE, FALSE, BODYTYPE_ORGANIC)
		. = TRUE
	..()

/datum/reagent/medicine/mine_salve
	name = "Miner's Salve"
	description = "A powerful painkiller. Restores bruising and burns in addition to making the patient believe they are fully healed. Also great for treating severe burn wounds in a pinch."
	reagent_state = LIQUID
	color = "#6D6374"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	ph = 2.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/mine_salve/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustBruteLoss(-0.25 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-0.25 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	..()
	return TRUE

/datum/reagent/medicine/mine_salve/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(!iscarbon(exposed_mob) || (exposed_mob.stat == DEAD))
		return

	if(methods & (INGEST|VAPOR|INJECT))
		exposed_mob.adjust_nutrition(-5)
		if(show_message)
			to_chat(exposed_mob, span_warning("Your stomach feels empty and cramps!"))

	if(methods & (PATCH|TOUCH))
		var/mob/living/carbon/exposed_carbon = exposed_mob
		for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
			surgery.speed_modifier = max(0.1, surgery.speed_modifier)

		if(show_message)
			to_chat(exposed_carbon, span_danger("You feel your injuries fade away to nothing!") )

/datum/reagent/medicine/mine_salve/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/mine_salve/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	description = "Slowly heals all damage types. Overdose will cause damage in all types instead."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	var/healing = 0.5
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(-healing * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustOxyLoss(-healing * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustBruteLoss(-healing * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-healing * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	..()
	. = TRUE

/datum/reagent/medicine/omnizine/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(1.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustOxyLoss(1.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustBruteLoss(1.5 * REM * delta_time, FALSE, FALSE, BODYTYPE_ORGANIC)
	affected_mob.adjustFireLoss(1.5 * REM * delta_time, FALSE, FALSE, BODYTYPE_ORGANIC)
	..()
	. = TRUE

/datum/reagent/medicine/omnizine/protozine
	name = "Protozine"
	description = "A less environmentally friendly and somewhat weaker variant of omnizine."
	color = "#d8c7b7"
	healing = 0.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/calomel
	name = "Calomel"
	description = "Quickly purges the body of toxic chemicals. Toxin damage is dealt if the patient is in good condition."
	reagent_state = LIQUID
	color = "#19C832"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "acid"
	ph = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/calomel/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	for(var/datum/reagent/toxin/R in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(R.type, 3 * REM * delta_time)
	if(affected_mob.health > 20)
		affected_mob.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	description = "Heals low toxin damage while the patient is irradiated, and will halt the damaging effects of radiation."
	reagent_state = LIQUID
	color = "#BAA15D"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	ph = 12 //It's a reducing agent
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/potass_iodide/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_HALT_RADIATION_EFFECTS, "[type]")

/datum/reagent/medicine/potass_iodide/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_HALT_RADIATION_EFFECTS, "[type]")
	return ..()

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if (HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		affected_mob.adjustToxLoss(-1 * REM * delta_time, required_biotype = affected_biotype)

	..()

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	description = "Reduces massive amounts of toxin damage while purging other chemicals from the body."
	reagent_state = LIQUID
	color = "#E6FFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 1 //One of the best buffers, NEVERMIND!
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/pen_acid/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_HALT_RADIATION_EFFECTS, "[type]")

/datum/reagent/medicine/pen_acid/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_HALT_RADIATION_EFFECTS, "[type]")
	return ..()

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(-2 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	for(var/datum/reagent/R in affected_mob.reagents.reagent_list)
		if(R != src)
			affected_mob.reagents.remove_reagent(R.type, 2 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	description = "Stimulates the healing of severe bruises. Extremely rapidly heals severe bruising and slowly heals minor ones. Overdose will worsen existing bruising."
	reagent_state = LIQUID
	color = "#D2D2D2"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 2.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getBruteLoss() > 25)
		affected_mob.adjustBruteLoss(-4 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	else
		affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	..()
	. = TRUE

/datum/reagent/medicine/sal_acid/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(affected_mob.getBruteLoss()) //It only makes existing bruises worse
		affected_mob.adjustBruteLoss(4.5 * REM * delta_time, FALSE, FALSE, BODYTYPE_ORGANIC) // it's going to be healing either 4 or 0.5
		. = TRUE
	..()

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	description = "Rapidly restores oxygen deprivation as well as preventing more of it to an extent."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOxyLoss(-3 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	if(affected_mob.losebreath >= 4)
		affected_mob.losebreath -= 2 * REM * delta_time
	..()
	. = TRUE

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	description = "Increases resistance to batons and movement speed, giving you hand cramps. Overdose deals toxin damage and inhibits breathing."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 12
	purity = REAGENT_STANDARD_PURITY
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 4) //1.6 per 2 seconds
	inverse_chem = /datum/reagent/inverse/corazargh
	inverse_chem_val = 0.4

/datum/reagent/medicine/ephedrine/on_mob_metabolize(mob/living/affected_mob)
	..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)
	ADD_TRAIT(affected_mob, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/medicine/ephedrine/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)
	REMOVE_TRAIT(affected_mob, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(DT_PROB(10 * (1-creation_purity), delta_time) && iscarbon(affected_mob))
		var/obj/item/I = affected_mob.get_active_held_item()
		if(I && affected_mob.dropItemToGround(I))
			to_chat(affected_mob, span_notice("Your hands spaz out and you drop what you were holding!"))
			affected_mob.set_jitter_if_lower(20 SECONDS)

	affected_mob.AdjustAllImmobility(-20 * REM * delta_time * normalise_creation_purity())
	affected_mob.adjustStaminaLoss(-1 * REM * delta_time * normalise_creation_purity(), FALSE)
	..()
	return TRUE

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(1 * (1 + (1-normalise_creation_purity())), delta_time) && iscarbon(affected_mob))
		var/datum/disease/D = new /datum/disease/heart_failure
		affected_mob.ForceContractDisease(D)
		to_chat(affected_mob, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
		affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, 0)

	if(DT_PROB(3.5 * (1 + (1-normalise_creation_purity())), delta_time))
		to_chat(affected_mob, span_notice("[pick("Your head pounds.", "You feel a tight pain in your chest.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")]"))

	if(DT_PROB(18 * (1 + (1-normalise_creation_purity())), delta_time))
		affected_mob.adjustToxLoss(1, FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		. = TRUE
	return TRUE

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	description = "Rapidly purges the body of Histamine and reduces jitteriness. Slight chance of causing drowsiness."
	reagent_state = LIQUID
	color = "#64FFE6"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 11.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(DT_PROB(5, delta_time))
		affected_mob.adjust_drowsiness(2 SECONDS)
	affected_mob.adjust_jitter(-2 SECONDS * REM * delta_time)
	holder.remove_reagent(/datum/reagent/toxin/histamine, 3 * REM * delta_time)
	..()

/datum/reagent/medicine/morphine
	name = "Morphine"
	description = "A painkiller that allows the patient to move at full speed even when injured. Causes drowsiness and eventually unconsciousness in high doses. Overdose will cause a variety of effects, ranging from minor to lethal."
	reagent_state = LIQUID
	color = "#A9FBFB"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 8.96
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 10)

/datum/reagent/medicine/morphine/on_mob_metabolize(mob/living/affected_mob)
	..()
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/morphine/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	..()

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(current_cycle >= 5)
		affected_mob.add_mood_event("numb", /datum/mood_event/narcotic_medium, name)
	switch(current_cycle)
		if(11)
			to_chat(affected_mob, span_warning("You start to feel tired...") )
		if(12 to 24)
			affected_mob.adjust_drowsiness(2 SECONDS * REM * delta_time)
		if(24 to INFINITY)
			affected_mob.Sleeping(40 * REM * delta_time)
			. = TRUE
	..()

/datum/reagent/medicine/morphine/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(18, delta_time))
		affected_mob.drop_all_held_items()
		affected_mob.set_dizzy_if_lower(4 SECONDS)
		affected_mob.set_jitter_if_lower(4 SECONDS)
	..()


/datum/reagent/medicine/oculine
	name = "Oculine"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#404040" //oculine is dark grey, inacusiate is light grey
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "dull toxin"
	purity = REAGENT_STANDARD_PURITY
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem = /datum/reagent/inverse/oculine
	inverse_chem_val = 0.45
	///The lighting alpha that the mob had on addition
	var/delta_light

/datum/reagent/medicine/oculine/on_mob_add(mob/living/affected_mob)
	if(!iscarbon(affected_mob))
		return
	RegisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/internal/eyes/eyes = affected_mob.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	improve_eyesight(affected_mob, eyes)

/datum/reagent/medicine/oculine/proc/improve_eyesight(mob/living/carbon/affected_mob, obj/item/organ/internal/eyes/eyes)
	delta_light = creation_purity*30
	if(eyes.lighting_alpha)
		eyes.lighting_alpha -= delta_light
	else
		eyes.lighting_alpha = 255 - delta_light
	eyes.see_in_dark += 3
	affected_mob.update_sight()

/datum/reagent/medicine/oculine/proc/restore_eyesight(mob/living/carbon/affected_mob, obj/item/organ/internal/eyes/eyes)
	eyes.lighting_alpha += delta_light
	eyes.see_in_dark -= 3
	affected_mob.update_sight()

/datum/reagent/medicine/oculine/proc/on_gained_organ(mob/affected_mob, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/eyes))
		return
	var/obj/item/organ/internal/eyes/affected_eyes = organ
	improve_eyesight(affected_mob, affected_eyes)

/datum/reagent/medicine/oculine/proc/on_removed_organ(mob/prev_affected_mob, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/eyes))
		return
	var/obj/item/organ/internal/eyes/eyes = organ
	restore_eyesight(prev_affected_mob, eyes)

/datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/normalized_purity = normalise_creation_purity()
	affected_mob.adjust_temp_blindness(-4 SECONDS * REM * delta_time * normalized_purity)
	affected_mob.adjust_eye_blur(-4 SECONDS * REM * delta_time * normalized_purity)
	var/obj/item/organ/internal/eyes/eyes = affected_mob.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		// Healing eye damage will cure nearsightedness and blindness from ... eye damage
		eyes.applyOrganDamage(-2 * REM * delta_time * normalise_creation_purity(), required_organtype = affected_organtype)
		// If our eyes are seriously damaged, we have a probability of causing eye blur while healing depending on purity
		if(eyes.damaged && DT_PROB(16 - min(normalized_purity * 6, 12), delta_time))
			// While healing, gives some eye blur
			if(affected_mob.is_blind_from(EYE_DAMAGE))
				to_chat(affected_mob, span_warning("Your vision slowly returns..."))
				affected_mob.adjust_eye_blur(20 SECONDS)
			else if(affected_mob.is_nearsighted_from(EYE_DAMAGE))
				to_chat(affected_mob, span_warning("The blackness in your peripheral vision begins to fade."))
				affected_mob.adjust_eye_blur(5 SECONDS)

	return ..()

/datum/reagent/medicine/oculine/on_mob_delete(mob/living/affected_mob)
	var/obj/item/organ/internal/eyes/eyes = affected_mob.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	restore_eyesight(affected_mob, eyes)
	..()

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	description = "Rapidly repairs damage to the patient's ears to cure deafness, assuming the source of said deafness isn't from genetic mutations, chronic deafness, or a total defecit of ears." //by "chronic" deafness, we mean people with the "deaf" quirk
	color = "#606060" // ditto
	ph = 2
	purity = REAGENT_STANDARD_PURITY
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/impurity/inacusiate

/datum/reagent/medicine/inacusiate/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if(creation_purity >= 1)
		RegisterSignal(affected_mob, COMSIG_MOVABLE_HEAR, PROC_REF(owner_hear))

//Lets us hear whispers from far away!
/datum/reagent/medicine/inacusiate/proc/owner_hear(datum/source, message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	SIGNAL_HANDLER
	if(!isliving(holder.my_atom))
		return
	var/mob/living/affected_mob = holder.my_atom
	var/atom/movable/composer = holder.my_atom
	if(message_mods[WHISPER_MODE])
		message = composer.compose_message(affected_mob, message_language, message, null, spans, message_mods)

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/obj/item/organ/internal/ears/ears = affected_mob.getorganslot(ORGAN_SLOT_EARS)
	if(!ears)
		return ..()
	ears.adjustEarDamage(-4 * REM * delta_time * normalise_creation_purity(), -4 * REM * delta_time * normalise_creation_purity())
	..()

/datum/reagent/medicine/inacusiate/on_mob_delete(mob/living/affected_mob)
	. = ..()
	UnregisterSignal(affected_mob, COMSIG_MOVABLE_HEAR)

/datum/reagent/medicine/atropine
	name = "Atropine"
	description = "If a patient is in critical condition, rapidly heals all damage types as well as regulating oxygen in the body. Excellent for stabilizing wounded patients, and said to neutralize blood-activated internal explosives found amongst clandestine black op agents."
	reagent_state = LIQUID
	color = "#1D3535" //slightly more blue, like epinephrine
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/atropine/on_mob_add(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION, "[type]")

/datum/reagent/medicine/atropine/on_mob_delete(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION, "[type]")
	return ..()

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.health <= affected_mob.crit_threshold)
		affected_mob.adjustToxLoss(-2 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustBruteLoss(-2* REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustFireLoss(-2 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustOxyLoss(-5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		. = TRUE
	affected_mob.losebreath = 0
	if(DT_PROB(10, delta_time))
		affected_mob.set_dizzy_if_lower(10 SECONDS)
		affected_mob.set_jitter_if_lower(10 SECONDS)
	..()

/datum/reagent/medicine/atropine/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	. = TRUE
	affected_mob.set_dizzy_if_lower(2 SECONDS * REM * delta_time)
	affected_mob.set_jitter_if_lower(2 SECONDS * REM * delta_time)
	..()

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	description = "Very minor boost to stun resistance. Slowly heals damage if a patient is in critical condition, as well as regulating oxygen loss. Overdose causes weakness and toxin damage."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 10.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/epinephrine/on_mob_metabolize(mob/living/carbon/affected_mob)
	..()
	ADD_TRAIT(affected_mob, TRAIT_NOCRITDAMAGE, type)

/datum/reagent/medicine/epinephrine/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_NOCRITDAMAGE, type)
	..()

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = TRUE
	if(holder.has_reagent(/datum/reagent/toxin/lexorin))
		holder.remove_reagent(/datum/reagent/toxin/lexorin, 2 * REM * delta_time)
		holder.remove_reagent(/datum/reagent/medicine/epinephrine, 1 * REM * delta_time)
		if(DT_PROB(10, delta_time))
			holder.add_reagent(/datum/reagent/toxin/histamine, 4)
		..()
		return
	if(affected_mob.health <= affected_mob.crit_threshold)
		affected_mob.adjustToxLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustFireLoss(-0.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	if(affected_mob.losebreath >= 4)
		affected_mob.losebreath -= 2 * REM * delta_time
	if(affected_mob.losebreath < 0)
		affected_mob.losebreath = 0
	affected_mob.adjustStaminaLoss(-0.5 * REM * delta_time, 0)
	if(DT_PROB(10, delta_time))
		affected_mob.AdjustAllImmobility(-20)
	..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(18, REM * delta_time))
		affected_mob.adjustStaminaLoss(2.5, 0)
		affected_mob.adjustToxLoss(1, FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		. = TRUE
	..()

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	description = "A miracle drug capable of bringing the dead back to life. Works topically unless anotamically complex, in which case works orally. Cannot revive targets under -%MAXHEALTHRATIO% health."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "magnets"
	harmful = TRUE
	ph = 0.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// The amount of damage a single unit of this will heal
	var/healing_per_reagent_unit = 5
	/// The ratio of the excess reagent used to contribute to excess healing
	var/excess_healing_ratio = 0.8
	/// Do we instantly revive
	var/instant = FALSE
	/// The maximum amount of damage we can revive from, as a ratio of max health
	var/max_revive_damage_ratio = 2

/datum/reagent/medicine/strange_reagent/instant
	name = "Stranger Reagent"
	instant = TRUE

/datum/reagent/medicine/strange_reagent/New()
	. = ..()
	description = replacetext(description, "%MAXHEALTHRATIO%", "[max_revive_damage_ratio * 100]%")
	if(instant)
		description += " It appears to be pulsing with a warm pink light."

// FEED ME SEYMOUR
/datum/reagent/medicine/strange_reagent/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!check_tray(chems, mytray))
		return

	mytray.spawnplant()

/// Calculates the amount of reagent to at a bare minimum make the target not dead
/datum/reagent/medicine/strange_reagent/proc/calculate_amount_needed_to_revive(mob/living/benefactor)
	var/their_health = benefactor.getMaxHealth() - (benefactor.getBruteLoss() + benefactor.getFireLoss())
	if(their_health > 0)
		return 1

	return round(-their_health / healing_per_reagent_unit, DAMAGE_PRECISION)

/// Calculates the amount of reagent that will be needed to both revive and full heal the target. Looks at healing_per_reagent_unit and excess_healing_ratio
/datum/reagent/medicine/strange_reagent/proc/calculate_amount_needed_to_full_heal(mob/living/benefactor)
	var/their_health = benefactor.getBruteLoss() + benefactor.getFireLoss()
	var/max_health = benefactor.getMaxHealth()
	if(their_health >= max_health)
		return 1

	var/amount_needed_to_revive = calculate_amount_needed_to_revive(benefactor)
	var/expected_amount_to_full_heal = round(max_health / healing_per_reagent_unit, DAMAGE_PRECISION) / excess_healing_ratio
	return amount_needed_to_revive + expected_amount_to_full_heal

/datum/reagent/medicine/strange_reagent/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	if(exposed_mob.stat != DEAD || !(exposed_mob.mob_biotypes & MOB_ORGANIC))
		return ..()

	if(exposed_mob.suiciding) //they are never coming back
		exposed_mob.visible_message(span_warning("[exposed_mob]'s body does not react..."))
		return

	if(iscarbon(exposed_mob) && !(methods & INGEST)) //simplemobs can still be splashed
		return ..()

	if(HAS_TRAIT(exposed_mob, TRAIT_HUSK))
		exposed_mob.visible_message(span_warning("[exposed_mob]'s body lets off a puff of smoke..."))
		return

	if((exposed_mob.getBruteLoss() + exposed_mob.getFireLoss()) > (exposed_mob.getMaxHealth() * max_revive_damage_ratio))
		exposed_mob.visible_message(span_warning("[exposed_mob]'s body convulses violently, before falling still..."))
		return

	var/needed_to_revive = calculate_amount_needed_to_revive(exposed_mob)
	if(reac_volume < needed_to_revive)
		exposed_mob.visible_message(span_warning("[exposed_mob]'s body convulses a bit, and then falls still once more."))
		exposed_mob.do_jitter_animation(10)
		return

	exposed_mob.visible_message(span_warning("[exposed_mob]'s body starts convulsing!"))
	exposed_mob.notify_ghost_cloning("Your body is being revived with Strange Reagent!")
	exposed_mob.do_jitter_animation(10)

	// we factor in healing needed when determing if we do anything
	var/healing = needed_to_revive * healing_per_reagent_unit
	// but excessive healing is penalized, to reward doctors who use the perfect amount
	reac_volume -= needed_to_revive
	healing += (reac_volume * healing_per_reagent_unit) * excess_healing_ratio

	// during unit tests, we want it to happen immediately
	if(instant)
		exposed_mob.do_strange_reagent_revival(healing)
	else
		// jitter immediately, after four seconds, and after eight seconds
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, do_jitter_animation), 1 SECONDS), 4 SECONDS)
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, do_strange_reagent_revival), healing), 7 SECONDS)
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, do_jitter_animation), 1 SECONDS), 8 SECONDS)

	return ..()

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/damage_at_random = rand(0, 250)/100 //0 to 2.5
	affected_mob.adjustBruteLoss(damage_at_random * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(damage_at_random * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	return ..()

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	description = "Efficiently restores brain damage."
	taste_description = "pleasant sweetness"
	color = "#A0A0A0" //mannitol is light grey, neurine is lighter grey
	ph = 10.4
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	purity = REAGENT_STANDARD_PURITY
	inverse_chem = /datum/reagent/inverse
	inverse_chem_val = 0.45

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2 * REM * delta_time * normalise_creation_purity(), required_organtype = affected_organtype)
	..()

//Having mannitol in you will pause the brain damage from brain tumor (so it heals an even 2 brain damage instead of 1.8)
/datum/reagent/medicine/mannitol/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)

/datum/reagent/medicine/mannitol/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	. = ..()

/datum/reagent/medicine/mannitol/overdose_start(mob/living/affected_mob)
	to_chat(affected_mob, span_notice("You suddenly feel <span class='purple'>E N L I G H T E N E D!</span>"))

/datum/reagent/medicine/mannitol/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(65, delta_time))
		return
	var/list/tips
	if(DT_PROB(50, delta_time))
		tips = world.file2list("strings/tips.txt")
	if(DT_PROB(50, delta_time))
		tips = world.file2list("strings/sillytips.txt")
	else
		tips = world.file2list("strings/chemistrytips.txt")
	var/message = pick(tips)
	send_tip_of_the_round(affected_mob, message)
	return ..()

/datum/reagent/medicine/neurine
	name = "Neurine"
	description = "Reacts with neural tissue, helping reform damaged connections. Can cure minor traumas."
	color = "#C0C0C0" //ditto
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED | REAGENT_DEAD_PROCESS
	purity = REAGENT_STANDARD_PURITY
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/neurine
	///brain damage level when we first started taking the chem
	var/initial_bdamage = 200

/datum/reagent/medicine/neurine/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_ANTICONVULSANT, name)
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(creation_purity >= 1)
		initial_bdamage = affected_carbon.getOrganLoss(ORGAN_SLOT_BRAIN)

/datum/reagent/medicine/neurine/on_mob_delete(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob, TRAIT_ANTICONVULSANT, name)
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(initial_bdamage < affected_carbon.getOrganLoss(ORGAN_SLOT_BRAIN))
		affected_carbon.setOrganLoss(ORGAN_SLOT_BRAIN, initial_bdamage)

/datum/reagent/medicine/neurine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(holder.has_reagent(/datum/reagent/consumable/ethanol/neurotoxin))
		holder.remove_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 5 * REM * delta_time * normalise_creation_purity())
	if(DT_PROB(8 * normalise_creation_purity(), delta_time))
		affected_mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	..()

/datum/reagent/medicine/neurine/on_mob_dead(mob/living/carbon/affected_mob, delta_time)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * REM * delta_time * normalise_creation_purity(), required_organtype = affected_organtype)
	..()

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	description = "Removes jitteriness and restores genetic defects."
	color = "#5096C8"
	taste_description = "acid"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	if(affected_mob.has_dna())
		affected_mob.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA), TRUE)
	if(!QDELETED(affected_mob)) //We were a monkey, now a human
		..()

/datum/reagent/medicine/antihol
	name = "Antihol"
	description = "Purges alcoholic substance from the patient's body and eliminates its side effects."
	color = "#00B4C8"
	taste_description = "raw egg"
	ph = 4
	purity = REAGENT_STANDARD_PURITY
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.35
	inverse_chem = /datum/reagent/inverse/antihol
	/// All status effects we remove on metabolize.
	/// Does not include drunk (despite what you may thing) as that's decresed gradually
	var/static/list/status_effects_to_clear = list(
		/datum/status_effect/confusion,
		/datum/status_effect/dizziness,
		/datum/status_effect/drowsiness,
		/datum/status_effect/speech/slurring/drunk,
	)

/datum/reagent/medicine/antihol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	for(var/effect in status_effects_to_clear)
		affected_mob.remove_status_effect(effect)
	affected_mob.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3 * REM * delta_time * normalise_creation_purity(), FALSE, TRUE)
	affected_mob.adjustToxLoss(-0.2 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjust_drunk_effect(-10 * REM * delta_time * normalise_creation_purity())
	..()
	. = TRUE

/datum/reagent/medicine/stimulants
	name = "Stimulants"
	description = "Increases resistance to batons and movement speed in addition to restoring minor damage and weakness. Overdose causes weakness and toxin damage."
	color = "#78008C"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	ph = 8.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	addiction_types = list(/datum/addiction/stimulants = 4) //0.8 per 2 seconds

/datum/reagent/medicine/stimulants/on_mob_metabolize(mob/living/affected_mob)
	..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	ADD_TRAIT(affected_mob, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/medicine/stimulants/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	REMOVE_TRAIT(affected_mob, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.health < 50 && affected_mob.health > 0)
		affected_mob.adjustOxyLoss(-1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustToxLoss(-1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustBruteLoss(-1 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustFireLoss(-1 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.AdjustAllImmobility(-60  * REM * delta_time)
	affected_mob.adjustStaminaLoss(-5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE

/datum/reagent/medicine/stimulants/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(18, delta_time))
		affected_mob.adjustStaminaLoss(2.5, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustToxLoss(1, FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		. = TRUE
	..()

/datum/reagent/medicine/insulin
	name = "Insulin"
	description = "Increases sugar depletion rates."
	reagent_state = LIQUID
	color = "#FFFFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 6.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/insulin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.AdjustSleeping(-20 * REM * delta_time))
		. = TRUE
	holder.remove_reagent(/datum/reagent/consumable/sugar, 3 * REM * delta_time)
	..()

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.

/datum/reagent/medicine/inaprovaline //is this used anywhere?
	name = "Inaprovaline"
	description = "Stabilizes the breathing of patients. Good for those in critical condition."
	reagent_state = LIQUID
	color = "#A4D8D8"
	ph = 8.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.losebreath >= 5)
		affected_mob.losebreath -= 5 * REM * delta_time
	..()

/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	description = "Gradually regenerates all types of damage, without harming slime anatomy."
	reagent_state = LIQUID
	color = "#CC23FF"
	taste_description = "jelly"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/regen_jelly/expose_mob(mob/living/exposed_mob, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob) || (reac_volume < 0.5))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	exposed_human.hair_color = "#CC22FF"
	exposed_human.facial_hair_color = "#CC22FF"
	exposed_human.update_body_parts()

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustBruteLoss(-1.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-1.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustOxyLoss(-1.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustToxLoss(-1.5 * REM * delta_time, FALSE, TRUE, affected_biotype) //heals TOXINLOVERs
	..()
	. = TRUE

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	description = "Miniature medical robots that swiftly restore bodily damage."
	reagent_state = SOLID
	color = "#555555"
	overdose_threshold = 30
	ph = 11
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustBruteLoss(-5 * REM * delta_time, FALSE) //A ton of healing - this is a 50 telecrystal investment.
	affected_mob.adjustFireLoss(-5 * REM * delta_time, FALSE)
	affected_mob.adjustOxyLoss(-15 * REM * delta_time, FALSE)
	affected_mob.adjustToxLoss(-5 * REM * delta_time, FALSE)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15 * REM * delta_time)
	affected_mob.adjustCloneLoss(-3 * REM * delta_time, FALSE)
	..()
	. = TRUE

/datum/reagent/medicine/syndicate_nanites/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired) //wtb flavortext messages that hint that you're vomitting up robots
	if(DT_PROB(13, delta_time))
		affected_mob.reagents.remove_reagent(type, metabolization_rate*15) // ~5 units at a rate of 0.4 but i wanted a nice number in code
		affected_mob.vomit(20) // nanite safety protocols make your body expel them to prevent harmies
	..()
	. = TRUE

/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	description = "Ichor from an extremely powerful plant. Great for restoring wounds, but it's a little heavy on the brain. For some strange reason, it also induces temporary pacifism in those who imbibe it and semi-permanent pacifism in those who overdose on it."
	color = "#FFAF00"
	metabolization_rate = REAGENTS_METABOLISM //Math is based on specific metab rate so we want this to be static AKA if define or medicine metab rate changes, we want this to stay until we can rework calculations.
	overdose_threshold = 25
	ph = 11
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 14)

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(current_cycle <= 25) //10u has to be processed before u get into THE FUN ZONE
		affected_mob.adjustBruteLoss(-1 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustFireLoss(-1 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustToxLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustCloneLoss(-0.1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustStaminaLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM * delta_time, 150, affected_organtype) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	else
		affected_mob.adjustBruteLoss(-5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype) //slow to start, but very quick healing once it gets going
		affected_mob.adjustFireLoss(-5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		affected_mob.adjustOxyLoss(-3 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustToxLoss(-3 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustCloneLoss(-1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjustStaminaLoss(-3 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		affected_mob.adjust_jitter_up_to(6 SECONDS * REM * delta_time, 1 MINUTES)
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * delta_time, 150, affected_organtype)
		if(DT_PROB(5, delta_time))
			affected_mob.say(pick("Yeah, well, you know, that's just, like, uh, your opinion, man.", "Am I glad he's frozen in there and that we're out here, and that he's the sheriff and that we're frozen out here, and that we're in there, and I just remembered, we're out here. What I wanna know is: Where's the caveman?", "It ain't me, it ain't me...", "Make love, not war!", "Stop, hey, what's that sound? Everybody look what's going down...", "Do you believe in magic in a young girl's heart?"), forced = /datum/reagent/medicine/earthsblood)
	affected_mob.adjust_drugginess_up_to(20 SECONDS * REM * delta_time, 30 SECONDS * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/medicine/earthsblood/on_mob_metabolize(mob/living/affected_mob)
	..()
	ADD_TRAIT(affected_mob, TRAIT_PACIFISM, type)

/datum/reagent/medicine/earthsblood/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_PACIFISM, type)
	..()

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjust_hallucinations_up_to(10 SECONDS * REM * delta_time, 120 SECONDS)
	if(current_cycle > 25)
		affected_mob.adjustToxLoss(4 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		if(current_cycle > 100) //podpeople get out reeeeeeeeeeeeeeeeeeeee
			affected_mob.adjustToxLoss(6 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	if(iscarbon(affected_mob))
		var/mob/living/carbon/hippie = affected_mob
		hippie.gain_trauma(/datum/brain_trauma/severe/pacifism)
	..()
	. = TRUE

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	description = "Increases depletion rates for most stimulating/hallucinogenic drugs. Reduces druggy effects and jitteriness. Severe stamina regeneration penalty, causes drowsiness. Small chance of brain damage."
	reagent_state = LIQUID
	color = "#27870a"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	ph = 4.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	harmful = TRUE

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	for(var/datum/reagent/drug/R in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(R.type, 5 * REM * delta_time)
	affected_mob.adjust_drowsiness(4 SECONDS * REM * delta_time)

	if(affected_mob.get_timed_status_effect_duration(/datum/status_effect/jitter) >= 6 SECONDS)
		affected_mob.adjust_jitter(-6 SECONDS * REM * delta_time)

	if (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) >= 10 SECONDS)
		affected_mob.adjust_hallucinations(-10 SECONDS * REM * delta_time)

	if(DT_PROB(10, delta_time))
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 50, affected_organtype)
	affected_mob.adjustStaminaLoss(2.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	return TRUE

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingadrenaline
	name = "Changeling Adrenaline"
	description = "Reduces the duration of unconciousness, knockdown and stuns. Restores stamina, but deals toxin damage when overdosed."
	color = "#C1151D"
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/changelingadrenaline/on_mob_life(mob/living/carbon/metabolizer, delta_time, times_fired)
	..()
	metabolizer.AdjustAllImmobility(-20 * REM * delta_time)
	metabolizer.adjustStaminaLoss(-10 * REM * delta_time, 0)
	metabolizer.set_jitter_if_lower(20 SECONDS * REM * delta_time)
	metabolizer.set_dizzy_if_lower(20 SECONDS * REM * delta_time)
	return TRUE

/datum/reagent/medicine/changelingadrenaline/on_mob_metabolize(mob/living/affected_mob)
	..()
	ADD_TRAIT(affected_mob, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(affected_mob, TRAIT_BATON_RESISTANCE, type)
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/changelingadrenaline/on_mob_end_metabolize(mob/living/affected_mob)
	..()
	REMOVE_TRAIT(affected_mob, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(affected_mob, TRAIT_BATON_RESISTANCE, type)
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	affected_mob.remove_status_effect(/datum/status_effect/dizziness)
	affected_mob.remove_status_effect(/datum/status_effect/jitter)

/datum/reagent/medicine/changelingadrenaline/overdose_process(mob/living/metabolizer, delta_time, times_fired)
	metabolizer.adjustToxLoss(1 * REM * delta_time, FALSE)
	..()
	return TRUE

/datum/reagent/medicine/changelinghaste
	name = "Changeling Haste"
	description = "Drastically increases movement speed, but deals toxin damage."
	color = "#AE151D"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/changelinghaste/on_mob_metabolize(mob/living/affected_mob)
	..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/changelinghaste/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)
	..()

/datum/reagent/medicine/changelinghaste/on_mob_life(mob/living/carbon/metabolizer, delta_time, times_fired)
	metabolizer.adjustToxLoss(2 * REM * delta_time, FALSE)
	..()
	return TRUE

/datum/reagent/medicine/higadrite
	name = "Higadrite"
	description = "A medication utilized to treat ailing livers."
	color = "#FF3542"
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/higadrite/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/higadrite/on_mob_end_metabolize(mob/living/affected_mob)
	..()
	REMOVE_TRAIT(affected_mob, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/cordiolis_hepatico
	name = "Cordiolis Hepatico"
	description = "A strange, pitch-black reagent that seems to absorb all light. Effects unknown."
	color = "#000000"
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/cordiolis_hepatico/on_mob_add(mob/living/affected_mob)
	..()
	ADD_TRAIT(affected_mob, TRAIT_STABLELIVER, type)
	ADD_TRAIT(affected_mob, TRAIT_STABLEHEART, type)

/datum/reagent/medicine/cordiolis_hepatico/on_mob_end_metabolize(mob/living/affected_mob)
	..()
	REMOVE_TRAIT(affected_mob, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(affected_mob, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/muscle_stimulant
	name = "Muscle Stimulant"
	description = "A potent chemical that allows someone under its influence to be at full physical ability even when under massive amounts of pain."
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/medicine/muscle_stimulant/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/muscle_stimulant/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/modafinil
	name = "Modafinil"
	description = "Long-lasting sleep suppressant that very slightly reduces stun and knockdown times. Overdosing has horrendous side effects and deals lethal oxygen damage, will knock you unconscious if not dealt with."
	reagent_state = LIQUID
	color = "#BEF7D8" // palish blue white
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 20 // with the random effects this might be awesome or might kill you at less than 10u (extensively tested)
	taste_description = "salt" // it actually does taste salty
	var/overdose_progress = 0 // to track overdose progress
	ph = 7.89
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/modafinil/on_mob_metabolize(mob/living/affected_mob)
	ADD_TRAIT(affected_mob, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/medicine/modafinil/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/medicine/modafinil/on_mob_life(mob/living/carbon/metabolizer, delta_time, times_fired)
	if(!overdosed) // We do not want any effects on OD
		overdose_threshold = overdose_threshold + ((rand(-10, 10) / 10) * REM * delta_time) // for extra fun
		metabolizer.AdjustAllImmobility(-5 * REM * delta_time)
		metabolizer.adjustStaminaLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		metabolizer.set_jitter_if_lower(1 SECONDS * REM * delta_time)
		metabolization_rate = 0.005 * REAGENTS_METABOLISM * rand(5, 20) // randomizes metabolism between 0.02 and 0.08 per second
		. = TRUE
	..()

/datum/reagent/medicine/modafinil/overdose_start(mob/living/affected_mob)
	to_chat(affected_mob, span_userdanger("You feel awfully out of breath and jittery!"))
	metabolization_rate = 0.025 * REAGENTS_METABOLISM // sets metabolism to 0.005 per second on overdose

/datum/reagent/medicine/modafinil/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	overdose_progress++
	switch(overdose_progress)
		if(1 to 40)
			affected_mob.adjust_jitter_up_to(2 SECONDS * REM * delta_time, 20 SECONDS)
			affected_mob.adjust_stutter_up_to(2 SECONDS * REM * delta_time, 20 SECONDS)
			affected_mob.set_dizzy_if_lower(10 SECONDS * REM * delta_time)
			if(DT_PROB(30, delta_time))
				affected_mob.losebreath++
		if(41 to 80)
			affected_mob.adjustOxyLoss(0.1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
			affected_mob.adjustStaminaLoss(0.1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
			affected_mob.adjust_jitter_up_to(2 SECONDS * REM * delta_time, 40 SECONDS)
			affected_mob.adjust_stutter_up_to(2 SECONDS * REM * delta_time, 40 SECONDS)
			affected_mob.set_dizzy_if_lower(20 SECONDS * REM * delta_time)
			if(DT_PROB(30, delta_time))
				affected_mob.losebreath++
			if(DT_PROB(10, delta_time))
				to_chat(affected_mob, span_userdanger("You have a sudden fit!"))
				affected_mob.emote("moan")
				affected_mob.Paralyze(20) // you should be in a bad spot at this point unless epipen has been used
		if(81)
			to_chat(affected_mob, span_userdanger("You feel too exhausted to continue!")) // at this point you will eventually die unless you get charcoal
			affected_mob.adjustOxyLoss(0.1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
			affected_mob.adjustStaminaLoss(0.1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		if(82 to INFINITY)
			REMOVE_TRAIT(affected_mob, TRAIT_SLEEPIMMUNE, type)
			affected_mob.Sleeping(100 * REM * delta_time)
			affected_mob.adjustOxyLoss(1.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
			affected_mob.adjustStaminaLoss(1.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	return TRUE

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "Suppresses anxiety and other various forms of mental distress. Overdose causes hallucinations and minor toxin damage."
	reagent_state = LIQUID
	color = "#07E79E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	ph = 9.12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/psicodine/on_mob_metabolize(mob/living/affected_mob)
	..()
	ADD_TRAIT(affected_mob, TRAIT_FEARLESS, type)

/datum/reagent/medicine/psicodine/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_FEARLESS, type)
	..()

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_jitter(-12 SECONDS * REM * delta_time)
	affected_mob.adjust_dizzy(-12 SECONDS * REM * delta_time)
	affected_mob.adjust_confusion(-6 SECONDS * REM * delta_time)
	affected_mob.disgust = max(affected_mob.disgust - (6 * REM * delta_time), 0)
	if(affected_mob.mob_mood != null && affected_mob.mob_mood.sanity <= SANITY_NEUTRAL) // only take effect if in negative sanity and then...
		affected_mob.mob_mood.set_sanity(min(affected_mob.mob_mood.sanity + (5 * REM * delta_time), SANITY_NEUTRAL)) // set minimum to prevent unwanted spiking over neutral
	..()
	. = TRUE

/datum/reagent/medicine/psicodine/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjust_hallucinations_up_to(10 SECONDS * REM * delta_time, 120 SECONDS)
	affected_mob.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE

/datum/reagent/medicine/metafactor
	name = "Mitogen Metabolism Factor"
	description = "This enzyme catalyzes the conversion of nutricious food into healing peptides."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	reagent_state = SOLID
	color = "#FFBE00"
	overdose_threshold = 10
	inverse_chem_val = 0.1 //Shouldn't happen - but this is so looking up the chem will point to the failed type
	inverse_chem = /datum/reagent/impurity/probital_failed
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/metafactor/overdose_start(mob/living/carbon/affected_mob)
	metabolization_rate = 2  * REAGENTS_METABOLISM

/datum/reagent/medicine/metafactor/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(DT_PROB(13, delta_time))
		affected_mob.vomit()
	..()

/datum/reagent/medicine/silibinin
	name = "Silibinin"
	description = "A thistle derrived hepatoprotective flavolignan mixture that help reverse damage to the liver."
	reagent_state = SOLID
	color = "#FFFFD0"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/silibinin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, -2 * REM * delta_time, required_organtype = affected_organtype)//Add a chance to cure liver trauma once implemented.
	..()
	. = TRUE

/datum/reagent/medicine/polypyr  //This is intended to be an ingredient in advanced chems.
	name = "Polypyrylium Oligomers"
	description = "A purple mixture of short polyelectrolyte chains not easily synthesized in the laboratory. It is valued as an intermediate in the synthesis of the cutting edge pharmaceuticals."
	reagent_state = SOLID
	color = "#9423FF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 50
	taste_description = "numbing bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/polypyr/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired) //I wanted a collection of small positive effects, this is as hard to obtain as coniine after all.
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjustBruteLoss(-0.35 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	return TRUE

/datum/reagent/medicine/polypyr/expose_mob(mob/living/carbon/human/exposed_human, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_human) || (reac_volume < 0.5))
		return
	exposed_human.hair_color = "#9922ff"
	exposed_human.facial_hair_color = "#9922ff"
	exposed_human.update_body_parts()

/datum/reagent/medicine/polypyr/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5 * REM * delta_time, required_organtype = affected_organtype)
	..()
	. = TRUE

/datum/reagent/medicine/granibitaluri
	name = "Granibitaluri" //achieve "GRANular" amounts of C2
	description = "A mild painkiller useful as an additive alongside more potent medicines. Speeds up the healing of small wounds and burns, but is ineffective at treating severe injuries. Extremely large doses are toxic, and may eventually cause liver failure."
	color = "#E0E0E0"
	reagent_state = LIQUID
	overdose_threshold = 50
	metabolization_rate = 0.5 * REAGENTS_METABOLISM //same as C2s
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/granibitaluri/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/healamount = max(0.5 - round(0.01 * (affected_mob.getBruteLoss() + affected_mob.getFireLoss()), 0.1), 0) //base of 0.5 healing per cycle and loses 0.1 healing for every 10 combined brute/burn damage you have
	affected_mob.adjustBruteLoss(-healamount * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-healamount * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	..()
	. = TRUE

/datum/reagent/medicine/granibitaluri/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = TRUE
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.2 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjustToxLoss(0.2 * REM * delta_time, FALSE, required_biotype = affected_biotype) //Only really deadly if you eat over 100u
	..()

// helps bleeding wounds clot faster
/datum/reagent/medicine/coagulant
	name = "Sanguirite"
	description = "A proprietary coagulant used to help bleeding wounds clot faster."
	reagent_state = LIQUID
	color = "#bb2424"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 20
	/// The bloodiest wound that the patient has will have its blood_flow reduced by about half this much each second
	var/clot_rate = 0.3
	/// While this reagent is in our bloodstream, we reduce all bleeding by this factor
	var/passive_bleed_modifier = 0.7
	/// For tracking when we tell the person we're no longer bleeding
	var/was_working
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/coagulant/on_mob_metabolize(mob/living/affected_mob)
	ADD_TRAIT(affected_mob, TRAIT_COAGULATING, /datum/reagent/medicine/coagulant)

	if(ishuman(affected_mob))
		var/mob/living/carbon/human/blood_boy = affected_mob
		blood_boy.physiology?.bleed_mod *= passive_bleed_modifier

	return ..()

/datum/reagent/medicine/coagulant/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_COAGULATING, /datum/reagent/medicine/coagulant)

	if(was_working)
		to_chat(affected_mob, span_warning("The medicine thickening your blood loses its effect!"))
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/blood_boy = affected_mob
		blood_boy.physiology?.bleed_mod /= passive_bleed_modifier

	return ..()

/datum/reagent/medicine/coagulant/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(!affected_mob.blood_volume || !affected_mob.all_wounds)
		return

	var/datum/wound/bloodiest_wound

	for(var/i in affected_mob.all_wounds)
		var/datum/wound/iter_wound = i
		if(iter_wound.blood_flow)
			if(iter_wound.blood_flow > bloodiest_wound?.blood_flow)
				bloodiest_wound = iter_wound

	if(bloodiest_wound)
		if(!was_working)
			to_chat(affected_mob, span_green("You can feel your flowing blood start thickening!"))
			was_working = TRUE
		bloodiest_wound.adjust_blood_flow(-clot_rate * REM * delta_time)
	else if(was_working)
		was_working = FALSE

/datum/reagent/medicine/coagulant/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = ..()
	if(!affected_mob.blood_volume)
		return

	if(DT_PROB(7.5, delta_time))
		affected_mob.losebreath += rand(2, 4)
		affected_mob.adjustOxyLoss(rand(1, 3), required_biotype = affected_biotype)
		if(prob(30))
			to_chat(affected_mob, span_danger("You can feel your blood clotting up in your veins!"))
		else if(prob(10))
			to_chat(affected_mob, span_userdanger("You feel like your blood has stopped moving!"))
			affected_mob.adjustOxyLoss(rand(3, 4), required_biotype = affected_biotype)

		if(prob(50))
			var/obj/item/organ/internal/lungs/our_lungs = affected_mob.getorganslot(ORGAN_SLOT_LUNGS)
			our_lungs.applyOrganDamage(1)
		else
			var/obj/item/organ/internal/heart/our_heart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
			our_heart.applyOrganDamage(1)

// i googled "natural coagulant" and a couple of results came up for banana peels, so after precisely 30 more seconds of research, i now dub grinding banana peels good for your blood
/datum/reagent/medicine/coagulant/banana_peel
	name = "Pulped Banana Peel"
	description = "Ancient Clown Lore says that pulped banana peels are good for your blood, but are you really going to take medical advice from a clown about bananas?"
	color = "#50531a" // rgb: 175, 175, 0
	taste_description = "horribly stringy, bitter pulp"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	clot_rate = 0.2
	passive_bleed_modifier = 0.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/banana_peel
	required_drink_type = /datum/reagent/medicine/coagulant/banana_peel
	name = "glass of banana peel pulp"
	desc = "Ancient Clown Lore says that pulped banana peels are good for your blood, \
		but are you really going to take medical advice from a clown about bananas?"

/datum/reagent/medicine/coagulant/seraka_extract
	name = "Seraka Extract"
	description = "A deeply coloured oil present in small amounts in Seraka Mushrooms. Acts as an effective blood clotting agent, but has a low overdose threshold."
	color = "#00767C"
	taste_description = "intensely savoury bitterness"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	clot_rate = 0.4 //slightly better than regular coagulant
	passive_bleed_modifier = 0.5
	overdose_threshold = 10 //but easier to overdose on

/datum/glass_style/drinking_glass/seraka_extract
	required_drink_type = /datum/reagent/medicine/coagulant/seraka_extract
	name = "glass of seraka extract"
	desc = "Deeply savoury, bitter, and makes your blood clot up in your veins. A great drink, all things considered."
