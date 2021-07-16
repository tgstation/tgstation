/datum/reagent/drug
	name = "Drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 10) //4 per 2 seconds

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_drugginess(15 * REM * delta_time)
	if(isturf(M.loc) && !isspaceturf(M.loc) && !HAS_TRAIT(M, TRAIT_IMMOBILIZED) && DT_PROB(5, delta_time))
		step(M, pick(GLOB.cardinals))
	if(DT_PROB(3.5, delta_time))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You start tripping hard!"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/M, delta_time, times_fired)
	if(M.hallucination < volume && DT_PROB(10, delta_time))
		M.hallucination += 5
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	ph = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/nicotine = 18) // 7.2 per 2 seconds

	//Nicotine is used as a pesticide IRL.
/datum/reagent/drug/nicotine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjustToxic(round(chems.get_reagent_amount(type)))
		mytray.adjustPests(-rand(1,2))

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(0.5, delta_time))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, span_notice("[smoke_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	M.Jitter(0) //calms down any withdrawal jitters
	M.AdjustStun(-50  * REM * delta_time)
	M.AdjustKnockdown(-50 * REM * delta_time)
	M.AdjustUnconscious(-50 * REM * delta_time)
	M.AdjustParalyzed(-50 * REM * delta_time)
	M.AdjustImmobilized(-50 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/nicotine/overdose_process(mob/living/M, delta_time, times_fired)
	M.adjustToxLoss(0.1 * REM * delta_time, 0)
	M.adjustOxyLoss(1.1 * REM * delta_time, 0)
	..()
	. = TRUE

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage."
	reagent_state = LIQUID
	color = "#0064B4"
	overdose_threshold = 20
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opiods = 18) //7.2 per 2 seconds


/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smacked out", /datum/mood_event/narcotic_heavy, name)
	if(current_cycle == 35 && creation_purity <= 0.6)
		if(!istype(M.dna.species, /datum/species/krokodil_addict))
			to_chat(M, span_userdanger("Your skin falls off easily!"))
			M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
			M.set_species(/datum/species/krokodil_addict)
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M, delta_time, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM * delta_time)
	M.adjustToxLoss(0.25 * REM * delta_time, 0)
	..()
	. = TRUE



/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 12) //4.8 per 2 seconds

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	..()

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.AdjustStun(-40 * REM * delta_time)
	M.AdjustKnockdown(-40 * REM * delta_time)
	M.AdjustUnconscious(-40 * REM * delta_time)
	M.AdjustParalyzed(-40 * REM * delta_time)
	M.AdjustImmobilized(-40 * REM * delta_time)
	M.adjustStaminaLoss(-2 * REM * delta_time, 0)
	M.Jitter(2 * REM * delta_time)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1, 4) * REM * delta_time)
	if(DT_PROB(2.5, delta_time))
		M.emote(pick("twitch", "shiver"))
	..()
	. = TRUE

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M, delta_time, times_fired)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i in 1 to round(4 * REM * delta_time, 1))
			step(M, pick(GLOB.cardinals))
	if(DT_PROB(10, delta_time))
		M.emote("laugh")
	if(DT_PROB(18, delta_time))
		M.visible_message(span_danger("[M]'s hands flip out and flail everywhere!"))
		M.drop_all_held_items()
	..()
	M.adjustToxLoss(1 * REM * delta_time, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5, 10) / 10) * REM * delta_time)
	. = TRUE

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Makes you impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	taste_description = "salt" // because they're bathsalts?
	addiction_types = list(/datum/addiction/stimulants = 25)  //8 per 2 seconds
	var/datum/brain_trauma/special/psychotic_brawling/bath_salts/rage
	ph = 8.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		rage = new()
		C.gain_trauma(rage, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(rage)
		QDEL_NULL(rage)
	..()

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "salted", /datum/mood_event/stimulant_heavy, name)
	M.adjustStaminaLoss(-5 * REM * delta_time, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4 * REM * delta_time)
	M.hallucination += 5 * REM * delta_time
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		step(M, pick(GLOB.cardinals))
		step(M, pick(GLOB.cardinals))
	..()
	. = TRUE

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M, delta_time, times_fired)
	M.hallucination += 5 * REM * delta_time
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i in 1 to round(8 * REM * delta_time, 1))
			step(M, pick(GLOB.cardinals))
	if(DT_PROB(10, delta_time))
		M.emote(pick("twitch","drool","moan"))
	if(DT_PROB(28, delta_time))
		M.drop_all_held_items()
	..()

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 8)

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	M.adjustStaminaLoss(-18 * REM * delta_time, 0)
	M.adjustToxLoss(0.5 * REM * delta_time, 0)
	if(DT_PROB(30, delta_time))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = TRUE

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Fills you with ecstasic numbness and causes minor brain damage. Highly addictive. If overdosed causes sudden mood swings."
	reagent_state = LIQUID
	color = "#EE35FF"
	overdose_threshold = 20
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	taste_description = "paint thinner"
	addiction_types = list(/datum/addiction/hallucinogens = 18)

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")
	..()

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.jitteriness = 0
	M.set_confusion(0)
	M.disgust = 0
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/happiness/overdose_process(mob/living/M, delta_time, times_fired)
	if(DT_PROB(16, delta_time))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				M.emote("laugh")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				M.emote("sway")
				M.Dizzy(25)
			if(3)
				M.emote("frown")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/drug/pumpup
	name = "Pump-Up"
	description = "Take on the world! A fast acting, hard hitting drug that pushes the limit on what you can handle."
	reagent_state = LIQUID
	color = "#e38e44"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 6) //2.6 per 2 seconds

