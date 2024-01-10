/datum/reagent/adrenaline
	name = "Liquid Adrenaline"
	description = "Dangerous in large quantities"
	color = "#ffffff"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	overdose_threshold = 11
	metabolization_rate = 1

/datum/reagent/adrenaline/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	ADD_TRAIT(L, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/adrenaline/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	REMOVE_TRAIT(L, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/adrenaline/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	M.AdjustStun(-0.5 SECONDS)
	M.AdjustKnockdown(-0.5 SECONDS)
	M.AdjustUnconscious(-0.5 SECONDS)
	M.AdjustImmobilized(-0.5 SECONDS)
	M.AdjustParalyzed(-0.5 SECONDS)
	M.stamina?.adjust(20, forced = TRUE)

/datum/reagent/adrenaline/overdose_start(mob/living/M)
	. = ..()
	to_chat(M, span_danger("You can feel your everything start to hurt."))

/datum/reagent/adrenaline/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.2 * seconds_per_tick)
	if(SPT_PROB(18, seconds_per_tick))
		M.stamina?.adjust(-2.5, FALSE)
		M.adjustToxLoss(1, FALSE, required_biotype = affected_biotype)
		M.losebreath++
		. = TRUE
	..()
