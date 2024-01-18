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
	icon = FA_ICON_PAW
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


/datum/quirk/clown_disbelief
	name = "Clown Disbelief"
	desc = "You never really believed in clowns."
	mob_trait = TRAIT_HIDDEN_CLOWN
	value = 0
	icon = FA_ICON_HIPPO

/datum/quirk/clown_disbelief/add(client/client_source)
	. = ..()
	if(!quirk_holder)
		return
	RegisterSignal(quirk_holder, COMSIG_MOB_LOGIN, PROC_REF(enable))
	RegisterSignal(quirk_holder, COMSIG_MOB_LOGOUT, PROC_REF(disable))
	RegisterSignal(quirk_holder, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(examined))

/datum/quirk/clown_disbelief/remove()
	. = ..()
	disable()
	UnregisterSignal(quirk_holder, COMSIG_MOB_LOGOUT, COMSIG_MOB_LOGIN, COMSIG_ATOM_EXAMINE_MORE)

/datum/quirk/clown_disbelief/proc/examined(datum/source, mob/user, list/examine_list)
	if(user.mind?.assigned_role.type == /datum/job/clown)
		examine_list += "[span_warning("[quirk_holder] doesn't seem to notice you!")]\n"

/datum/quirk/clown_disbelief/proc/enable(datum/source)
	for(var/image/image as anything in GLOB.hidden_image_holders["clown"])
		quirk_holder.client.images += image

/datum/quirk/clown_disbelief/proc/disable(datum/source)
	for(var/image/image as anything in GLOB.hidden_image_holders["clown"])
		quirk_holder.client.images -= image


//DRG style callouts
//Useful mainly for Shaft Miners, but can be taken by anyone.
/datum/quirk/drg_callout
	name = "Miner Training"
	desc = "You arrive with a strange skillchip that teaches you how to reflexively call out mining-related entities you point at."
	mob_trait = TRAIT_MINING_CALLOUTS
	value = 0
	icon = FA_ICON_BULLHORN
	quirk_flags = QUIRK_HIDE_FROM_SCAN

/datum/quirk/drg_callout/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/skillchip/drg_callout/skillchip = new
	human_holder.implant_skillchip(skillchip)
	skillchip.try_activate_skillchip()