/datum/reagent/drug/pumpup/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)

/datum/reagent/drug/pumpup/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	..()

/datum/reagent/drug/pumpup/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.Jitter(5 * REM * delta_time)

	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[pick("Go! Go! GO!", "You feel ready...", "You feel invincible...")]"))
	if(DT_PROB(7.5, delta_time))
		M.losebreath++
		M.adjustToxLoss(2, 0)
	..()
	. = TRUE

/datum/reagent/drug/pumpup/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You can't stop shaking, your heart beats faster and faster..."))

/datum/reagent/drug/pumpup/overdose_process(mob/living/M, delta_time, times_fired)
	M.Jitter(5 * REM * delta_time)
	if(DT_PROB(2.5, delta_time))
		M.drop_all_held_items()
	if(DT_PROB(7.5, delta_time))
		M.emote(pick("twitch","drool"))
	if(DT_PROB(10, delta_time))
		M.losebreath++
		M.adjustStaminaLoss(4, 0)
	if(DT_PROB(7.5, delta_time))
		M.adjustToxLoss(2, 0)
	..()

/datum/reagent/drug/maint
	name = "Maintenance Drugs"
	chemical_flags = NONE

/datum/reagent/drug/maint/powder
	name = "Maintenance Powder"
	description = "An unknown powder that you most likely gotten from an assistant, a bored chemist... or cooked yourself. It is a refined form of tar that enhances your mental ability, making you learn stuff a lot faster."
	reagent_state = SOLID
	color = "#ffffff"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 14)

/datum/reagent/drug/maint/powder/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.1 * REM * delta_time)
	// 5x if you want to OD, you can potentially go higher, but good luck managing the brain damage.
	var/amt = max(round(volume/3, 0.1), 1)
	M?.mind?.experience_multiplier_reasons |= type
	M?.mind?.experience_multiplier_reasons[type] = amt * REM * delta_time

/datum/reagent/drug/maint/powder/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M?.mind?.experience_multiplier_reasons[type] = null
	M?.mind?.experience_multiplier_reasons -= type

/datum/reagent/drug/maint/powder/overdose_process(mob/living/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 6 * REM * delta_time)

/datum/reagent/drug/maint/sludge
	name = "Maintenance Sludge"
	description = "An unknown sludge that you most likely gotten from an assistant, a bored chemist... or cooked yourself. Half refined, it fills your body with itself, making it more resistant to wounds, but causes toxins to accumulate."
	reagent_state = LIQUID
	color = "#203d2c"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 25
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 8)

/datum/reagent/drug/maint/sludge/on_mob_metabolize(mob/living/L)

	. = ..()
	ADD_TRAIT(L,TRAIT_HARDLY_WOUNDED,type)

/datum/reagent/drug/maint/sludge/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustToxLoss(0.5 * REM * delta_time)

/datum/reagent/drug/maint/sludge/on_mob_end_metabolize(mob/living/M)
	. = ..()
	REMOVE_TRAIT(M,TRAIT_HARDLY_WOUNDED,type)

