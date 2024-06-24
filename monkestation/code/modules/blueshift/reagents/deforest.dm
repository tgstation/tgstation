/datum/reagent/medicine/lidocaine
	name = "Lidocaine"
	description = "A numbing agent used often for surgeries, metabolizes slowly."
	reagent_state = LIQUID
	color = "#6dbdbd" // 109, 189, 189
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 20
	ph = 6.09
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	inverse_chem_val = 0.55
	inverse_chem = /datum/reagent/inverse/lidocaine
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/medicine/lidocaine/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART,3 * REM * seconds_per_tick, 80)

//Inverse Medicines//

/datum/reagent/inverse/lidocaine
	name = "Lidopaine"
	description = "A paining agent used often for... being a jerk, metabolizes faster than lidocaine."
	reagent_state = LIQUID
	color = "#85111f" // 133, 17, 31
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	ph = 6.09
	tox_damage = 0

/datum/reagent/inverse/lidocaine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	to_chat(affected_mob, span_userdanger("Your body aches with unimaginable pain!"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART,3 * REM * seconds_per_tick, 85)
	affected_mob.stamina?.adjust(-5 * REM * seconds_per_tick, 0)
	if(prob(30))
		INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), "scream")

//Medigun Clotting Medicine
/datum/reagent/medicine/coagulant/fabricated
	name = "fabricated coagulant"
	description = "A synthesized coagulant created by Mediguns."
	color = "#ff7373" //255, 155. 155
	clot_rate = 0.15 //Half as strong as standard coagulant
	passive_bleed_modifier = 0.5 // around 2/3 the bleeding reduction


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
	reagent_state = LIQUID
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

	our_guy.stamina?.adjust(10 * REM * seconds_per_tick)
	our_guy.AdjustSleeping(-20 * REM * seconds_per_tick)
	our_guy.adjust_drowsiness(-5 * REM * seconds_per_tick)

	if(SPT_PROB(25, seconds_per_tick))
		our_guy.playsound_local(our_guy, 'sound/effects/singlebeat.ogg', 100, TRUE)
		flash_color(our_guy, flash_color = "#ff0000", flash_time = 3 SECONDS)

	if(SPT_PROB(5, seconds_per_tick))
		hurt_that_mans_organs(our_guy, 3, FALSE)

	if(locate(/datum/reagent/drug/twitch) in our_guy.reagents.reagent_list) // Combining this with twitch could cause some heart attack problems
		our_guy.infect_disease_predefined(DISEASE_HEART, TRUE)


/datum/reagent/drug/demoneye/overdose_process(mob/living/carbon/our_guy, seconds_per_tick, times_fired)
	. = ..()

	our_guy.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

	if(SPT_PROB(10, seconds_per_tick))
		hurt_that_mans_organs(our_guy, 5, TRUE)


/// Hurts a random organ, if its 'really_bad' we'll vomit blood too
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

#define CONSTANT_DOSE_SAFE_LIMIT 60

#define TWITCH_SCREEN_FILTER "twitch_screen_filter"
#define TWITCH_SCREEN_BLUR "twitch_screen_blur"

#define TWITCH_BLUR_EFFECT "twitch_dodge_blur"
#define TWITCH_OVERDOSE_BLUR_EFFECT "twitch_overdose_blur"

// Reaction to make twitch, makes 10u from 17u input reagents
/datum/chemical_reaction/twitch
	results = list(
		/datum/reagent/drug/twitch = 10,
	)
	required_reagents = list(
		/datum/reagent/impedrezene = 5,
		/datum/reagent/bluespace = 10,
		/datum/reagent/consumable/liquidelectricity = 2,
	)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

// Twitch drug, makes the takers of it faster and able to dodge bullets while in their system, to potentially bad side effects
/datum/reagent/drug/twitch
	name = "TWitch"
	description = "A drug originally developed by and for plutonians to assist them during raids. \
		Does not see wide use due to the whole reality-disassociation and heart disease thing afterwards. \
		Can be intentionally overdosed to increase the drug's effects"
	reagent_state = LIQUID
	color = "#c22a44"
	taste_description = "television static"
	metabolization_rate = 0.65 * REAGENTS_METABOLISM
	ph = 3
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 20)
	process_flags = ORGANIC | SYNTHETIC
	/// How much time has the drug been in them?
	var/constant_dose_time = 0
	/// What type of span class do we change heard speech to?
	var/speech_effect_span
	/// How much the mob heating is multiplied by, if the target is a robot or has muscled veins
	var/mob_heating_muliplier = 5


