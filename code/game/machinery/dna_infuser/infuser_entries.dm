/// A list of all infuser entries
GLOBAL_LIST_INIT(infuser_entries, prepare_infuser_entries())

/// just clarifying that no threshold does some special stuff, since only meme mutants have it
#define DNA_INFUSION_NO_THRESHOLD ""

/// Global proc that sets up each [/datum/infuser_entry] sub-type as singleton instances in a list, and returns it.
/proc/prepare_infuser_entries()
	var/list/entries = list()
	// Regardless of names, we want the fly/failed mutant case to show first.
	var/prepended
	for(var/datum/infuser_entry/entry_type as anything in subtypesof(/datum/infuser_entry))
		var/datum/infuser_entry/entry = new entry_type()
		if(entry.type == /datum/infuser_entry/fly)
			prepended = entry
			continue
		entries += entry
	var/list/sorted = sort_names(entries)
	sorted.Insert(1, prepended)
	return sorted

/datum/infuser_entry
	//-- Vars for DNA Infusion Book --//
	/// name of the mutant you become
	var/name = "Mutant"
	/// what you have to infuse to become it
	var/infuse_mob_name = "some kind of mutant"
	/// general desc
	var/desc = "The ignorants call you a mutant. I prefer to think of mutants as the future of mankind! They could use a guy like you on their team."
	/// desc of what passing the threshold gets you. if this is empty, there is no threshold, so this is also really a tally of whether this is a "meme" mutant or not
	var/threshold_desc = "the DNA mess takes over, and you turn into a mutant freak!"
	/// List of personal attributes added by the mutation.
	var/list/qualities = list(
		"override this",
		"puts pineapple on pizza",
		"inspiration for birth control",
		"just a weird guy",
	)
	//-- Vars for DNA Infuser Machine --//
	/// List of objects, mobs, and/or items, the machine will infuse to make output organs.
	/// Rejected creatures, of course, are anything not covered by other recipes. This is a special case
	var/list/input_obj_or_mob
	/// List of organs that the machine could spit out in relation
	var/list/output_organs
	///message the target gets while being infused
	var/infusion_desc = "mutant-like"

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

// just some meme entries, these basically encourage killing staff pets but do not play with the organ bonus system

/datum/infuser_entry/felinid
	name = "Cat"
	infuse_mob_name = "feline"
	desc = "EVERYONE CALM DOWN! I'm not implying anything with this entry. Are we really so surprised that felinids are humans with mixed feline DNA?"
	threshold_desc = DNA_INFUSION_NO_THRESHOLD
	qualities = list(
		"oh, let me guess, you're a big fan of those japanese tourist bots",
	)
	input_obj_or_mob = list(
		/mob/living/simple_animal/pet/cat,
	)
	output_organs = list(
		/obj/item/organ/internal/ears/cat,
		/obj/item/organ/external/tail/cat,
	)
	infusion_desc = "domestic"

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
		/mob/living/simple_animal/pet/fox,
	)
	output_organs = list(
		/obj/item/organ/internal/ears/fox,
	)
	infusion_desc = "inexcusable"

/datum/infuser_entry/goliath
	name = "Goliath"
	infuse_mob_name = "Goliath"
	desc = "The guy who said 'Whoever fights monsters should see to it that in the process he does not become a monster' clearly didn't see what a goliath miner can do!"
	threshold_desc = "You can walk on lava!"
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

/datum/infuser_entry/mothroach
	name = "Mothroach"
	infuse_mob_name = "Mothroach"
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