/datum/reagent/drug/maint/sludge/overdose_process(mob/living/M, delta_time, times_fired)
	. = ..()
	if(!iscarbon(M))
		return
	var/mob/living/carbon/carbie = M
	//You will be vomiting so the damage is really for a few ticks before you flush it out of your system
	carbie.adjustToxLoss(1 * REM * delta_time)
	if(DT_PROB(5, delta_time))
		carbie.adjustToxLoss(5)
		carbie.vomit()

/datum/reagent/drug/maint/tar
	name = "Maintenance Tar"
	description = "An unknown tar that you most likely gotten from an assistant, a bored chemist... or cooked yourself. Raw tar, straight from the floor. It can help you with escaping bad situations at the cost of liver damage."
	reagent_state = LIQUID
	color = "#000000"
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 5)

/datum/reagent/drug/maint/tar/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()

	M.AdjustStun(-10 * REM * delta_time)
	M.AdjustKnockdown(-10 * REM * delta_time)
	M.AdjustUnconscious(-10 * REM * delta_time)
	M.AdjustParalyzed(-10 * REM * delta_time)
	M.AdjustImmobilized(-10 * REM * delta_time)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM * delta_time)

/datum/reagent/drug/maint/tar/overdose_process(mob/living/M, delta_time, times_fired)
	. = ..()

	M.adjustToxLoss(5 * REM * delta_time)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 3 * REM * delta_time)

/datum/reagent/drug/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	description = "A strong hallucinogenic drug derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "mushroom"
	ph = 11
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 12)

/datum/reagent/drug/mushroomhallucinogen/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!M.slurring)
		M.slurring = 1 * REM * delta_time
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(5 * REM * delta_time)
			if(DT_PROB(5, delta_time))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(10 * REM * delta_time)
			M.Dizzy(10 * REM * delta_time)
			if(DT_PROB(10, delta_time))
				M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			M.Jitter(20 * REM * delta_time)
			M.Dizzy(20 * REM * delta_time)
			if(DT_PROB(16, delta_time))
				M.emote(pick("twitch","giggle"))
	..()

/datum/reagent/drug/mushroomhallucinogen/on_mob_add(mob/living/L)
	. = ..()
	var/atom/movable/plane_master_controller/affected_plane_controller = L.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_identity = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.000,0,0,0)
	var/list/col_filter_green = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.333,0,0,0)
	var/list/col_filter_blue = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.666,0,0,0)
	var/list/col_filter_red = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 1.000,0,0,0) //visually this is identical to the identity

	affected_plane_controller.add_filter("rainbow", 1, color_matrix_filter(col_filter_red, FILTER_COLOR_HSL))

	for(var/i in affected_plane_controller.get_filters("rainbow"))
		animate(i, color = col_filter_identity, time = 0 SECONDS, loop = -1)
		animate(color = col_filter_green, time = 4 SECONDS)
		animate(color = col_filter_blue, time = 4 SECONDS)
		animate(color = col_filter_red, time = 4 SECONDS)

/datum/reagent/drug/mushroomhallucinogen/on_mob_delete(mob/living/L)
	. = ..()
	var/atom/movable/plane_master_controller/affected_plane_controller = L.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	affected_plane_controller.remove_filter("rainbow")

/datum/reagent/drug/blastoff
	name = "bLaSToFF"
	description = "A drug for the hardcore party crowd said to enhance ones abilities on the dance floor.\nMost old heads refuse to touch this stuff, perhaps because memories of the luna discoteque incident are seared into their brains."
	reagent_state = LIQUID
	color = "#9015a9"
	ph = 5
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 15)
	///How many flips have we done so far?
	var/flip_count = 0
	///How many spin have we done so far?
	var/spin_count = 0
	///How many flips for a super flip?
	var/super_flip_requirement = 3

/datum/reagent/drug/blastoff/on_mob_metabolize(mob/living/L)
	. = ..()

	RegisterSignal(L, COMSIG_MOB_EMOTED("flip"), .proc/on_flip)
	RegisterSignal(L, COMSIG_MOB_EMOTED("spin"), .proc/on_spin)

	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_blue = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.764,0,0,0) //most blue color
	var/list/col_filter_mid = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.832,0,0,0) //red/blue mix midpoint
	var/list/col_filter_red = list(0,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.900,0,0,0) //most red color

	game_plane_master_controller.add_filter("blastoff_filter", 10, color_matrix_filter(col_filter_mid, FILTER_COLOR_HCY))

	for(var/filter in game_plane_master_controller.get_filters("blastoff_filter"))
		animate(filter, color = col_filter_blue, time = 3 SECONDS, loop = -1)
		animate(color = col_filter_mid, time = 3 SECONDS)
		animate(color = col_filter_red, time = 3 SECONDS)
		animate(color = col_filter_mid, time = 3 SECONDS)

	L.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC

