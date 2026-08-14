/datum/quirk/cursed
	name = "Cursed"
	desc = "You are cursed with bad luck. You are much more likely to suffer from accidents and mishaps. When it rains, it pours."
	icon = FA_ICON_CLOUD_SHOWERS_HEAVY
	value = -8
	mob_trait = TRAIT_CURSED
	gain_text = span_danger("You feel like you're going to have a bad day.")
	lose_text = span_notice("You feel like you're going to have a good day.")
	medical_record_text = "Patient is cursed with bad luck."
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
