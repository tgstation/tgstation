/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/shadow
	species_traits = list(NOBLOOD,NOEYESPRITES)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER,TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NOBREATH)
	inherent_factions = list("faithless")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	mutanteyes = /obj/item/organ/eyes/night_vision
	species_language_holder = /datum/language_holder/shadowpeople


/datum/species/shadow/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()

		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
			H.take_overall_damage(0.5 * delta_time, 0.5 * delta_time, 0, BODYPART_ORGANIC)
		else if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
			H.heal_overall_damage(0.5 * delta_time, 0.5 * delta_time, 0, BODYPART_ORGANIC)

/datum/species/shadow/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()
