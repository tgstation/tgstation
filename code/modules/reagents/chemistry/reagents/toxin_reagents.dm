
//////////////////////////Poison stuff (Toxins & Acids)///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	description = "A toxic chemical."
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "bitterness"
	taste_mult = 1.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	///The amount of toxin damage this will cause when metabolized (also used to calculate liver damage)
	var/toxpwr = 1.5
	///The amount to multiply the liver damage this toxin does by (Handled solely in liver code)
	var/liver_damage_multiplier = 1
	///The multiplier of the liver toxin tolerance, below which any amount toxin will be simply metabolized out with no effect.
	var/liver_tolerance_multiplier = 1
	///won't produce a pain message when processed by liver/life() if there isn't another non-silent toxin present if true
	var/silent_toxin = FALSE
	///The afflicted must be above this health value in order for the toxin to deal damage
	var/health_required = -100

// Are you a bad enough dude to poison your own plants?
/datum/reagent/toxin/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume * 2))

/datum/reagent/toxin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(toxpwr && affected_mob.health > health_required)
		if(affected_mob.adjust_tox_loss(toxpwr * REM * normalise_creation_purity() * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 2.5
	taste_description = "mushroom"
	ph = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/mutagen
	name = "Unstable Mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = COLOR_VIBRANT_LIME
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	toxpwr = 0
	taste_description = "slime"
	taste_mult = 0.9
	ph = 2.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/mutagen/expose_mob(mob/living/carbon/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!exposed_mob.can_mutate())
		return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.

	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.random_mutate_unique_identity()
		exposed_mob.random_mutate_unique_features()
		if(prob(98))
			exposed_mob.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
		else
			exposed_mob.easy_random_mutate(POSITIVE)
		exposed_mob.updateappearance()
		exposed_mob.domutcheck()

/datum/reagent/toxin/mutagen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjust_tox_loss(0.5 * seconds_per_tick * REM, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/toxin/mutagen/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.mutation_roll(user)
	mytray.adjust_toxic(3) //It is still toxic, mind you, but not to the same degree.

/datum/reagent/toxin/mutagen/used_on_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_MUTAGENIC, type)
	addtimer(TRAIT_CALLBACK_REMOVE(fish, TRAIT_FISH_MUTAGENIC, type), fish.feeding_frequency * 0.8, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

#define LIQUID_PLASMA_BP (50+T0C)
#define LIQUID_PLASMA_IG (325+T0C)

/datum/reagent/toxin/plasma
	name = "Plasma"
	description = "Plasma in its liquid form."
	taste_description = "bitterness"
	specific_heat = SPECIFIC_HEAT_PLASMA
	taste_mult = 1.5
	color = "#8228A0"
	toxpwr = 3
	material = /datum/material/plasma
	penetrates_skin = NONE
	ph = 4
	burning_temperature = 4500//plasma is hot!!
	burning_volume = 0.3//But burns fast
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/plasma/on_new(data)
	. = ..()
	RegisterSignal(holder, COMSIG_REAGENTS_TEMP_CHANGE, PROC_REF(on_temp_change))

/datum/reagent/toxin/plasma/Destroy()
	UnregisterSignal(holder, COMSIG_REAGENTS_TEMP_CHANGE)
	return ..()

/datum/reagent/toxin/plasma/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(holder.has_reagent(/datum/reagent/medicine/epinephrine))
		holder.remove_reagent(/datum/reagent/medicine/epinephrine, 2 * REM * seconds_per_tick)
	affected_mob.adjustPlasma(20 * REM * seconds_per_tick)

/datum/reagent/toxin/plasma/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_PLASMA_LOVER_METABOLISM)) // sometimes mobs can temporarily metabolize plasma (e.g. plasma fixation disease symptom)
		toxpwr = 0

/datum/reagent/toxin/plasma/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	toxpwr = initial(toxpwr)

/// Handles plasma boiling.
/datum/reagent/toxin/plasma/proc/on_temp_change(datum/reagents/_holder, old_temp)
	SIGNAL_HANDLER
	if(holder.chem_temp < LIQUID_PLASMA_BP)
		return
	if(!holder.my_atom)
		return
	if((holder.flags & SEALED_CONTAINER) && (holder.chem_temp < LIQUID_PLASMA_IG))
		return
	var/atom/A = holder.my_atom
	A.atmos_spawn_air("[GAS_PLASMA]=[volume];[TURF_TEMPERATURE(holder.chem_temp)]")
	holder.del_reagent(type)

/datum/reagent/toxin/plasma/expose_turf(turf/open/exposed_turf, reac_volume)
	if(!istype(exposed_turf))
		return
	var/temp = holder ? holder.chem_temp : T20C
	if(temp >= LIQUID_PLASMA_BP)
		exposed_turf.atmos_spawn_air("[GAS_PLASMA]=[reac_volume];[TURF_TEMPERATURE(temp)]")
	return ..()

#undef LIQUID_PLASMA_BP
#undef LIQUID_PLASMA_IG

/datum/reagent/toxin/plasma/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with plasma is stronger than fuel!
	. = ..()
	if(methods & (TOUCH|VAPOR))
		exposed_mob.adjust_fire_stacks(reac_volume / 5)
		return

/datum/reagent/toxin/hot_ice
	name = "Hot Ice Slush"
	description = "Frozen plasma, worth its weight in gold, to the right people."
	color = "#724cb8" // rgb: 114, 76, 184
	taste_description = "thick and smokey"
	specific_heat = SPECIFIC_HEAT_PLASMA
	toxpwr = 3
	material = /datum/material/hot_ice
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/hot_ice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(holder.has_reagent(/datum/reagent/medicine/epinephrine))
		holder.remove_reagent(/datum/reagent/medicine/epinephrine, 2 * REM * seconds_per_tick)
	affected_mob.adjustPlasma(20 * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-7 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, affected_mob.get_body_temp_normal())
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/humi = affected_mob
		humi.adjust_coretemperature(-7 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/toxin/hot_ice/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_PLASMA_LOVER_METABOLISM))
		toxpwr = 0