/datum/reagent/drug/twitch/on_mob_metabolize(mob/living/our_guy)
	. = ..()

	our_guy.add_movespeed_modifier(/datum/movespeed_modifier/reagent/twitch)
	our_guy.next_move_modifier -= 0.3 // For the duration of this you move and attack faster

	our_guy.sound_environment_override = SOUND_ENVIRONMENT_DIZZY

	speech_effect_span = "green"

	RegisterSignal(our_guy, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	RegisterSignal(our_guy, COMSIG_MOVABLE_HEAR, PROC_REF(distort_hearing))

	if(!our_guy.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = our_guy.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/static/list/col_filter_green = list(0.5,0,0,0, 0,1,0,0, 0,0,0.5,0, 0,0,0,1)
	var/static/list/col_filter_purple = list(1,0,0,0, 0,0.5,0,0, 0,0,1,0, 0,0,0,1)

	var/color_filter_to_use = col_filter_green
	if(overdosed)
		color_filter_to_use = col_filter_purple

	game_plane_master_controller.add_filter(TWITCH_SCREEN_FILTER, 10, color_matrix_filter(color_filter_to_use, FILTER_COLOR_RGB))

	game_plane_master_controller.add_filter(TWITCH_SCREEN_BLUR, 1, list("type" = "radial_blur", "size" = 0.02))


/datum/reagent/drug/twitch/on_mob_end_metabolize(mob/living/carbon/our_guy)
	. = ..()

	our_guy.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/twitch)
	our_guy.next_move_modifier += (overdosed ? 0.5 : 0.3)

	our_guy.sound_environment_override = NONE

	speech_effect_span = "hierophant"

	UnregisterSignal(our_guy, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(our_guy, COMSIG_MOVABLE_HEAR)
	if(overdosed)
		UnregisterSignal(our_guy, COMSIG_ATOM_PRE_BULLET_ACT)

	if(constant_dose_time < CONSTANT_DOSE_SAFE_LIMIT) // Anything less than this and you'll come out fiiiine, aside from a big hit of stamina damage
		if(!(our_guy.mob_biotypes & MOB_ROBOTIC))
			our_guy.visible_message(
				span_danger("[our_guy] suddenly slows from [our_guy.p_their()] inhuman speeds, coming back with a wicked nosebleed!"),
				span_danger("You suddenly slow back to normal, a stream of blood gushing from your nose!")
			)
		else
			our_guy.visible_message(
				span_danger("[our_guy] suddenly slows from [our_guy.p_their()] inhuman speeds!"),
				span_danger("You suddenly slow back to normal speed!")
			)
		our_guy.stamina.adjust(-constant_dose_time)

	else // Much longer than that however, and you're not gonna have a good day
		if(!(our_guy.mob_biotypes & MOB_ROBOTIC))
			our_guy.spray_blood(our_guy.dir, 2) // The before mentioned coughing up blood
			our_guy.emote("cough")
			our_guy.visible_message(
				span_danger("[our_guy] suddenly snaps back from [our_guy.p_their()] inhuman speeds, coughing up a spray of blood!"),
				span_danger("As you snap back to normal speed you cough up a worrying amount of blood. You feel like you've just been run over by a power loader.")
			)
		else
			our_guy.visible_message(
				span_danger("[our_guy] suddenly snaps back from [our_guy.p_their()] inhuman speeds!"),
				span_danger("You suddenly snap back to normal speeds. You feel like you've just been run over by a power loader.")
			)
		our_guy.stamina.adjust(-constant_dose_time)
		if(!HAS_TRAIT(our_guy, TRAIT_TWITCH_ADAPTED))
			our_guy.adjustOrganLoss(ORGAN_SLOT_HEART, 0.3 * constant_dose_time) // Basically you might die

	if(!our_guy.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = our_guy.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter(TWITCH_SCREEN_FILTER)
	game_plane_master_controller.remove_filter(TWITCH_SCREEN_BLUR)


/// Leaves an afterimage behind the mob when they move
/datum/reagent/drug/twitch/proc/on_movement(mob/living/carbon/our_guy, atom/old_loc)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/decoy/twitch_afterimage(old_loc, our_guy)


/// Tries to dodge incoming bullets if we aren't disabled for any reasons
/datum/reagent/drug/twitch/proc/dodge_bullets(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_INCAPACITATED))
		return NONE
	source.visible_message(
		span_danger("[source] effortlessly dodges [hitting_projectile]!"),
		span_userdanger("You effortlessly evade [hitting_projectile]!"),
	)
	playsound(source, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
	source.add_filter(TWITCH_BLUR_EFFECT, 2, gauss_blur_filter(5))
	addtimer(CALLBACK(source, TYPE_PROC_REF(/datum, remove_filter), TWITCH_BLUR_EFFECT), 0.5 SECONDS)
	return COMPONENT_BULLET_PIERCED


/datum/reagent/drug/twitch/on_mob_life(mob/living/carbon/our_guy, seconds_per_tick, times_fired)
	. = ..()

	constant_dose_time += seconds_per_tick

	// If the target is a robot, or has muscle veins, then they get an effect similar to herignis, heating them up quite a bit
	if((our_guy.mob_biotypes & MOB_ROBOTIC) || HAS_TRAIT(our_guy, TRAIT_STABLEHEART))
		var/heating = mob_heating_muliplier * creation_purity * REM * seconds_per_tick
		our_guy.reagents?.chem_temp += heating
		our_guy.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)
		if(!ishuman(our_guy))
			return
		var/mob/living/carbon/human/human = our_guy
		human.adjust_coretemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)
	else
		our_guy.adjustOrganLoss(ORGAN_SLOT_HEART, 0.1 * REM * seconds_per_tick)

	if(locate(/datum/reagent/drug/kronkaine) in our_guy.reagents.reagent_list) // Kronkaine, another heart-straining drug, could cause problems if mixed with this
		our_guy.infect_disease_predefined(DISEASE_TRAUMA, TRUE, "[ROUND_TIME()] Infected From Krokaine")


/datum/reagent/drug/twitch/overdose_start(mob/living/our_guy)
	. = ..()

	RegisterSignal(our_guy, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(dodge_bullets))

	our_guy.next_move_modifier -= 0.2 // Overdosing makes you a liiitle faster but you know has some really bad consequences

	if(!our_guy.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = our_guy.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_ourple = list(1,0,0,0, 0,0.5,0,0, 0,0,1,0, 0,0,0,1)

	for(var/filter in game_plane_master_controller.get_filters(TWITCH_SCREEN_FILTER))
		animate(filter, loop = -1, color = col_filter_ourple, time = 4 SECONDS, easing = BOUNCE_EASING)


/datum/reagent/drug/twitch/overdose_process(mob/living/carbon/our_guy, seconds_per_tick, times_fired)
	. = ..()
	our_guy.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

	// If the target is a robot, or has muscle veins, then they get an effect similar to herignis, heating them up quite a bit
	if((our_guy.mob_biotypes & MOB_ROBOTIC) || HAS_TRAIT(our_guy, TRAIT_STABLEHEART))
		var/heating = (mob_heating_muliplier * 2) * creation_purity * REM * seconds_per_tick
		our_guy.reagents?.chem_temp += heating
		our_guy.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)
		if(!ishuman(our_guy))
			return
		var/mob/living/carbon/human/human = our_guy
		human.adjust_coretemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT)
	else
		our_guy.adjustOrganLoss(ORGAN_SLOT_HEART, 1 * REM * seconds_per_tick, required_organtype = affected_organtype)
	our_guy.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)

	if(SPT_PROB(5, seconds_per_tick) && !(our_guy.mob_biotypes & MOB_ROBOTIC))
		to_chat(our_guy, span_danger("You cough up a splatter of blood!"))
		our_guy.spray_blood(our_guy.dir, 1)
		our_guy.emote("cough")

	if(SPT_PROB(10, seconds_per_tick))
		our_guy.add_filter(TWITCH_OVERDOSE_BLUR_EFFECT, 2, phase_filter(8))
		addtimer(CALLBACK(our_guy, TYPE_PROC_REF(/datum, remove_filter), TWITCH_OVERDOSE_BLUR_EFFECT), 0.5 SECONDS)

