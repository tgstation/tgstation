//shit for effects
/datum/mood_event/stoned
	description = "<span class='nicegreen'>You're totally baked right now...</span>\n"
	mood_change = 6
	timeout = 3 MINUTES

/atom/movable/screen/alert/stoned
	name = "Stoned"
	desc = "You're stoned out of your mind! Woaaahh..."
	icon_state = "high"

//the reagent itself
/datum/reagent/drug/thc
	name = "THC"
	description = "A chemical found in cannabis that serves as its main psychoactive component."
	reagent_state = LIQUID
	color = "#cfa40c"
	overdose_threshold = 30 //just gives funny effects, but doesnt hurt you; thc has no actual known overdose
	ph = 6
	taste_description = "skunk"

/datum/reagent/drug/thc/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel relaxed.", "You feel fucked up.", "You feel totally wrecked...")
	if(M.hud_used!=null)
		var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.add_filter("weed_blur", 10, angular_blur_filter(0, 0, 0.45))
	if(DT_PROB(2.5, delta_time))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "stoned", /datum/mood_event/stoned, name)
	M.throw_alert("stoned", /atom/movable/screen/alert/stoned)
	M.sound_environment_override = SOUND_ENVIRONMENT_DRUGGED
	M.Dizzy(5 * REM * delta_time)
	M.adjust_nutrition(-1 * REM * delta_time) //munchies
	if(DT_PROB(3.5, delta_time))
		M.emote(pick("laugh","giggle"))
	..()

/datum/reagent/drug/thc/on_mob_end_metabolize(mob/living/carbon/M)
	if(M.hud_used!=null)
		var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.remove_filter("weed_blur")
	M.clear_alert("stoned")
	M.sound_environment_override = SOUND_ENVIRONMENT_NONE

/datum/reagent/drug/thc/overdose_process(mob/living/M, delta_time, times_fired)
	var/cg420_message = pick("It's major...", "Oh my goodness...",)
	if(DT_PROB(1.5, delta_time))
		M.say("[cg420_message]")
	M.adjust_drowsyness(0.1 * REM * normalise_creation_purity() * delta_time)
	if(DT_PROB(3.5, delta_time))
		playsound(M, pick('modular_skyrat/master_files/sound/effects/lungbust_cough1.ogg','modular_skyrat/master_files/sound/effects/lungbust_cough2.ogg'), 50, TRUE)
		M.emote("cough")
	..()
	. = TRUE

/datum/reagent/drug/thc/hash //only exists to generate hash object
	name = "hashish"
	description = "Concentrated cannabis extract. Delivers a much better high when used in a bong."
	color = "#cfa40c"
