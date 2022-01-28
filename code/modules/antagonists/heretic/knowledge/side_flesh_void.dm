// Sidepaths for knowledge between Flesh and Void.

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "A cloak that can become invisbile at will, hiding items you store in it. \
		To create it, transmute a glass shard, any item of clothing that you can fit over your uniform and any type of bedsheet."
	gain_text = "Owl is the keeper of things that quite not are in practice, but in theory are."
	next_knowledge = list(
		/datum/heretic_knowledge/flesh_ghoul,
		/datum/heretic_knowledge/cold_snap,
	)
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	gain_text = "Etched, carved... eternal. I can carve the monolith and evoke their powers!"
	desc = "You can create a carving knife, which allows you to create up to 3 carvings on the floor \
		that have various effects on nonbelievers who walk over them. Also makes quite a handy throwing weapon. \
		To create the carving knife, transmute a knife with a glass shard and a piece of paper."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/void_phase,
		/datum/heretic_knowledge/summon/raw_prophet,
	)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	desc = "You gain a spell that drains health from your enemies to restores your own."
	gain_text = "No matter the man, we bleed all the same. That's what the Marshal told me."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/stalker,
		/datum/heretic_knowledge/spell/voidpull,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/blood_siphon
	cost = 1
	route = PATH_SIDE
