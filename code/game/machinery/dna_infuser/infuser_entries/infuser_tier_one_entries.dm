/*
 * Tier one entries are unlocked at the start, and are for dna mutants that are:
 * - easy to aquire (rats)
 * - have a bonus for getting past a threshold
 * - might serve a job purpose for others (goliath) and thus should be gainable early enough
*/
/datum/infuser_entry/goliath
	name = "Goliath"
	infuse_mob_name = "goliath"
	desc = "The guy who said 'Whoever fights monsters should see to it that in the process he does not become a monster' clearly didn't see what a goliath miner can do!"
	threshold_desc = "you can walk on lava!"
	qualities = list(
		"can breath both the station and lavaland air but can't deal with pure O2",
		"immune to ashstorms",
		"eyes that can see in the dark",
		"a tendril hand can easily dig through basalt and obliterate hostile fauna, won't be fitting on gloves any time soon tho...",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/hostile/asteroid/goliath,
	)
	output_organs = list(
		/obj/item/organ/internal/brain/goliath,
		/obj/item/organ/internal/eyes/night_vision/goliath,
		/obj/item/organ/internal/heart/goliath,
		/obj/item/organ/internal/lungs/lavaland/goliath,
	)
	infusion_desc = "armored tendril-like"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/goliath

/datum/infuser_entry/carp
	name = "Carp"
	infuse_mob_name = "space-cyprinidae"
	desc = "Carp-mutants are very well-prepared for long term deep space exploration. In fact, they can't stand not doing it!"
	threshold_desc = "you learn how to propel yourself through space. Like a fish!"
	qualities = list(
		"big jaws, big teeth",
		"swim through space, no problem",
		"face every problem when you go back on station",
		"always wants to travel",
	)
	input_obj_or_mob = list(
		/mob/living/basic/carp,
	)
	output_organs = list(
		/obj/item/organ/internal/brain/carp,
		/obj/item/organ/internal/heart/carp,
		/obj/item/organ/internal/lungs/carp,
		/obj/item/organ/internal/tongue/carp,
	)
	infusion_desc = "nomadic"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/carp

/datum/infuser_entry/rat
	name = "Rat"
	infuse_mob_name = "rodent"
	desc = "Frail, small, positively cheesed to face the world. Easy to stuff yourself full of rat DNA, but perhaps not the best choice?"
	threshold_desc = "you become lithe enough to crawl through ventilation."
	qualities = list(
		"cheesy lines",
		"will eat anything",
		"wants to eat anything, constantly",
		"frail but quick",
	)
	input_obj_or_mob = list(
		/obj/item/food/deadmouse,
	)
	output_organs = list(
		/obj/item/organ/internal/eyes/night_vision/rat,
		/obj/item/organ/internal/heart/rat,
		/obj/item/organ/internal/stomach/rat,
		/obj/item/organ/internal/tongue/rat,
	)
	infusion_desc = "skittish"
	tier = DNA_MUTANT_TIER_ONE
	status_effect_type = /datum/status_effect/organ_set_bonus/rat
