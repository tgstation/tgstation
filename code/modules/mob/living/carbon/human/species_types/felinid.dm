//Subtype of human
/datum/species/human/felinid
	name = "Felinid"
	id = SPECIES_FELINE
	examine_limb_id = SPECIES_HUMAN
	mutantbrain = /obj/item/organ/brain/felinid
	mutanttongue = /obj/item/organ/tongue/cat
	mutantears = /obj/item/organ/ears/cat
	mutant_organs = list(
		/obj/item/organ/tail/cat = "Cat",
	)
	inherent_traits = list(
		TRAIT_CATLIKE_GRACE,
		TRAIT_HATED_BY_DOGS,
		TRAIT_USES_SKINTONES,
		TRAIT_WATER_HATER,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/felinid
	payday_modifier = 1.0
	family_heirlooms = list(/obj/item/toy/cattoy)
	/// When false, this is a felinid created by mass-purrbation
	var/original_felinid = TRUE
	/// Yummy!
	species_cookie = /obj/item/food/nugget

/datum/species/human/felinid/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		var/mob/living/carbon/human/target_human = carbon_being
		if(!pref_load) //Hah! They got forcefully purrbation'd. Force default felinid parts on them if they have no mutant parts in those areas!
			target_human.dna.features[FEATURE_TAIL] = "Cat"
			if(target_human.dna.features[FEATURE_EARS] == "None")
				target_human.dna.features[FEATURE_EARS] = "Cat"
		if(target_human.dna.features[FEATURE_EARS] == "None")
			mutantears = /obj/item/organ/ears
		else
			var/obj/item/organ/ears/cat/ears = new(FALSE, target_human.dna.features[FEATURE_EARS])
			ears.Insert(target_human, movement_flags = DELETE_IF_REPLACED)
	return ..()

/datum/species/human/felinid/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	features[FEATURE_EARS] = pick("None", "Cat")
	return features

/datum/species/human/felinid/get_laugh_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg'
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)


/datum/species/human/felinid/get_cough_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)


