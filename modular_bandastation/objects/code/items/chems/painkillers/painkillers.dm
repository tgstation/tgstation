/datum/reagent/medicine/tramadol
	name = "Tramadol"
	description = "Простой, но эффективный обезболивающий препарат. При передозировке вызывает отравление и зависимость."
	color = "#8a8686"
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	overdose_threshold = 30
	overdose_crit_threshold = 50
	ph = 7.4
	taste_description = "горечи"
	randomized_spawns = REAGENT_SPAWN_ALL_RANDOM_SPAWNS
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 20)
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/medicine/tramadol/on_mob_life(mob/living/carbon/affected_mob)
	if(volume > 20)
		affected_mob.apply_damage(1, TOX)
	return ..()

/datum/reagent/medicine/tramadol/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	affected_mob.set_drugginess(30 SECONDS * metabolization_ratio * seconds_per_tick) //Hallucinations and oxy damage
	affected_mob.apply_damage(1, OXY)

/datum/reagent/medicine/tramadol/overdose_crit_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	affected_mob.apply_damage(5, TOX)

/datum/reagent/medicine/tramadol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.add_mood_event("numb", /datum/mood_event/narcotic_medium)

/datum/reagent/medicine/tramadol/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!iscarbon(exposed_mob) || (exposed_mob.stat == DEAD))
		return

	if(!(methods & (TOUCH|VAPOR|PATCH)))
		return

	exposed_mob.add_surgery_speed_mod(type, 0.7, min(reac_volume * 1 MINUTES, 5 MINUTES))
	if(show_message)
		to_chat(exposed_mob, span_danger("Вы чувствуете, как ваши раны исчезают, превращаясь в ничто!"))

/datum/reagent/medicine/tramadol/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/tramadol/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
