// Sidepaths for knowledge between Rust and Ash.

/datum/heretic_knowledge/essence
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a flask of eldritch water. \
		Eldritch water can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "This is an old recipe. The Owl whispered it to me."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_regen,
		/datum/heretic_knowledge/spell/ashen_shift,
		)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	cost = 1

/datum/heretic_knowledge/curse/corrosion
	name = "Curse of Corrosion"
	gain_text = "Cursed land, cursed man, cursed mind."
	desc = "Curse someone for 2 minutes of vomiting and major organ damage. \
		Requires wirecutters, a pool of vomit, a heart, and an item that the victim touched with their bare hands."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/spell/area_conversion,
	)
	required_atoms = list(
		/obj/item/wirecutters = 1,
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/organ/heart = 1,
	)
	duration = 2 MINUTES
	cost = 1

/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Grants you Cleave, an AOE spell that causes heavy bleeding and blood loss."
	gain_text = "At first I didn't understand these instruments of war, but the priest \
		told me to use them regardless. Soon, he said, I would know them well."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/entropic_plume,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 1