/datum/reagent/toxin/hot_ice/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	toxpwr = initial(toxpwr)

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	description = "A powerful poison used to stop respiration."
	color = "#7DC3A0"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	toxpwr = 0
	taste_description = "acid"
	ph = 1.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/lexorin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_NOBREATH))
		affected_mob.adjust_oxy_loss(5 * REM * normalise_creation_purity() * seconds_per_tick, FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		affected_mob.losebreath += 2 * REM * normalise_creation_purity() * seconds_per_tick
		. = UPDATE_MOB_HEALTH
		if(SPT_PROB(10, seconds_per_tick))
			affected_mob.emote("gasp")

/datum/reagent/toxin/lexorin/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	RegisterSignal(affected_mob, COMSIG_CARBON_ATTEMPT_BREATHE, PROC_REF(block_breath))

/datum/reagent/toxin/lexorin/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	UnregisterSignal(affected_mob, COMSIG_CARBON_ATTEMPT_BREATHE, PROC_REF(block_breath))

/datum/reagent/toxin/lexorin/proc/block_breath(mob/living/source)
	SIGNAL_HANDLER
	return COMSIG_CARBON_BLOCK_BREATH

/datum/reagent/toxin/slimejelly
	name = "Slime Jelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	color = "#a6959d"
	toxpwr = 0
	taste_description = "slime"
	taste_mult = 1.3
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/slimejelly/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(5, seconds_per_tick))
		to_chat(affected_mob, span_danger("Your insides are burning!"))
		if(metabolic_health_adjust(affected_mob, rand(20, 60), TOX))
			return UPDATE_MOB_HEALTH
	else if(SPT_PROB(23, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(5))
			return UPDATE_MOB_HEALTH

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	silent_toxin = TRUE
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 1
	taste_description = "fish"
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/carpotoxin/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if (HAS_TRAIT(affected_mob, TRAIT_CARPOTOXIN_IMMUNE))
		toxpwr = 0

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	description = "A strong neurotoxin that puts the patient into a death-like state."
	silent_toxin = TRUE
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5
	taste_description = "death"
	penetrates_skin = NONE
	ph = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/zombiepowder/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if(!isliving(exposed_mob) || !(methods & (INGEST|INHALE)))
		return

	LAZYINITLIST(data)
	data["method"] |= methods

	//the stomach handles INGEST via on_mob_metabolize() we only deal with INHALE
	//also means vapour works much faster which is realistic
	if(methods & INHALE)
		zombify(exposed_mob)
/**
 * Does the fake death & oxy loss on the mob
 *
 * Arguments
 * * mob/living/holder_mob - the mob we are zombifying
*/
/datum/reagent/toxin/zombiepowder/proc/zombify(mob/living/holder_mob)
	PRIVATE_PROC(TRUE)

	holder_mob.adjust_oxy_loss(0.5*REM, FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if((data?["method"] & (INGEST|INHALE)) && holder_mob.stat != DEAD)
		holder_mob.apply_status_effect(/datum/status_effect/reagent_effect/fakedeath, type)

/datum/reagent/toxin/zombiepowder/on_mob_metabolize(mob/living/holder_mob)
	. = ..()
	zombify(holder_mob)

/datum/reagent/toxin/zombiepowder/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/reagent_effect/fakedeath)

/datum/reagent/toxin/zombiepowder/on_mob_life(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_FAKEDEATH) && HAS_TRAIT(affected_mob, TRAIT_DEATHCOMA))
		return
	var/need_mob_update
	switch(current_cycle)
		if(2 to 6)
			affected_mob.adjust_confusion(1 SECONDS * REM * seconds_per_tick)
			affected_mob.adjust_drowsiness(2 SECONDS * REM * seconds_per_tick)
			affected_mob.adjust_slurring(6 SECONDS * REM * seconds_per_tick)
		if(6 to 9)
			need_mob_update = affected_mob.adjust_stamina_loss(40 * REM * seconds_per_tick, updating_stamina = FALSE)
		if(10 to INFINITY)
			if(affected_mob.stat != DEAD)
				affected_mob.fakedeath(type)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/toxin/ghoulpowder
	name = "Ghoul Powder"
	description = "A strong neurotoxin that slows metabolism to a death-like state, while keeping the patient fully active. Causes toxin buildup if used too long."
	color = "#664700" // rgb: 102, 71, 0
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	toxpwr = 0.8
	taste_description = "death"
	ph = 14.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_FAKEDEATH)

