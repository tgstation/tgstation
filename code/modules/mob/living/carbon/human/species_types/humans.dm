/datum/species/human
	name = "\improper Kitsune"
	say_mod = "geckers"
	id = SPECIES_HUMAN
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_LITERATE,
	)
	mutant_bodyparts = list("wings" = "None", "ears" = "Fox", "tail_cat" = "Fox")
	mutantears = /obj/item/organ/internal/ears/fox
	external_organs = list(
		/obj/item/organ/external/tail/fox = "Fox",
	)
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | CLOTH | BUGS | GORE
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Unkept"
	human.hair_color = "#f08e33" // brown

	var/obj/item/organ/internal/ears/fox/fox_ears = human.getorgan(/obj/item/organ/internal/ears/fox)
	if (fox_ears)
		fox_ears.color = human.hair_color
		human.update_body()

	human.update_body_parts()

/datum/species/human/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		// Force everyone to have at least fox features. I am evil and fucked up. We don't want to
		// override cat ears, so I'll do it like this. If you don't like it sue me.
		if(H.dna.features["tail_cat"] == "None")
			H.dna.features["tail_cat"] = "Fox"
		if(H.dna.features["ears"] == "None")
			H.dna.features["ears"] = "Fox"

		if(H.dna.features["ears"] == "Fox")
			var/obj/item/organ/internal/ears/fox/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else if (H.dna.features["ears"] == "Cat")
			mutantears = /obj/item/organ/internal/ears/cat
		if(H.dna.features["tail_cat"] == "Fox")
			var/obj/item/organ/external/tail/fox/tail = new
			tail.Insert(H, special = TRUE, drop_if_replaced = FALSE)
	return ..()

/datum/species/human/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.skin_tone = random_skin_tone()

/datum/species/human/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(
			'sound/voice/human/malescream_1.ogg',
			'sound/voice/human/malescream_2.ogg',
			'sound/voice/human/malescream_3.ogg',
			'sound/voice/human/malescream_4.ogg',
			'sound/voice/human/malescream_5.ogg',
			'sound/voice/human/malescream_6.ogg',
		)

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
	)

/datum/species/human/get_species_description()
	return "Kitsunes are the second most dominant species in the known galaxy. \
		Their kind extend from Meridiana XIV to the edges of known space."

/datum/species/human/get_species_lore()
	return list(
		"Kitsunes are a species of humanoid mammalians most easily identified \
		by their external features closely related to that of Vulpines from Earth. \
		Be it fluffy tails, fuzzy ears, a tendency to gecker... Most Kitsunes exhibit \
		fox-like traits and are usually distinguishable from fox-people thanks to their \
		higher number of tails."
	)


/datum/species/human/create_pref_unique_perks()
	var/list/to_add = list()

	if(CONFIG_GET(number/default_laws) == 0 || CONFIG_GET(flag/silicon_asimov_superiority_override)) // Default lawset is set to Asimov
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Asimov Superiority",
			SPECIES_PERK_DESC = "The AI and their cyborgs are, by default, subservient only \
				to humans. As a human, silicons are required to both protect and obey you.",
		))

	if(CONFIG_GET(flag/enforce_human_authority))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bullhorn",
			SPECIES_PERK_NAME = "Chain of Command",
			SPECIES_PERK_DESC = "Nanotrasen only recognizes kitsunes for command roles, such as Captain.",
		))

	return to_add
