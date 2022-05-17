// Sidepaths for knowledge between Flesh and Void.

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "A cloak that can become invisbile at will, hiding items you store in it. \
		To create it, transmute a glass shard, any item of clothing that you can fit over your uniform and any type of bedsheet."
	gain_text = "The Owl is the keeper of things that are not quite in practice, but in theory are. Many things are."
	next_knowledge = list(
		/datum/heretic_knowledge/limited_amount/flesh_ghoul,
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

/datum/heretic_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	desc = "Grants you Blood Siphon, a spell that drains a victim of blood and health, transferring it to you. \
		Also has a chance to transfer wounds from you to the victim."
	gain_text = "\"No matter the man, we bleed all the same.\" That's what the Marshal told me."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/void_phase,
		/datum/heretic_knowledge/summon/raw_prophet,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/blood_siphon
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Grants you Cleave, an area-of-effect targeted spell \
		that causes heavy bleeding and blood loss to anyone afflicted."
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
		told me to use them regardless. Soon, he said, I would know them well."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/stalker,
		/datum/heretic_knowledge/spell/void_pull,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 1
	route = PATH_SIDE