/datum/reagent/toxin/ghoulpowder/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(metabolic_health_adjust(affected_mob, 1 * REM * seconds_per_tick, OXY))
		return UPDATE_MOB_HEALTH

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	description = "A powerful hallucinogen, not to be messed with. However, for some mental patients it instead counteracts their symptoms and anchors them to reality."
	color = "#B31008" // rgb: 139, 166, 233
	toxpwr = 0
	taste_description = "sourness"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	ph = 11
	inverse_chem = /datum/reagent/impurity/rosenol
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 18)  //7.2 per 2 seconds
	metabolized_traits = list(TRAIT_RDS_SUPPRESSED)

/datum/reagent/toxin/mindbreaker/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	// mindbreaker toxin assuages hallucinations in those plagued with it, mentally
	if(affected_mob.has_trauma_type(/datum/brain_trauma/mild/hallucinations))
		affected_mob.remove_status_effect(/datum/status_effect/hallucination)

	// otherwise it creates hallucinations. truly a miracle medicine.
	else
		affected_mob.adjust_hallucinations(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/toxin/mindbreaker/fish
	name = "Jellyfish Hallucinogen"
	description = "A hallucinogen structurally similar to the mindbreaker toxin, but with weaker molecular bonds, making it easily degradeable by heat."

/datum/reagent/toxin/mindbreaker/fish/on_new(data)
	. = ..()
	if(holder?.my_atom)
		RegisterSignals(holder.my_atom, list(COMSIG_ITEM_FRIED, COMSIG_ITEM_BARBEQUE_GRILLED), PROC_REF(on_atom_cooked))

/datum/reagent/toxin/mindbreaker/fish/proc/on_atom_cooked(datum/source, cooking_time)
	SIGNAL_HANDLER
	holder.del_reagent(type)

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1
	taste_mult = 1
	penetrates_skin = NONE
	ph = 2.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Plant-B-Gone is just as bad
/datum/reagent/toxin/plantbgone/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 10))
	mytray.adjust_toxic(round(volume * 6))
	mytray.adjust_weedlevel(-rand(4,8))