/// Changes heard message spans into that defined on the drug earlier
/datum/reagent/drug/twitch/proc/distort_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	hearing_args[HEARING_RAW_MESSAGE] = "<span class='[speech_effect_span]'>[hearing_args[HEARING_RAW_MESSAGE]]</span>"


/// Cool filter that I'm using for some of this :)))
/proc/phase_filter(size)
	. = list("type" = "wave")
	.["x"] = 1
	if(!isnull(size))
		.["size"] = size


// Temp visual that changes color for that bootleg sandevistan effect
/obj/effect/temp_visual/decoy/twitch_afterimage
	duration = 0.75 SECONDS
	/// The color matrix it should be at spawn
	var/list/matrix_start = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0.1,0.4,0)
	/// The color matrix it should be by the time it despawns
	var/list/matrix_end = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0.5,0,0)

/obj/effect/temp_visual/decoy/twitch_afterimage/Initialize(mapload)
	. = ..()
	color = matrix_start
	animate(src, color = matrix_end, time = duration, easing = EASE_OUT)
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

// Movespeed modifier used by twitch when someone has it in their system
/datum/movespeed_modifier/reagent/twitch
	multiplicative_slowdown = -0.4

#undef TWITCH_SCREEN_FILTER
#undef TWITCH_SCREEN_BLUR

