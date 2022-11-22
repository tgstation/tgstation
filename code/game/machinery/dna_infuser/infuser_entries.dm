/// A list of all infuser entries
GLOBAL_LIST_INIT(infuser_entries, prepare_entries())

/proc/prepare_entries()
	var/list/entries
	for(var/datum/infuser_entry/entry_type as anything in typesof(/datum/infuser_entry))
		var/datum/infuser_entry/entry = new entry_type()
		entries += entry
	return entries

/datum/infuser_entry
	//info for the book

	/// name of the mutant you become
	var/name = "Rejected"
	/// what you have to infuse to become it
	var/infuse_mob_name = "rejected creature"
	/// general desc
	var/desc = "For whatever reason, when the body rejects DNA, the DNA goes sour, ending up as some kind of fly-like DNA jumble."
	/// desc of what passing the threshold gets you
	var/threshold_desc = "The DNA mess takes over, and you become a full-fledged flyperson."
	/// various little bits
	var/list/qualities = list(
		"buzzy-like speech",
		"vomit drinking",
		"unidentifiable organs",
		"this is a bad idea",
	)

	//info for the machine

	/// ...THINGS, mobs or items, the machine will infuse to make output organs
	var/list/input_obj_or_mob = list(
		///rejected creatures, of course, are anything not covered by other recipes. This is a special case
	)
	/// organs that the machine could spit out in relation
	var/list/output_organs = list(
		/obj/item/organ/internal/eyes/fly,
		/obj/item/organ/internal/tongue/fly,
		/obj/item/organ/internal/heart/fly,
		/obj/item/organ/internal/lungs/fly,
		/obj/item/organ/internal/stomach/fly,
		/obj/item/organ/internal/appendix/fly,
	)
	///message the target gets while being infused
	var/infusion_desc = "fly-like"

/datum/infuser_entry/rat
	name = "Rat"
	infuse_mob_name = "rodent"
	desc = "Frail, small, positively cheesed to face the world. Easy to stuff yourself full of rat DNA, but perhaps not the best choice?"
	threshold_desc = "You become lithe enough to crawl through ventilation."
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
		/obj/item/organ/internal/stomach/rat,
		/obj/item/organ/internal/heart/rat,
		/obj/item/organ/internal/tongue/rat,
	)
	infusion_desc = "skittish"

/datum/infuser_entry/carp
	name = "Carp"
	infuse_mob_name = "space-cyprinidae"
	desc = "Carp-mutants are very well-prepared for long term deep space exploration. In fact, they can't stand not doing it!"
	threshold_desc = "The DNA mess takes over, and you become a full-fledged flyperson."
	qualities = list(
		"big jaws, big teeth",
		"swim through space, no problem",
		"face every problem when you go back on station",
		"always wants to travel",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/hostile/carp,
	)
	output_organs = list(
		/obj/item/organ/internal/lungs/carp,
		/obj/item/organ/internal/tongue/carp,
		/obj/item/organ/internal/brain/carp,
		/obj/item/organ/internal/heart/carp,
	)
	infusion_desc = "nomadic"
