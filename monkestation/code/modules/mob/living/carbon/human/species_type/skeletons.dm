/datum/species/skeleton/get_scream_sound(mob/living/carbon/human/human)
	return 'monkestation/sound/voice/screams/skeleton/scream_skeleton.ogg'

/datum/species/skeleton/get_laugh_sound(mob/living/carbon/human/human)
	return 'monkestation/sound/voice/laugh/skeleton/skeleton_laugh.ogg'

/datum/species/skeleton/draconic
	// Alternate skeleton for drake blood that can process chems!
	name = "Draconic Skeleton"
	id = SPECIES_DRACONIC_SKELETON
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/skeleton
	species_traits = list(
		NOTRANSSTING,
		NO_DNA_COPY,
		NO_UNDERWEAR,
		NOHUSK,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_XENO_IMMUNE,
		TRAIT_NOBLOOD,
	)
	mutantliver = /obj/item/organ/internal/liver