/datum/reagent/drug/blastoff/on_mob_end_metabolize(mob/living/M)
	. = ..()

	UnregisterSignal(M, COMSIG_MOB_EMOTED("flip"))
	UnregisterSignal(M, COMSIG_MOB_EMOTED("spin"))

	var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter("blastoff_filter")
	M.sound_environment_override = NONE

/datum/reagent/drug/blastoff/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()

	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.4 * REM * delta_time)

	if(DT_PROB(BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT * volume, delta_time))
		M.emote("flip")

/datum/reagent/drug/blastoff/overdose_process(mob/living/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.4 * REM * delta_time)

	if(DT_PROB(BLASTOFF_DANCE_MOVE_CHANCE_PER_UNIT * volume, delta_time))
		M.emote("spin")

///This proc listens to the flip signal and throws the mob every third flip
/datum/reagent/drug/blastoff/proc/on_flip()
	SIGNAL_HANDLER

	if(!iscarbon(holder.my_atom))
		return
	var/mob/living/carbon/dancer = holder.my_atom

	flip_count++
	if(flip_count >= BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE) //Do a super flip
		flip_count = 0
		var/atom/throw_target = get_edge_target_turf(dancer, dancer.dir)
		dancer.visible_message("<span class='userdanger'>[dancer] does an extravagant flip!</span>")
		dancer.throw_at(throw_target, range = 3, speed = 1, gentle = !overdosed)

/datum/reagent/drug/blastoff/proc/on_spin()
	SIGNAL_HANDLER

	if(!iscarbon(holder.my_atom))
		return
	var/mob/living/carbon/dancer = holder.my_atom

	spin_count++
	if(spin_count >= BLASTOFF_DANCE_MOVES_PER_SUPER_MOVE) //Do a super flip
		spin_count = 0
		dancer.visible_message("<span class='userdanger'>[dancer] spins around violently!</span>")
		if(dancer.disgust < 40)
			dancer.adjust_disgust(10)
		if(!dancer.pulledby)
			return
		var/dancer_turf = get_turf(dancer)
		var/atom/movable/dance_partner = dancer.pulledby
		var/throwtarget = get_edge_target_turf(dancer_turf, get_dir(dancer_turf, get_step_away(dance_partner, dancer_turf)))
		dance_partner.throw_at(target = throwtarget, range = 2, speed = 1)

/datum/reagent/drug/saturnx
	name = "SaturnX"
	description = "This compound was first discovered during the infancy of cloaking technology and at the time thought to be a promising candidate agent. It was withdrawn for consideration after the researchers discovered a slew of associated safety issues including thought disorders and hepatoxicity."
	reagent_state = SOLID
	color = "#638b9b"
	overdose_threshold = 25
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 20)

/datum/reagent/drug/saturnx/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.6 * REM * delta_time)

