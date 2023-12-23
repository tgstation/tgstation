// Number of seconds to wait before incrementing stage.
#define HYPOGLYCEMIA_STAGE_DELAY 360

/datum/disease/hypoglycemia
	form = "Condition"
	name = "Hypoglycemic Shock"
	max_stages = 3
	stage_prob = 0
	cure_text = "Sugar"
	cures = list(/datum/reagent/consumable/sugar)
	cure_chance = 15
	agent = "Diabetes"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	desc = "If left untreated the subject will suffer from lethargy, dizziness, periodic loss of conciousness, and eventually death."
	severity = DISEASE_SEVERITY_DANGEROUS
	disease_flags = CURABLE
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "Organ failure"
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE
	// Number of seconds remaining until the next stage.
	var/stage_timer = HYPOGLYCEMIA_STAGE_DELAY

/datum/disease/hypoglycemia/after_add()
	to_chat(affected_mob, span_warning("You feel a cold sweat form."))


// Hypoglycemia Symptoms worsen and increase in variety as stage progresses:
// Stage 1 (alarming): Hunger, jiters, headache.
// Stage 2 (annoying): Dizzyness, confusion, slurring.
// Stage 3 (dangerous): Brain damage, seizures, drowsiness, loss of balance.
/datum/disease/hypoglycemia/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	// Increments stage on a delay until stage 3 is reached.
	if(stage < 3)
		stage_timer -= seconds_per_tick
		if(stage_timer < 1)
			stage_timer = HYPOGLYCEMIA_STAGE_DELAY
			update_stage(stage + 1)

	// Stage 1: Step right up and get some...
	// Hypoglycemic Ketoacidosis!
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("Your stomach rumbles."))
		affected_mob.adjust_nutrition(-1 * REM * seconds_per_tick)

	if(stage == 1)
		// Jitters.
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(affected_mob, span_warning(pick("You find it hard to stay still.", "Your heart beats quickly.", "You feel nervous.")))
			affected_mob.adjust_jitter_up_to(8 SECONDS, 32 SECONDS)
		
		// Headache.
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(affected_mob, span_warning(pick("Your head pounds.", "Your head hurts.")))
		
		return

	// Stage 2: There's more where that came from!
	// Confusion and slurring.
	if(SPT_PROB(2, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("You feel confused.", "You can't think straight.", "You forget for a moment what you were doing.", "Your mind blanks for a moment.")))
		affected_mob.set_confusion_if_lower(25 SECONDS)
		affected_mob.set_slurring_if_lower(25 SECONDS)
	
	// Excessively high heart-rate.
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("You feel your heart lurching in your chest!", "Your heart is beating so fast, it hurts!", "You feel your heart practically beating out of your chest!")))
		affected_mob.adjust_jitter_up_to(25 SECONDS, 50 SECONDS)

	if(stage == 2)
		// Very painful headache.
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(affected_mob, span_warning(pick("You feel a stabbing pain in your head.", "Your head pounds incessantly.", "Your head hurts a lot!")))

		// Dizziness
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(affected_mob, span_warning(pick("Your head spins", "You feel [pick("dizzy","woozy","faint")].")))
			affected_mob.adjust_dizzy_up_to(10 SECONDS, 30 SECONDS)

		// Lethargy.
		if(!affected_mob.IsUnconscious() && SPT_PROB(2.5, seconds_per_tick))
			to_chat(affected_mob, span_warning(pick("You feel lethargic.", "You feel tired.", "You feel very sleepy.")))
			affected_mob.adjustStaminaLoss(50, FALSE)
			affected_mob.adjust_eye_blur_up_to(4 SECONDS, 10 SECONDS)

		return

	// Stage 3: Let God sort 'em out.
	// Extremely painful headache and nerve/brain damage. Looks like Lady Luck just gave you the finger.
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("A wave of intense pain fills your head!", "You feel pain shoot down your arms and legs!")))
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * seconds_per_tick)

	// Prevents double-whammies, as most stage-3 symptoms can knock you out.
	if(affected_mob.IsUnconscious())
		return

	// Extreme lethargy and blackouts.
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("You have a hard time keeping your eyes open!", "You feel like you are going to pass out at any moment!")))
		affected_mob.adjustStaminaLoss(40, FALSE)
		affected_mob.adjust_drowsiness_up_to(10 SECONDS, 20 SECONDS)

	// Seizures.
	else if(SPT_PROB(2, seconds_per_tick))
		affected_mob.visible_message(span_danger("[affected_mob] starts having a seizure!"), span_userdanger("You have a seizure!"))
		affected_mob.Unconscious(25 SECONDS)
		affected_mob.adjust_jitter_up_to(25 SECONDS, 50 SECONDS)

	// Extreme dizziness.
	else if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("A wave of dizziness washes over you!", "You feel very weak and dizzy!")))
		affected_mob.adjust_dizzy_up_to(30 SECONDS, 60 SECONDS)

		// So dizzy you might fall over.
		if((affected_mob.body_position != LYING_DOWN) && SPT_PROB(10, seconds_per_tick))
			affected_mob.Knockdown(3 SECONDS)
			to_chat(affected_mob, span_warning("You lose your balance and fall!"))

#undef HYPOGLYCEMIA_STAGE_DELAY
