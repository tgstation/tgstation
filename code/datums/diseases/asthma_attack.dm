GLOBAL_LIST_INIT(asthma_attack_rarities, list(
	/datum/disease/asthma_attack/minor = 500,
	/datum/disease/asthma_attack/moderate = 400,
	/datum/disease/asthma_attack/severe = 50,
	/datum/disease/asthma_attack/critical = 5 // very rare
))

/datum/disease/asthma_attack
	form = "Bronchitis"
	name = "Asthma attack"
	desc = "Subject is undergoing a autoimmune response which threatens to close the esophagus and halt all respiration, leading to death. \
	Minor asthma attacks may disappear on their own, but all are dangerous."
	cure_text = "Albuterol/Surgical intervention"
	cures = list(/datum/reagent/medicine/albuterol)
	agent = "Auto-immune"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CURABLE
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	spread_text = "None"
	visibility_flags = HIDDEN_PANDEMIC
	bypasses_immunity = TRUE
	disease_flags = CURABLE|INCREMENTAL_CURE
	required_organ = ORGAN_SLOT_LUNGS

	var/time_to_start_remission

	var/max_time_til_remission
	var/min_time_til_remission

	var/in_remission = FALSE

	var/progress_to_stage_demotion = 0
	var/progress_to_demotion_per_second = 1
	var/progress_needed_to_demote = 10

	var/static/list/severity_to_suffix = list(
		DISEASE_SEVERITY_MEDIUM = "Minor",
		DISEASE_SEVERITY_HARMFUL = "Moderate",
		DISEASE_SEVERITY_DANGEROUS = "Severe",
		DISEASE_SEVERITY_BIOHAZARD = "EXTREME"
	)
	var/list/stage_to_inflammation_per_second

/datum/disease/asthma_attack/New()
	. = ..()

	suffix_name()

	time_to_start_remission = world.time + rand(min_time_til_remission, max_time_til_remission)

/datum/disease/asthma_attack/try_infect(mob/living/infectee, make_copy)
	if (!get_asthma_quirk())
		return FALSE
	if (HAS_TRAIT(infectee, TRAIT_NOBREATH))
		return FALSE

	return ..()

/datum/disease/asthma_attack/proc/suffix_name()
	name += " ([severity_to_suffix[severity]])"

/datum/disease/asthma_attack/proc/get_asthma_quirk(mob/living/target = affected_mob)
	RETURN_TYPE(/datum/quirk/item_quirk/asthma)

	return (locate(/datum/quirk/item_quirk/asthma) in target.quirks)

/datum/disease/asthma_attack/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if (!.)
		return

	if (HAS_TRAIT(affected_mob, TRAIT_NOBREATH))
		cure()
		return FALSE

	var/datum/quirk/item_quirk/asthma/asthma_quirk = get_asthma_quirk()
	var/inflammation = stage_to_inflammation_per_second["[stage]"]
	if (inflammation)
		asthma_quirk.adjust_inflammation(inflammation * seconds_per_tick)

	if (world.time >= time_to_start_remission)
		if (!in_remission)
			in_remission = TRUE
			stage_prob = 0
			name += " (Remission)"
			desc += " <i>The attack has entered remission. It will slowly decrease in intensity before vanishing.</i>"
		progress_to_stage_demotion += (progress_to_demotion_per_second * seconds_per_tick)
		if (progress_to_stage_demotion >= progress_needed_to_demote)
			progress_to_stage_demotion = 0
			update_stage(stage - 1)

// TYPES OF ASTHMA ATTACK

/datum/disease/asthma_attack/minor
	severity = DISEASE_SEVERITY_MEDIUM
	stage_prob = 4

	max_time_til_remission = 80 SECONDS
	min_time_til_remission = 120 SECONDS
	max_stages = 3

	cure_chance = 25

	stage_to_inflammation_per_second = list(
		"2" = 0.1,
		"3" = 0.5
	)

/datum/disease/asthma_attack/minor/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if (!.)
		return FALSE

	if (SPT_PROB(5, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("Mucous runs down the back of your throat.", "You swallow excess mucus.")))