/datum/reagent/toxin/plantbgone/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(istype(exposed_obj, /obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/alien_weeds = exposed_obj
		alien_weeds.take_damage(rand(15, 35), BRUTE, 0) // Kills alien weeds pretty fast
	if(istype(exposed_obj, /obj/structure/alien/resin/flower_bud))
		var/obj/structure/alien/resin/flower_bud/flower = exposed_obj
		flower.take_damage(rand(30, 50), BRUTE, 0)
	else if(istype(exposed_obj, /obj/structure/glowshroom)) //even a small amount is enough to kill it
		qdel(exposed_obj)
	else if(istype(exposed_obj, /obj/structure/spacevine))
		var/obj/structure/spacevine/SV = exposed_obj
		SV.on_chem_effect(src)

/datum/reagent/toxin/plantbgone/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume)
	. = ..()
	var/damage = min(round(0.4 * reac_volume, 0.1), 10)
	if(exposed_mob.mob_biotypes & MOB_PLANT)
		// spray bottle emits 5u so it's dealing ~15 dmg per spray
		if(metabolic_health_adjust(exposed_mob, damage * 20, TOX))
			return

	if(!(methods & VAPOR) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	if(!exposed_carbon.wear_mask)
		metabolic_health_adjust(exposed_carbon, damage, TOX)

/datum/reagent/toxin/plantbgone/weedkiller
	name = "Weed Killer"
	description = "A harmful toxic mixture to kill weeds. Do not ingest!"
	color = "#4B004B" // rgb: 75, 0, 75
	ph = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//Weed Spray
/datum/reagent/toxin/plantbgone/weedkiller/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume * 0.5))
	mytray.adjust_weedlevel(-rand(1,2))

/datum/reagent/toxin/pestkiller
	name = "Pest Killer"
	description = "A harmful toxic mixture to kill pests. Do not ingest!"
	color = "#4B004B" // rgb: 75, 0, 75
	toxpwr = 1
	ph = 3.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/pestkiller/on_new(data)
	. = ..()
	AddElement(/datum/element/bugkiller_reagent)

/datum/reagent/toxin/pestkiller/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(metabolic_health_adjust(affected_mob, 2 * toxpwr * REM * seconds_per_tick, TOX))
		return UPDATE_MOB_HEALTH

//Pest Spray
/datum/reagent/toxin/pestkiller/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume))
	mytray.adjust_pestlevel(-rand(1,2))

/datum/reagent/toxin/pestkiller/organic
	name = "Natural Pest Killer"
	description = "An organic mixture used to kill pests, with less of the side effects. Do not ingest!"
	color = "#4b2400" // rgb: 75, 0, 75
	toxpwr = 1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//Pest Spray
/datum/reagent/toxin/pestkiller/organic/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume * 0.1))
	mytray.adjust_pestlevel(-rand(1,2))

