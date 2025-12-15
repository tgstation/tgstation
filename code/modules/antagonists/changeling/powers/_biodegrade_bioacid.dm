/datum/reagent/toxin/acid/bio_acid
	name = "adaptive bio-acid"
	description = "An immensely strong, acidic substance of seemingly biological origin. It is teeming with microscopic\
	organisms that seem to alter its composition to most adaptively dissolve whatever it comes into contact with."
	color = "#9455ff"
	creation_purity = 100
	toxpwr = 0
	acidpwr = 0
	ph = 0.0
	penetrates_skin = TOUCH

/datum/reagent/toxin/acid/bio_acid/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection)
	if(IS_CHANGELING(exposed_mob))
		to_chat(exposed_mob, span_changeling("We excrete a bio-agent to neutralize the bio-acid. It is routine and reflexive to do so."))
		volume = min(0.1, volume)
		holder.update_total()
		return
	. = ..()
	exposed_mob.adjust_fire_loss(round(reac_volume * min(1 - touch_protection), 0.1) * 3, required_bodytype = BODYTYPE_ORGANIC) // full bio protection = 100% damage reduction
	exposed_mob.acid_act(10, 50)

/datum/reagent/toxin/acid/bio_acid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(50, seconds_per_tick))
		affected_mob.emote(pick("screech", "cry"))
