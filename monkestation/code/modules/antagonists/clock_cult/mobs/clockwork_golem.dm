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
//	species_language_holder = /datum/language_holder/clockmob
	armor = 50
	speedmod = 0.5

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/our_mob, datum/species/old_species, pref_load)
	. = ..()
	ADD_TRAIT(our_mob, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/human/our_mob, datum/species/new_species, pref_load)
	REMOVE_TRAIT(our_mob, TRAIT_FASTER_SLAB_INVOKE, SPECIES_TRAIT)
	. = ..()
