// Sidepaths for knowledge between Void and Rust.

/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "You can now create Eldritch Armor using a table and a gas mask. \
		The armor both protect from damage and works as a focus, allowing you to cast spells."
	gain_text = "The Rusted Hills welcomed the Blacksmith in their generosity."
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

/datum/heretic_knowledge/crucible
	name = "Mawed Crucible"
	gain_text = "This is pure agony. I wasn't able to summon the dereliction of the emperor, but I stumbled upon a different recipe..."
	desc = "Allows you to create a mawed crucible, eldritch structure that allows you to create potions of various effects. \
		To do so, transmute a table with a portable water tank."
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

/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "You can now summon a Rust Walker by transmutating a vomit pool, a severed head and a book."
	gain_text = "I combined my principle of hunger with my desire for corruption. And the Rusted Hills called my name."
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
