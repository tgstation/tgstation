/datum/reagent/drug/quaalude
	name = "Quaalude"
	description = "Relaxes the user, putting them in a hypnotic, drugged state. A favorite drug of kids from Brooklyn." //THAT WAS THE BEST FUCKIN DRUG EVER MADE
	reagent_state = LIQUID
	color = "#ffe669"
	overdose_threshold = 20
	ph = 8
	taste_description = "lemons"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drug/quaalude/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel relaxed.", "You feel like you're on the moon.", "You feel like you could walk 20 miles for a quaalude.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	if(M.hud_used!=null)
		var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.add_filter("quaalude_wave", 10, wave_filter(300, 300, 3, 0, WAVE_SIDEWAYS))
	M.set_drugginess(15 * REM * delta_time)
	if(!M.slurring)
		M.slurring = 10 * REM * delta_time
	M.Dizzy(5 * REM * delta_time)
	M.adjustStaminaLoss(-5 * REM * delta_time, 0)
	if(DT_PROB(3.5, delta_time))
		M.emote(pick("laugh","drool"))
	if(!HAS_TRAIT(M, TRAIT_FLOORED))
		if(DT_PROB(1, delta_time))
			M.visible_message("<span class='danger'>[M]'s legs become too weak to carry their own weight!</span>")
			M.Knockdown(90,TRUE)
			M.drop_all_held_items()
	..()

/datum/reagent/drug/quaalude/on_mob_end_metabolize(mob/living/carbon/M)
	if(M.hud_used!=null)
		var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.remove_filter("quaalude_wave")

/datum/reagent/drug/quaalude/overdose_process(mob/living/M, delta_time, times_fired)
	var/kidfrombrooklyn_message = pick("BRING BACK THE FUCKING QUAALUDES!", "I'd walk 20 miles for a quaalude, let me tell ya'!", "There's nothing like a fuckin' quaalude!")
	if(DT_PROB(1.5, delta_time))
		M.say("[kidfrombrooklyn_message]")
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * delta_time)
	M.adjustToxLoss(0.25 * REM * delta_time, 0)
	M.adjust_drowsyness(0.25 * REM * normalise_creation_purity() * delta_time)
	if(DT_PROB(3.5, delta_time))
		M.emote("twitch")
	..()
	. = TRUE
