// Sidepaths for knowledge between Void and Rust.

/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "Allows you to transmute a table and a gas mask to create Eldritch Armor. \
		Eldritch Armor provides great protection while also acting as a focus when hooded."
	gain_text = "The Rusted Hills welcomed the Blacksmith in their generosity. And the Blacksmith \
		returned their generosity in kind."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_regen,
		/datum/heretic_knowledge/cold_snap,
	)
	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	desc = "Allows you to transmute a portable water tank and a table to create a Mawed Crucible. \
		The Mawed Crubile can brew powerful potions for combat and utility, but must be fed bodyparts and organs between uses."
	gain_text = "This is pure agony. I wasn't able to summon the figure of the Aristocrat, \
		but with the Priest's attention I stumbled upon a different recipe..."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/void_phase,
		/datum/heretic_knowledge/spell/area_conversion,
	)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "Allows you to transmute a pool of vomit, a book, and a head into a Rust Walker. \
		Rust Walkers excel at spreading rust and are moderately strong in combat."
	gain_text = "I combined my principle of hunger with my desire for corruption. The Marshal knew my name, and the Rusted Hills echoed out."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/voidpull,
		/datum/heretic_knowledge/spell/entropic_plume,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/book = 1,
		/obj/item/bodypart/head = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/rust_spirit
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/summon/rusty/cleanup_atoms(list/selected_atoms)
	var/obj/item/bodypart/head/ritual_head = locate() in selected_atoms
	if(!ritual_head)
		CRASH("[type] required a head bodypart, yet did not have one in selected_atoms when it reached cleanup_atoms.")

	// Spill out any brains or stuff before we delete it.
	ritual_head.drop_organs()
	return ..()
