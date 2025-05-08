#define CONSTANT_DOSE_SAFE_LIMIT 60
#define METABOLISM_END_LIMB_DAMAGE 20

// Chemical reaction, turns 25 input reagents into 25 output reagents, 10 of those being demoneye
/datum/chemical_reaction/demoneye
	results = list(
		/datum/reagent/drug/demoneye = 10,
		/datum/reagent/impurity/healing/medicine_failure = 10,
		/datum/reagent/impurity = 5,
	)
	required_reagents = list(
		/datum/reagent/medicine/ephedrine = 5,
		/datum/reagent/blood = 15,
		/datum/reagent/stable_plasma = 5,
	)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

// Demoneye, a drug that makes you temporarily immune to fear and crit, in exchange for damaging all of your organs and making your veins explode
/datum/reagent/drug/demoneye
	name = "DemonEye"
	description = "A performance enhancing drug originally developed on mars. \
		A favorite among gangs and other outlaws on the planet, though overuse can cause terrible addiction and bodily damage."
	color = "#af00be"
	taste_description = "industrial shuttle fuel"
	metabolization_rate = 0.65 * REAGENTS_METABOLISM
	ph = 7
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 15)
	metabolized_traits = list(TRAIT_UNNATURAL_RED_GLOWY_EYES, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_FEARLESS, TRAIT_ANALGESIA)
	/// How much time has the drug been in them?
	var/constant_dose_time = 0
	/// What the original color of the user's left eye is
	var/user_left_eye_color
	/// What the original color of the user's right eye is
	var/user_right_eye_color

/datum/reagent/drug/demoneye/on_mob_metabolize(mob/living/carbon/human/our_guy)
	. = ..()

	user_left_eye_color = our_guy.eye_color_left
	user_right_eye_color = our_guy.eye_color_right

	our_guy.eye_color_left = BLOODCULT_EYE
	our_guy.eye_color_right = BLOODCULT_EYE
	our_guy.update_body()

	our_guy.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC

	if(!our_guy.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = our_guy.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/static/list/col_filter_red = list(0.7,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1)

	game_plane_master_controller.add_filter("demoneye_filter", 10, color_matrix_filter(col_filter_red, FILTER_COLOR_RGB))

	game_plane_master_controller.add_filter("demoneye_blur", 1, list("type" = "angular_blur", "size" = 4))


/datum/reagent/drug/demoneye/on_mob_end_metabolize(mob/living/carbon/human/our_guy)
	. = ..()

	our_guy.eye_color_left = user_left_eye_color
	our_guy.eye_color_right = user_right_eye_color
	our_guy.update_body()

	our_guy.sound_environment_override = NONE

	if(constant_dose_time < CONSTANT_DOSE_SAFE_LIMIT || !our_guy.blood_volume)
		our_guy.visible_message(
				span_danger("[our_guy]'s eyes fade from their evil looking red back to normal..."),
				span_danger("Your vision slowly returns to normal as you lose your unnatural strength...")
		)
	else
		our_guy.visible_message(
			span_danger("[our_guy]'s veins violently explode, spraying blood everywhere!"),
			span_danger("Your veins burst from the sheer stress put on them!")
		)

		var/obj/item/bodypart/bodypart = pick(our_guy.bodyparts)
		var/datum/wound/slash/flesh/critical/crit_wound = new()
		crit_wound.apply_wound(bodypart)
		bodypart.receive_damage(brute = METABOLISM_END_LIMB_DAMAGE, wound_bonus = CANT_WOUND)

		new /obj/effect/temp_visual/cleave(our_guy.drop_location())

		if(overdosed && !our_guy.has_status_effect(/datum/status_effect/vulnerable_to_damage))
			our_guy.apply_status_effect(/datum/status_effect/vulnerable_to_damage)

	if(!our_guy.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = our_guy.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("demoneye_filter")
	game_plane_master_controller.remove_filter("demoneye_blur")


/datum/reagent/drug/demoneye/on_mob_life(mob/living/carbon/our_guy, seconds_per_tick, times_fired)
	. = ..()

	constant_dose_time += seconds_per_tick

	our_guy.add_mood_event("tweaking", /datum/mood_event/stimulant_heavy/sundowner, name)

	our_guy.adjustStaminaLoss(-10 * REM * seconds_per_tick)
	our_guy.AdjustSleeping(-20 * REM * seconds_per_tick)
	our_guy.adjust_drowsiness(-5 * REM * seconds_per_tick)

	if(SPT_PROB(25, seconds_per_tick))
		our_guy.playsound_local(our_guy, 'sound/effects/singlebeat.ogg', 100, TRUE)
		flash_color(our_guy, flash_color = "#ff0000", flash_time = 3 SECONDS)

	if(SPT_PROB(5, seconds_per_tick))
		hurt_that_mans_organs(our_guy, 3, FALSE)

	if(locate(/datum/reagent/drug/twitch) in our_guy.reagents.reagent_list) // Combining this with twitch could cause some heart attack problems
		our_guy.apply_status_effect(/datum/status_effect/heart_attack)


/datum/reagent/drug/demoneye/overdose_process(mob/living/carbon/our_guy, seconds_per_tick, times_fired)
	. = ..()

	our_guy.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

	if(SPT_PROB(10, seconds_per_tick))
		hurt_that_mans_organs(our_guy, 5, TRUE)


/// Hurts a random organ, if it's 'really_bad' we'll vomit blood too
/datum/reagent/drug/demoneye/proc/hurt_that_mans_organs(mob/living/carbon/our_guy, damage, really_bad = FALSE)
	/// List of organs we can randomly damage
	var/static/list/organs_we_damage = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)
	if(really_bad)
		our_guy.vomit(0, TRUE, FALSE, 1)
	our_guy.adjustOrganLoss(
		pick(organs_we_damage),
		damage,
	)

// Mood event used by demoneye, because the normal one I just didn't vibe with
/datum/mood_event/stimulant_heavy/sundowner
	description = "I'M FUCKING INVINCIBLE!!!!"

#undef CONSTANT_DOSE_SAFE_LIMIT
#undef METABOLISM_END_LIMB_DAMAGE