/datum/species/human/felinid/get_cry_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/human/felinid/get_sneeze_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/human/felinid/get_sigh_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/human/felinid/get_sniff_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/human/felinid/get_snore_sound(mob/living/carbon/human/felinid)
	if(felinid.physique == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/species/human/felinid/get_hiss_sound(mob/living/carbon/human/felinid)
	return 'sound/mobs/humanoids/felinid/felinid_hiss.ogg'

/proc/mass_purrbation()
	for(var/mob in GLOB.human_list)
		purrbation_apply(mob)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/mob in GLOB.human_list)
		purrbation_remove(mob)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/target_human, silent = FALSE)
	if(!ishuman(target_human))
		return
	if(!istype(target_human.get_organ_slot(ORGAN_SLOT_EARS), /obj/item/organ/ears/cat))
		purrbation_apply(target_human, silent = silent)
		. = TRUE
	else
		purrbation_remove(target_human, silent = silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/soon_to_be_felinid, silent = FALSE)
	if(!ishuman(soon_to_be_felinid) || isfelinid(soon_to_be_felinid))
		return
	if(ishumanbasic(soon_to_be_felinid))
		soon_to_be_felinid.set_species(/datum/species/human/felinid)
		var/datum/species/human/felinid/cat_species = soon_to_be_felinid.dna.species
		cat_species.original_felinid = FALSE
	else
		// This removes the spines if they exist
		var/obj/item/organ/spines/current_spines = soon_to_be_felinid.get_organ_slot(ORGAN_SLOT_EXTERNAL_SPINES)
		if(current_spines)
			current_spines.Remove(soon_to_be_felinid, special = TRUE)
			qdel(current_spines)

		// Without this line the tails would be invisible. This is because cat tail and ears default to None.
		// Humans get converted directly to felinids, and the key is handled in on_species_gain.
		// Now when we get mob.dna.features[feature_key], it returns None, which is why the tail is invisible.
		// stored_feature_id is only set once (the first time an organ is inserted), so this should be safe.
		var/obj/item/organ/ears/cat/kitty_ears = new
		kitty_ears.Insert(soon_to_be_felinid, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		if(should_visual_organ_apply_to(/obj/item/organ/tail/cat, soon_to_be_felinid)) //only give them a tail if they actually have sprites for it / are a compatible subspecies.
			var/obj/item/organ/tail/cat/kitty_tail = new
			kitty_tail.Insert(soon_to_be_felinid, special = TRUE, movement_flags = DELETE_IF_REPLACED)

	if(!silent)
		to_chat(soon_to_be_felinid, span_boldnotice("Something is nya~t right."))
		playsound(get_turf(soon_to_be_felinid), 'sound/effects/meow1.ogg', 50, TRUE, -1)

/proc/purrbation_remove(mob/living/carbon/human/purrbated_human, silent = FALSE)
	if(isfelinid(purrbated_human))
		var/datum/species/human/felinid/cat_species = purrbated_human.dna.species
		if(cat_species.original_felinid)
			return // Don't display the to_chat message
		purrbated_human.set_species(/datum/species/human)
	else if(ishuman(purrbated_human) && !ishumanbasic(purrbated_human))
		var/datum/species/target_species = purrbated_human.dna.species

		// From the previous check we know they're not a felinid, therefore removing cat ears and tail is safe
		var/obj/item/organ/tail/old_tail = purrbated_human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
		if(istype(old_tail, /obj/item/organ/tail/cat))
			old_tail.Remove(purrbated_human, special = TRUE)
			qdel(old_tail)
			// Locate does not work on assoc lists, so we do it by hand
			for(var/external_organ in target_species.mutant_organs)
				if(!should_visual_organ_apply_to(external_organ, purrbated_human))
					continue
				if(ispath(external_organ, /obj/item/organ/tail))
					var/obj/item/organ/tail/new_tail = new external_organ()
					new_tail.Insert(purrbated_human, special = TRUE, movement_flags = DELETE_IF_REPLACED)
				// Don't forget the spines we removed earlier
				else if(ispath(external_organ, /obj/item/organ/spines))
					var/obj/item/organ/spines/new_spines = new external_organ()
					new_spines.Insert(purrbated_human, special = TRUE, movement_flags = DELETE_IF_REPLACED)

		var/obj/item/organ/ears/old_ears = purrbated_human.get_organ_slot(ORGAN_SLOT_EARS)
		if(istype(old_ears, /obj/item/organ/ears/cat))
			var/obj/item/organ/new_ears = new target_species.mutantears()
			new_ears.Insert(purrbated_human, special = TRUE, movement_flags = DELETE_IF_REPLACED)
	if(!silent)
		to_chat(purrbated_human, span_boldnotice("You are no longer a cat."))

/datum/species/human/felinid/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.set_haircolor("#ffcccc", update = FALSE) // pink
	human_for_preview.set_hairstyle("Hime Cut", update = TRUE)

	var/obj/item/organ/ears/cat/cat_ears = human_for_preview.get_organ_by_type(/obj/item/organ/ears/cat)
	if (cat_ears)
		cat_ears.color = human_for_preview.hair_color
		human_for_preview.update_body()

/datum/species/human/felinid/get_physical_attributes()
	return "Felinids are very similar to humans in almost all respects, with their biggest differences being the ability to lick their wounds, \
		and an increased sensitivity to noise, which is often detrimental. They are also rather fond of eating oranges."

/datum/species/human/felinid/get_species_description()
	return "Felinids are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common. Meow?"

/datum/species/human/felinid/get_species_lore()
	return list(
		"Bio-engineering at its felinest, Felinids are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, Felinids are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Felinids, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felinids (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

// Felinids are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/felinid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Grooming",
			SPECIES_PERK_DESC = "Felinids can lick wounds to reduce bleeding.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "Catlike Grace",
			SPECIES_PERK_DESC = "Felinids have catlike instincts allowing them to land upright on their feet.  \
				Instead of being knocked down from falling, you only receive a short slowdown. \
				However, they do not have catlike legs, and the fall will deal additional damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Felinids are more sensitive to loud sounds, such as flashbangs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Felinids don't like getting soaked with water.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "'Fight or Flight' Defense Response",
			SPECIES_PERK_DESC = "Felinids who become mentally unstable (and deprived of food) exhibit an \
				extreme 'fight or flight' response against aggressors. They sometimes bite people. Violently.",
		),
	)
	return to_add
