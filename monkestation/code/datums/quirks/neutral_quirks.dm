/datum/quirk/gigantism
	name = "Gigantism"
	desc = "Your cells take up more space than others', giving you a larger appearance. You find it difficult to avoid looking down on others. Literally."
	value = 0
	icon = FA_ICON_CHEVRON_CIRCLE_UP
	quirk_flags = QUIRK_CHANGES_APPEARANCE

/datum/quirk/gigantism/add()
	. = ..()
	if (ishuman(quirk_holder))
		var/mob/living/carbon/human/gojira = quirk_holder
		if(gojira.dna)
			gojira.dna.add_mutation(/datum/mutation/human/gigantism)

/datum/quirk/anime
	name = "Anime"
	desc = "You are an anime enjoyer! Show your enthusiasm with some fashionable attire."
	mob_trait = TRAIT_ANIME
	value = 0
	icon = "cat"
	quirk_flags = QUIRK_CHANGES_APPEARANCE

	var/list/anime_list = list(
		/obj/item/organ/external/anime_head,
		/obj/item/organ/external/anime_middle,
		/obj/item/organ/external/anime_bottom,
		)

/datum/quirk/anime/add(client/client_source)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	RegisterSignal(human_holder, COMSIG_SPECIES_GAIN_PRE, PROC_REF(on_species_gain))

	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		//Load a persons preferences from DNA
		var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
		new_organ.Insert(human_holder, special=TRUE, drop_if_replaced=FALSE)
		species.external_organs |= organ_path

/datum/quirk/anime/remove()
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/species/species = human_holder.dna.species
	UnregisterSignal(human_holder, COMSIG_SPECIES_GAIN_PRE)

	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		species.external_organs -= organ_path

/datum/quirk/anime/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	for(var/obj/item/organ/external/organ_path as anything in anime_list)
		new_species.external_organs |= organ_path
