/*
 * Tier two entries are unlocked after infusing someone/being infused and achieving a bonus, and are for dna mutants that are:
 * - harder to acquire (gondolas) but not *necessarily* requiring job help
 * - have a bonus for getting past a threshold
 *
 * todos for the future:
 * - tier threes, requires xenobio cooperation, unlocked after getting a tier two entity bonus
 * - when completing a tier, add the bonus to an xp system for unlocking new tiers. so instead of getting/giving a tier 1 bonus and unlocking tier 2, tier 1 would add "1" to a total. when you have a total of say, 3, you get the next tier
*/
/datum/infuser_entry/gondola
	name = "Gondola"
	infuse_mob_name = "gondolid"
	desc = "Gondolas, rare creatures that choose to simply observe instead of act have quite a set of interesting qualities to take advantage of. You know. Zen, peace, happiness... shrugging off a raging plasma fire..."
	threshold_desc = "you can shrug off most environmental conditions!"
	qualities = list(
		"pacify people with your hugs",
		"enter a bliss-like state of zen",
		"become too weak to pick up anything larger than a pen",
		"stop caring about temperature... or pressure, or atmos... or much of anything...",
	)
	input_obj_or_mob = list(
		/obj/item/food/meat/slab/gondola,
	)
	output_organs = list(
		/obj/item/organ/heart/gondola,
		/obj/item/organ/tongue/gondola,
		/obj/item/organ/liver/gondola,
	)
	infusion_desc = "observant"
	tier = DNA_MUTANT_TIER_TWO
	status_effect_type = /datum/status_effect/organ_set_bonus/gondola
