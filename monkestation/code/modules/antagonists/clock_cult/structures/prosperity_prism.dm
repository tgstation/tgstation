#define POWER_PER_USE 50

/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism
	name = "prosperity prism"
	desc = "A prism that seems to somehow always have its gaze locked to you."
	clockwork_desc = "A prism that will heal nearby servants of various damage types, along with purging poisons."
	icon_state = "prolonging_prism"
	base_icon_state = "prolonging_prism"
	anchored = TRUE
	break_message = span_warning("The prism falls apart, smoke leaking out into the air.")
	max_integrity = 150
	minimum_power = POWER_PER_USE
	passive_consumption = POWER_PER_USE / 2


/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism/process(seconds_per_tick)
	. = ..()
	if(!.)
		return

	for(var/mob/living/possible_cultist in range(3, src)) // Kyler said this is faster than spatial grid
		if(!IS_CLOCK(possible_cultist))
			continue

		if(possible_cultist.health >= possible_cultist.maxHealth)
			continue

		if(use_power(POWER_PER_USE))
			possible_cultist.adjustToxLoss(-2.5 * seconds_per_tick)
			possible_cultist.stamina.adjust(7.5 * seconds_per_tick)
			possible_cultist.adjustBruteLoss(-2.5 * seconds_per_tick)
			possible_cultist.adjustFireLoss(-2.5 * seconds_per_tick)
			possible_cultist.adjustOxyLoss(-2.5 * seconds_per_tick)
			possible_cultist.adjustCloneLoss(-1 * seconds_per_tick)

			new /obj/effect/temp_visual/heal(get_turf(possible_cultist), "#45dd8a")

			for(var/datum/reagent/toxin/toxin_chem in possible_cultist.reagents.reagent_list)
				possible_cultist.reagents.remove_reagent(toxin_chem.type, 2.5 * seconds_per_tick)

#undef POWER_PER_USE
