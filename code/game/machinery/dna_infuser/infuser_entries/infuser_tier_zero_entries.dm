/*
 * Tier zero entries are unlocked at the start, and are for dna mutants that are:
 * - a roundstart race (felinid)
 * - something of equal power to a roundstart race (flyperson)
 * - mutants without a bonus, just bringing cosmetics (fox ears)
 * basically just meme, cosmetic, and base species entries
*/
/datum/infuser_entry/fly
	name = "Rejected"
	infuse_mob_name = "rejected creature"
	desc = "For whatever reason, when the body rejects DNA, the DNA goes sour, ending up as some kind of fly-like DNA jumble."
	threshold_desc = "the DNA mess takes over, and you become a full-fledged flyperson."
	qualities = list(
		"buzzy-like speech",
		"vomit drinking",
		"unidentifiable organs",
		"this is a bad idea",
	)
	output_organs = list(
		/obj/item/organ/internal/appendix/fly,
		/obj/item/organ/internal/eyes/fly,
		/obj/item/organ/internal/heart/fly,
		/obj/item/organ/internal/lungs/fly,
		/obj/item/organ/internal/stomach/fly,
		/obj/item/organ/internal/tongue/fly,
	)
	infusion_desc = "fly-like"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/vulpini
	name = "Fox"
	infuse_mob_name = "vulpini"
	desc = "Foxes are now quite rare because of the \"fox ears\" craze back in 2555. I mean, also because we're spacefarers who destroyed foxes' natural habitats ages ago, but that applies to most animals."
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"oh come on really",
		"you bring SHAME to all geneticists",
		"i hope it was worth it",
	)
	input_obj_or_mob = list(
		/mob/living/basic/pet/fox,
	)
	output_organs = list(
		/obj/item/organ/external/tail/cat/fox,
		/obj/item/organ/internal/ears/fox,
	)
	infusion_desc = "inexcusable"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/mothroach
	name = "Mothroach"
	infuse_mob_name = "lepi-blattidae"
	desc = "So first they mixed moth and roach DNA to make mothroaches, and now we mix mothroach DNA with humanoids to make mothmen hybrids?"
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"eyes weak to bright lights",
		"you flutter when you talk",
		"wings that can't even carry your body weight",
		"i hope it was worth it",
	)
	input_obj_or_mob = list(
		/mob/living/basic/mothroach,
	)
	output_organs = list(
		/obj/item/organ/external/antennae,
		/obj/item/organ/external/wings/moth,
		/obj/item/organ/internal/eyes/moth,
		/obj/item/organ/internal/tongue/moth,
	)
	infusion_desc = "fluffy"
	tier = DNA_MUTANT_TIER_ZERO

/datum/infuser_entry/felinid
	name = "Cat"
	infuse_mob_name = "feline"
	desc = "EVERYONE CALM DOWN! I'm not implying anything with this entry. Are we really so surprised that felinids are humans with mixed feline DNA?"
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"oh, let me guess, you're a big fan of those japanese tourist bots",
	)
	input_obj_or_mob = list(
		/mob/living/basic/pet/cat,
	)
	output_organs = list(
		/obj/item/organ/internal/ears/cat,
		/obj/item/organ/external/tail/cat,
	)
	infusion_desc = "domestic"
	tier = DNA_MUTANT_TIER_ZERO
