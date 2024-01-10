#define POWER_PER_USE 20

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
	///typecache of chem types to purge
	var/static/list/chems_to_purge

/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism/Initialize(mapload)
	. = ..()
	if(!chems_to_purge)
		chems_to_purge = typecacheof(list(/datum/reagent/toxin, /datum/reagent/water/holywater))


/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism/process(seconds_per_tick)
	. = ..()
	if(!.)
		return

	for(var/mob/living/possible_cultist in range(3, src))
		if(isnull(possible_cultist) || !IS_CLOCK(possible_cultist))
			continue

		if(possible_cultist.health >= possible_cultist.maxHealth)
			continue

		possible_cultist.adjustToxLoss(-2.5 * seconds_per_tick, forced = TRUE)
		possible_cultist.stamina.adjust(7.5 * seconds_per_tick, TRUE)
		possible_cultist.adjustBruteLoss(-2.5 * seconds_per_tick)
		possible_cultist.adjustFireLoss(-2.5 * seconds_per_tick)
		possible_cultist.adjustOxyLoss(-2.5 * seconds_per_tick)
		possible_cultist.adjustCloneLoss(-1 * seconds_per_tick)

		new /obj/effect/temp_visual/heal(get_turf(possible_cultist), "#1E8CE1")

		for(var/datum/reagent/negative_chem in possible_cultist.reagents?.reagent_list)
			if(is_type_in_typecache(negative_chem, chems_to_purge))
				possible_cultist.reagents?.remove_reagent(negative_chem.type, 2.5 * seconds_per_tick)

#undef POWER_PER_USE