/datum/reagent/drug/saturnx/on_mob_metabolize(mob/living/L)
	. = ..()
	playsound(L, 'sound/chemistry/saturnx_fade.ogg', 20)
	to_chat(L, span_nicegreen("You feel pins and needles all over your skin as your body suddenly becomes transparent!"))
	addtimer(CALLBACK(src, .proc/turn_man_invisible, L), 10) //just a quick delay to synch up the sound.

	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_full = list(1,0,0,0, 0,1.00,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_twothird = list(1,0,0,0, 0,0.68,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_half = list(1,0,0,0, 0,0.42,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/col_filter_empty = list(1,0,0,0, 0,0.11,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0) //leaves just a bit of color

	game_plane_master_controller.add_filter("saturnx_filter", 10, color_matrix_filter(col_filter_twothird, FILTER_COLOR_HCY))

	for(var/filter in game_plane_master_controller.get_filters("saturnx_filter"))
		animate(filter, loop = -1, color = col_filter_full, time = 4 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
		//uneven so we spend slightly less time with bright colors
		animate(color = col_filter_twothird, time = 2 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
		animate(color = col_filter_half, time = 9 SECONDS, easing = LINEAR_EASING)
		animate(color = col_filter_empty, time = 3 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
		animate(color = col_filter_half, time = 3 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
		animate(color = col_filter_twothird, time = 9 SECONDS, easing = LINEAR_EASING)

///This proc turns the guy who took the drug invisible by giving him the invisible man trait and updating his body, this changes the sprite of all his organic limbs to a 1 alpha version.
/datum/reagent/drug/saturnx/proc/turn_man_invisible(mob/living/carbon/invisible_man)
		ADD_TRAIT(invisible_man, TRAIT_INVISIBLE_MAN, name)
		invisible_man.update_body()
		invisible_man.remove_from_all_data_huds()
		invisible_man.sound_environment_override = SOUND_ENVIROMENT_PHASED

/datum/reagent/drug/saturnx/on_mob_end_metabolize(mob/living/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_INVISIBLE_MAN))
		M.add_to_all_human_data_huds() //Is this safe, what do you think, Floyd?
		REMOVE_TRAIT(M, TRAIT_INVISIBLE_MAN, name)
		to_chat(M, span_notice("As you sober up, opacity once again returns to your body meats."))
	M.update_body()
	M.sound_environment_override = NONE


	var/atom/movable/plane_master_controller/game_plane_master_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("saturnx_filter")

/datum/reagent/drug/saturnx/overdose_process(mob/living/M, delta_time, times_fired)
	. = ..()
	if(DT_PROB(7.5, delta_time))
		M.emote("giggle")
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.4 * REM * delta_time)

/datum/reagent/drug/kroncaine
	name = "kroncaine"
	description = "A highly illegal stimulant from the edge of the galaxy.\nIt is said the average kronkaine addict causes as much criminal damage as five stick up men, two rascals and one proferssional cambringo hustler combined."
	reagent_state = SOLID
	color = "#FAFAFA"
	ph = 8
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	addiction_types = list(/datum/addiction/stimulants = 20)

/datum/reagent/drug/kroncaine/on_mob_metabolize(mob/living/L)
	..()
	L.add_actionspeed_modifier(/datum/actionspeed_modifier/kroncaine)
	L.sound_environment_override = SOUND_ENVIRONMENT_HANGAR

/datum/reagent/drug/kroncaine/on_mob_end_metabolize(mob/living/L)
	L.remove_actionspeed_modifier(/datum/actionspeed_modifier/kroncaine)
	L.sound_environment_override = NONE
	. = ..()

/datum/reagent/drug/kroncaine/on_transfer(atom/A, methods, trans_volume)
	. = ..()
	if(!iscarbon(A))
		return
	var/mob/living/carbon/druggo = A
	druggo.adjustStaminaLoss(-4 * trans_volume, 0)
	//I wish i could give it some kind of bonus when smoked, but we don't have an INHALE method.

/datum/reagent/drug/kroncaine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.4 * REM * delta_time)
	M.Jitter(2 * REM * delta_time)
	M.AdjustSleeping(-20 * REM * delta_time)
	M.drowsyness = max(M.drowsyness - (5 * REM * delta_time), 0)
	if(volume < 10)
		return
	for(var/possible_purger as anything in M.reagents.reagent_list)
		if(istype(possible_purger, /datum/reagent/medicine/c2/multiver) || istype(possible_purger, /datum/reagent/medicine/haloperidol))
			M.ForceContractDisease(new /datum/disease/adrenal_crisis(), FALSE, TRUE) //We punish players for purging, since unchecked purging would allow players to reap the stamina healing benefits without any drawbacks. This also has the benefit of making haloperidol a counter, like it is supposed to be.
			break

/datum/reagent/drug/kroncaine/overdose_process(mob/living/M, delta_time, times_fired)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 1 * REM * delta_time)
	M.Jitter(10 * REM * delta_time)
	if(DT_PROB(10, delta_time))
		to_chat(M, span_danger(pick("You feel like your heart is going to explode!", "Your ears are ringing!", "You sweat like a pig!", "You clench your jaw and grind your teeth.", "You feel prickles of pain in your chest.")))

/*

TODO:

saturnx implementation
	make saturnx colour matrix linger longer in the desaturated region.
	add blur(angular?) filter or staic wave filter

blastoff implementation
	maybe make superflips and spin use signals so flips from other sources count?
	add animated ripple filter?

mushroom_hallucinogen implementation
	add an animated wave filter.

make sure the design doc and code aligns.

Testing
*/