/datum/disease/asthma_attack/moderate
	severity = DISEASE_SEVERITY_HARMFUL
	stage_prob = 5

	max_time_til_remission = 80 SECONDS
	min_time_til_remission = 120 SECONDS
	max_stages = 4

	cure_chance = 25

	stage_to_inflammation_per_second = list(
		"2" = 1,
		"3" = 2,
		"4" = 4
	)

/datum/disease/asthma_attack/moderate/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if (!.)
		return FALSE

	if (SPT_PROB(15, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("Mucous runs down the back of your throat.", "You swallow excess mucus.")))

	if (stage >= 4)
		if (SPT_PROB(10, seconds_per_tick))
			to_chat(affected_mob, span_warning("You briefly choke on the mucus piling in your throat!"))
			affected_mob.losebreath++


/datum/disease/asthma_attack/severe
	severity = DISEASE_SEVERITY_DANGEROUS
	stage_prob = 6

	max_time_til_remission = 120 SECONDS
	min_time_til_remission = 80 SECONDS
	max_stages = 5

	cure_chance = 25

	stage_to_inflammation_per_second = list(
		"2" = 1,
		"3" = 3,
		"4" = 6,
		"5" = 8
	)

	visibility_flags = HIDDEN_SCANNER

/datum/disease/asthma_attack/severe/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if (!.)
		return FALSE

	if (stage > 1)
		visibility_flags &= ~HIDDEN_SCANNER // revealed

	if (SPT_PROB(15, seconds_per_tick))
		to_chat(affected_mob, span_warning(pick("Mucous runs down the back of your throat.", "You swallow excess mucus.")))
	else if (SPT_PROB(20, seconds_per_tick))
		affected_mob.emote("cough")

	if (stage >= 4)
		if (SPT_PROB(15, seconds_per_tick))
			to_chat(affected_mob, span_warning("You briefly choke on the mucus piling in your throat!"))
			affected_mob.losebreath++

/datum/disease/asthma_attack/critical
	severity = DISEASE_SEVERITY_BIOHAZARD
	stage_prob = 85

	max_time_til_remission = 60 SECONDS // this kills you extremely quickly, so its fair
	min_time_til_remission = 40 SECONDS
	max_stages = 6

	cure_chance = 30

	stage_to_inflammation_per_second = list(
		"1" = 5,
		"2" = 6,
		"3" = 7,
		"4" = 10,
		"5" = 20,
		"6" = 500 // youre fucked frankly
	)

	var/warned_user = FALSE
	var/max_stage_reached = FALSE

/datum/disease/asthma_attack/critical/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if (!.)
		return FALSE

	if (stage < 5)
		if (SPT_PROB(75, seconds_per_tick))
			to_chat(affected_mob, span_warning(pick("Mucous runs down the back of your throat.", "You swallow excess mucus.")))

	var/wheeze_chance
	if (!warned_user && stage >= 5)
		to_chat(affected_mob, span_userdanger("You feel like your lungs are filling with fluid! It's getting incredibly hard to breathe!"))
		warned_user = TRUE

	switch (stage)
		if (1)
			wheeze_chance = 0
		if (2)
			wheeze_chance = 20
		if (3)
			wheeze_chance = 40
		if (4)
			wheeze_chance = 60
		if (5)
			wheeze_chance = 80
			if (!in_remission)
				stage_prob = 10 // slow it down significantly
		if (6)
			if (!max_stage_reached)
				max_stage_reached = TRUE
				to_chat(affected_mob, span_userdanger("You feel your windpipe squeeze shut!"))
			wheeze_chance = 0
			if (SPT_PROB(40, seconds_per_tick))
				affected_mob.emote("gag")
			var/datum/quirk/item_quirk/asthma/asthma_quirk = get_asthma_quirk()
			asthma_quirk.adjust_inflammation(INFINITY)

	if (SPT_PROB(wheeze_chance, seconds_per_tick))
		affected_mob.emote("wheeze")

	if (stage >= 4)
		if (SPT_PROB(15, seconds_per_tick))
			to_chat(affected_mob, span_warning("You briefly choke on the mucus piling in your throat!"))
			affected_mob.losebreath++


