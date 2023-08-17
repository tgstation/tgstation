//not technically a mob but ehh, close enough
/datum/species/golem/clockwork
	name = "Clockwork Golem"
	id = SPECIES_GOLEM_CLOCKWORK
	meat = /obj/item/stack/sheet/bronze
	fixed_mut_color = rgb(190, 135, 0)
	info_text = "As a <span class='bigbrass'>Clockwork Golem</span>, most sriptures will take less time for you to invoke. You are also faster then most golems."
	prefix = "Clockwork"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	armor = 70
	speedmod = 0.2
	///ref to our turf_healing component, used for deletion on_species_loss()
	var/datum/component/turf_healing/mob_turf_healing

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/our_mob, datum/species/old_species, pref_load)
	. = ..()
	ADD_TRAIT(our_mob, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	mob_turf_healing = our_mob.AddComponent(/datum/component/turf_healing, healing_types = list(TOX = 1, BRUTE = 1, BURN = 1), \
											healing_turfs = list(/turf/open/floor/bronze, /turf/open/indestructible/reebe_flooring))

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/human/our_mob, datum/species/new_species, pref_load)
	REMOVE_TRAIT(our_mob, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	QDEL_NULL(mob_turf_healing)
	. = ..()
