/atom/movable/screen/fullscreen/color_vision/heroin_color
	color = "#444444"

/datum/reagent/drug/opium
	name = "Opium"
	description = "A extract from opium poppies. Puts the user in a slightly euphoric state."
	reagent_state = LIQUID
	color = "#ffe669"
	overdose_threshold = 30
	ph = 8
	taste_description = "flowers"
	addiction_types = list(/datum/addiction/opiods = 18)

/datum/reagent/drug/opium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel euphoric.", "You feel on top of the world.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smacked out", /datum/mood_event/narcotic_heavy, name)
	M.adjustBruteLoss(-0.1 * REM * delta_time, 0) //can be used as a (shitty) painkiller
	M.adjustFireLoss(-0.1 * REM * delta_time, 0)
	M.hal_screwyhud = SCREWYHUD_HEALTHY
	M.overlay_fullscreen("heroin_euphoria", /atom/movable/screen/fullscreen/color_vision/heroin_color)
	..()

/datum/reagent/drug/opium/overdose_process(mob/living/M, delta_time, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * delta_time)
	M.adjustToxLoss(1 * REM * delta_time, 0)
	M.adjust_drowsyness(0.5 * REM * normalise_creation_purity() * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/opium/on_mob_end_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = SCREWYHUD_NONE
		N.clear_fullscreen("heroin_euphoria")
	..()

/datum/reagent/drug/opium/heroin
	name = "Heroin"
	description = "She's like heroin to me, she's like heroin to me! She cannot... miss a vein!"
	reagent_state = LIQUID
	color = "#ffe669"
	overdose_threshold = 20
	ph = 6
	taste_description = "flowers"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	failed_chem = /datum/reagent/drug/opium/blacktar

/datum/reagent/drug/opium/heroin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel like nothing can stop you.", "You feel like God.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustBruteLoss(-0.4 * REM * delta_time, 0) //more powerful as a painkiller, possibly actually useful to medical now
	M.adjustFireLoss(-0.4 * REM * delta_time, 0)
	..()

/datum/reagent/drug/opium/blacktar
	name = "Black Tar Heroin"
	description = "An impure, freebase form of heroin. Probably not a good idea to take this..."
	reagent_state = LIQUID
	color = "#242423"
	overdose_threshold = 10 //more easy to overdose on
	ph = 8
	taste_description = "flowers"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	failed_chem = null

/datum/reagent/drug/opium/blacktar/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel like tar.", "The blood in your veins feel like syrup.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.set_drugginess(15 * REM * delta_time)
	M.adjustToxLoss(0.5 * REM * delta_time, 0) //toxin damage
	..()