#undef TWITCH_BLUR_EFFECT
#undef TWITCH_OVERDOSE_BLUR_EFFECT

// a potent coolant that treats synthetic burns at decent efficiency. compared to hercuri its worse, but without
// the lethal side effects, opting for a movement speed decrease instead
/datum/reagent/dinitrogen_plasmide
	name = "Dinitrogen Plasmide"
	description = "A compound of nitrogen and stabilized plasma, this substance has the ability to flash-cool overheated metals \
	while avoiding excessive damage. Being a heavy compound, it has the effect of slowing anything that metabolizes it."
	ph = 4.8
	specific_heat = SPECIFIC_HEAT_PLASMA * 1.2
	color = "#b779cc"
	taste_description = "dull plasma"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	process_flags = ORGANIC | SYNTHETIC
	overdose_threshold = 60 // it takes a lot, if youre really messed up you CAN hit this but its unlikely
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/dinitrogen_plasmide/on_mob_metabolize(mob/living/affected_mob)
	. = ..()

	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide)
	to_chat(affected_mob, span_warning("Your joints suddenly feel stiff."))

/datum/reagent/dinitrogen_plasmide/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()

	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide_overdose)
	to_chat(affected_mob, span_warning("Your joints no longer feel stiff!"))

/datum/reagent/dinitrogen_plasmide/overdose_start(mob/living/affected_mob)
	. = ..()

	to_chat(affected_mob, span_danger("You feel like your joints are filling with some viscous fluid!"))
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/dinitrogen_plasmide_overdose)

/datum/reagent/dinitrogen_plasmide/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	holder.remove_reagent(type, 1.2 * seconds_per_tick) // decays
	holder.add_reagent(/datum/reagent/stable_plasma, 0.4 * seconds_per_tick)
	holder.add_reagent(/datum/reagent/nitrogen, 0.8 * seconds_per_tick)

/datum/movespeed_modifier/dinitrogen_plasmide
	multiplicative_slowdown = 0.3

/datum/movespeed_modifier/dinitrogen_plasmide_overdose
	multiplicative_slowdown = 1.3

/datum/chemical_reaction/dinitrogen_plasmide_formation
	results = list(/datum/reagent/dinitrogen_plasmide = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/nitrogen = 2)
	required_catalysts = list(/datum/reagent/acetone = 0.1)
	required_temp = 400
	optimal_temp = 550
	overheat_temp = 590

	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_HEALING

/obj/item/reagent_containers/spray/dinitrogen_plasmide
	name = "coolant spray"
	desc = "A medical spray bottle. This one contains dinitrogen plasmide, a potent coolant commonly used to treat synthetic burns. \
	Has the side effect of causing movement slowdown."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "sprayer_med_yellow"
	list_reagents = list(/datum/reagent/dinitrogen_plasmide = 100)
