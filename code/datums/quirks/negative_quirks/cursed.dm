/datum/quirk/cursed
	name = "Cursed"
	desc = "Вы прокляты невезением. Вы гораздо чаще попадаете в аварии и казусы. Беда не приходит одна."
	icon = FA_ICON_CLOUD_SHOWERS_HEAVY
	value = -8
	mob_trait = TRAIT_CURSED
	gain_text = span_danger("Вы чувствуете, что у вас сегодня будет неудачный день.")
	lose_text = span_notice("Вы чувствуете, что у вас сегодня день пойдет по плану.")
	medical_record_text = "Пациент проклят невезением."
	hardcore_value = 8

/datum/quirk/cursed/add(client/client_source)
	quirk_holder.AddComponent( \
		/datum/component/omen, \
		incidents_left = INFINITY, \
		luck_mod = 0.3, \
		damage_mod = 0.25, \
		bless_fixable = FALSE, \
		on_death = CALLBACK(src, PROC_REF(on_death)), \
	)

/datum/quirk/cursed/proc/on_death(datum/component/omen/omen)
	var/mob/living/carbon/cursed = omen.parent
	if(!iscarbon(cursed))
		cursed.gib(DROP_ALL_REMAINS)
		return

	// Don't explode if buckled to a stasis bed
	if(istype(cursed.buckled, /obj/machinery/stasis))
		return

	omen.death_explode(cursed)
	cursed.spread_bodyparts()
	cursed.spawn_gibs()