/datum/reagent/toxin/spore
	name = "Spore Toxin"
	description = "A natural toxin produced by blob spores that inhibits vision when ingested."
	color = "#9ACD32"
	toxpwr = 1
	ph = 11
	liver_damage_multiplier = 0.7
	taste_description = "spores"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/toxin/spore/expose_mob(mob/living/spore_lung_victim, methods, reac_volume, show_message, touch_protection)
	. = ..()

	if(!(methods & INHALE))
		return
	if(!(spore_lung_victim.mob_biotypes & (MOB_HUMANOID | MOB_BEAST)))
		return

	if(prob(min(reac_volume * 10, 80)))
		to_chat(spore_lung_victim, span_danger("[pick("You have a coughing fit!", "You hack and cough!", "Your lungs burn!")]"))
		spore_lung_victim.Stun(1 SECONDS)
		spore_lung_victim.emote("cough")

/datum/reagent/toxin/spore/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.damageoverlaytemp = 60
	affected_mob.update_damage_hud()
	affected_mob.set_eye_blur_if_lower(6 SECONDS * REM * seconds_per_tick)

/datum/reagent/toxin/spore_burning
	name = "Burning Spore Toxin"
	description = "A natural toxin produced by blob spores that induces combustion in its victim."
	color = "#9ACD32"
	toxpwr = 0.5
	taste_description = "burning"
	ph = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/toxin/spore_burning/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_fire_stacks(2 * REM * seconds_per_tick)
	affected_mob.ignite_mob()

/datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	description = "A powerful sedative that induces confusion and drowsiness before putting its target to sleep."
	silent_toxin = TRUE
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	ph = 11
	inverse_chem = /datum/reagent/impurity/chloralax
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/chloralhydrate/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	switch(current_cycle)
		if(2 to 11)
			affected_mob.adjust_confusion(2 SECONDS * REM * normalise_creation_purity() * seconds_per_tick)
			affected_mob.adjust_drowsiness(4 SECONDS * REM * normalise_creation_purity() * seconds_per_tick)
		if(11 to 51)
			affected_mob.Sleeping(40 * REM * normalise_creation_purity() * seconds_per_tick)
		if(52 to INFINITY)
			affected_mob.Sleeping(40 * REM * normalise_creation_purity() * seconds_per_tick)
			if(affected_mob.adjust_tox_loss(1 * (current_cycle - 51) * REM * normalise_creation_purity() * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
				return UPDATE_MOB_HEALTH

/datum/reagent/toxin/fakebeer //disguised as normal beer for use by emagged brobots
	name = "B33r"
	description = "A specially-engineered sedative disguised as beer. It induces instant sleep in its target."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "piss water"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/glass_style/drinking_glass/fakebeer
	required_drink_type = /datum/reagent/toxin/fakebeer

/datum/glass_style/drinking_glass/fakebeer/New()
	. = ..()
	// Copy styles from the beer drinking glass datum
	var/datum/glass_style/copy_from = /datum/glass_style/drinking_glass/beer
	name = initial(copy_from.name)
	desc = initial(copy_from.desc)
	icon = initial(copy_from.icon)
	icon_state = initial(copy_from.icon_state)

/datum/reagent/toxin/fakebeer/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	switch(current_cycle)
		if(2 to 51)
			affected_mob.Sleeping(40 * REM * seconds_per_tick)
		if(52 to INFINITY)
			affected_mob.Sleeping(40 * REM * seconds_per_tick)
			if(affected_mob.adjust_tox_loss(1 * (current_cycle - 50) * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
				return UPDATE_MOB_HEALTH

/datum/reagent/toxin/coffeepowder
	name = "Coffee Grounds"
	description = "Finely ground coffee beans, used to make coffee."
	color = "#5B2E0D" // rgb: 91, 46, 13
	toxpwr = 0.5
	ph = 4.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/toxin/teapowder
	name = "Ground Tea Leaves"
	description = "Finely shredded tea leaves, used for making tea."
	color = "#7F8400" // rgb: 127, 132, 0
	toxpwr = 0.1
	taste_description = "green tea"
	ph = 4.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/toxin/mushroom_powder
	name = "Mushroom Powder"
	description = "Finely ground polypore mushrooms, ready to be steeped in water to make mushroom tea."
	color = "#67423A" // rgb: 127, 132, 0
	toxpwr = 0.1
	taste_description = "mushrooms"
	ph = 8.0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/mutetoxin //the new zombie powder.
	name = "Mute Toxin"
	description = "A nonlethal poison that inhibits speech in its victim."
	silent_toxin = TRUE
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	color = "#F0F8FF" // rgb: 240, 248, 255
	toxpwr = 0
	taste_description = "silence"
	ph = 12.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/mutetoxin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	// Gain approximately 12 seconds * creation purity seconds of silence every metabolism tick.
	affected_mob.set_silence_if_lower(6 SECONDS * REM * normalise_creation_purity() * seconds_per_tick)

/datum/reagent/toxin/staminatoxin
	name = "Tirizene"
	description = "A nonlethal poison that causes extreme fatigue and weakness in its victim."
	silent_toxin = TRUE
	color = "#6E2828"
	data = 15
	toxpwr = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/staminatoxin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(metabolic_health_adjust(affected_mob, data * REM * seconds_per_tick, STAMINA))
		. = UPDATE_MOB_HEALTH
	data = max(data - 1, 3)

/datum/reagent/toxin/polonium
	name = "Polonium"
	description = "An extremely radioactive material in liquid form. Ingestion results in fatal irradiation."
	color = "#787878"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	/// How radioactive is this reagent
	var/rad_power = 3

/datum/reagent/toxin/polonium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_IRRADIATED) && SSradiation.can_irradiate_basic(affected_mob))
		var/chance = min(volume / (20 - rad_power * 5), rad_power)
		if(SPT_PROB(chance, seconds_per_tick)) // ignore rad protection calculations bc it's inside of us
			affected_mob.AddComponent(/datum/component/irradiated)
	else
		if(affected_mob.adjust_tox_loss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/toxin/polonium/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()

	if(!SSradiation.can_irradiate_basic(exposed_obj))
		return

	radiation_pulse(
		source = exposed_obj,
		max_range = 0,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (min(reac_volume * rad_power, CALCULATE_RAD_MAX_CHANCE(rad_power))),
	)

/datum/reagent/toxin/polonium/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()

	if(!SSradiation.can_irradiate_basic(exposed_mob))
		return

	if(ishuman(exposed_mob) && SSradiation.wearing_rad_protected_clothing(exposed_mob))
		return

	if(!(methods & (TOUCH|VAPOR)))
		return

	radiation_pulse(
		source = exposed_mob,
		max_range = 0,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (min(reac_volume * rad_power, CALCULATE_RAD_MAX_CHANCE(rad_power))),
	)

/datum/reagent/toxin/histamine
	name = "Histamine"
	description = "Histamine's effects become more dangerous depending on the dosage amount. They range from mildly annoying to incredibly lethal."
	silent_toxin = TRUE
	color = "#FA6464"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	toxpwr = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/toxin/histamine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(30, seconds_per_tick))
		switch(pick(1, 2, 3, 4))
			if(1)
				to_chat(affected_mob, span_danger("You can barely see!"))
				affected_mob.set_eye_blur_if_lower(6 SECONDS)
			if(2)
				affected_mob.emote("cough")
			if(3)
				affected_mob.emote("sneeze")
			if(4)
				if(prob(75))
					to_chat(affected_mob, span_danger("You scratch at an itch."))
					if(metabolic_health_adjust(affected_mob, 2* REM * seconds_per_tick, BRUTE))
						return UPDATE_MOB_HEALTH

/datum/reagent/toxin/histamine/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjust_oxy_loss(2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += affected_mob.adjust_brute_loss(2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjust_tox_loss(2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/toxin/formaldehyde
	name = "Formaldehyde"
	description = "A fairly weak toxin that helps prevent organ decay in dead bodies. \
		It will slowly decay into Histamine over time."
	silent_toxin = TRUE
	color = "#B4004B"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	toxpwr = 1
	ph = 2.0
	inverse_chem = /datum/reagent/impurity/methanol
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/formaldehyde/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_CORONER_METABOLISM)) //mmmm, the forbidden pickle juice
		if(affected_mob.adjust_tox_loss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)) //it counteracts its own toxin damage.
			return UPDATE_MOB_HEALTH
		return
	else if(SPT_PROB(2.5, seconds_per_tick) && !HAS_TRAIT(affected_mob, TRAIT_BLOCK_FORMALDEHYDE_METABOLISM))
		holder.add_reagent(/datum/reagent/toxin/histamine, pick(5,15))
		holder.remove_reagent(/datum/reagent/toxin/formaldehyde, 1.2)
	return ..()

/datum/reagent/toxin/formaldehyde/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(HAS_TRAIT(affected_mob, TRAIT_BLOCK_FORMALDEHYDE_METABOLISM))
		return

	return ..()

/datum/reagent/toxin/venom
	name = "Venom"
	description = "An exotic poison extracted from highly toxic fauna. Causes scaling amounts of toxin damage and bruising depending and dosage. Often decays into Histamine."
	color = "#F0FFF0"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	///Mob Size of the current mob sprite.
	var/current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/toxin/venom/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/newsize = 1.1 * RESIZE_DEFAULT_SIZE
	affected_mob.update_transform(newsize/current_size)
	current_size = newsize
	toxpwr = 0.1 * volume

	if(affected_mob.adjust_brute_loss((0.3 * volume) * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype))
		. = UPDATE_MOB_HEALTH

	// chance to either decay into histamine or go the normal route of toxin metabolization
	if(SPT_PROB(8, seconds_per_tick))
		holder.add_reagent(/datum/reagent/toxin/histamine, pick(5, 10))
		holder.remove_reagent(/datum/reagent/toxin/venom, 1.1)
	else
		return ..() || .

/datum/reagent/toxin/venom/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.update_transform(RESIZE_DEFAULT_SIZE/current_size)
	current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/toxin/fentanyl
	name = "Fentanyl"
	description = "Inhibits brain function and causes toxin damage before eventually knocking out the patient."
	color = "#64916E"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	toxpwr = 0
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 25)

/datum/reagent/toxin/fentanyl/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjust_organ_loss(ORGAN_SLOT_BRAIN, 3 * REM * normalise_creation_purity() * seconds_per_tick, 150)
	if(affected_mob.toxloss <= 60)
		need_mob_update += affected_mob.adjust_tox_loss(1 * REM * normalise_creation_purity() * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(current_cycle > 4)
		affected_mob.add_mood_event("smacked out", /datum/mood_event/narcotic_heavy, name)
	if(current_cycle > 18)
		affected_mob.Sleeping(40 * REM * normalise_creation_purity() * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/toxin/cyanide
	name = "Cyanide"
	description = "An infamous poison known for its use in assassination. Causes small amounts of toxin damage with a small chance of oxygen damage or a stun."
	color = "#00B4FF"
	creation_purity = REAGENT_STANDARD_PURITY
	purity = REAGENT_STANDARD_PURITY
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 1.25
	ph = 9.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/cyanide/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update = FALSE
	if(SPT_PROB(2.5, seconds_per_tick))
		affected_mob.losebreath += 1
		need_mob_update = TRUE
	if(SPT_PROB(4, seconds_per_tick))
		to_chat(affected_mob, span_danger("You feel horrendously weak!"))
		affected_mob.Stun(40)
		need_mob_update += metabolic_health_adjust(affected_mob, 2*REM * normalise_creation_purity(), TOX)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/toxin/bad_food
	name = "Bad Food"
	description = "The result of some abomination of cookery, food so bad it's toxic."
	color = "#d6d6d8"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0.5
	taste_description = "bad cooking"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/itching_powder
	name = "Itching Powder"
	description = "A powder that induces itching upon contact with the skin. Causes the victim to scratch at their itches and has a very low chance to decay into Histamine."
	sil