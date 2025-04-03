/datum/heretic_knowledge_tree_column/flesh_to_void
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/flesh
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/void

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/void_cloak
	tier2 = /datum/heretic_knowledge/spell/blood_siphon
	tier3 = list(/datum/heretic_knowledge/spell/void_prison, /datum/heretic_knowledge/spell/cleave)

// Sidepaths for knowledge between Flesh and Void.

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "Allows you to transmute a glass shard, a bedsheet, and any outer clothing item (such as armor or a suit jacket) \
		to create a Void Cloak. While the hood is down, the cloak functions as a focus, \
		and while the hood is up, the cloak is completely invisible. It also provide decent armor and \
		has pockets which can hold one of your blades, various ritual components (such as organs), and small heretical trinkets."
	gain_text = "The Owl is the keeper of things that are not quite in practice, but in theory are. Many things are."

	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "void_cloak"

/datum/heretic_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	desc = "Grants you Blood Siphon, a spell that drains a victim of blood and health, transferring it to you. \
		Also has a chance to transfer wounds from you to the victim."
	gain_text = "\"No matter the man, we bleed all the same.\" That's what the Marshal told me."

	action_to_add = /datum/action/cooldown/spell/pointed/blood_siphon
	cost = 1

/datum/heretic_knowledge/spell/void_prison
	name = "Void Prison"
	desc = "Grants you Void Prison, a spell that places your victim into ball, making them unable to do anything or speak. \
		Applies void chill afterwards."
	gain_text = "At first, I see myself, waltzing along a snow-laden street. \
		I try to yell, grab hold of this fool and tell them to run. \
		But the only welts made are on my own beating fist. \
		My smiling face turns to regard me, reflecting back in glassy eyes the empty path I have been lead down."

	action_to_add = /datum/action/cooldown/spell/pointed/void_prison
	cost = 1

/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Grants you Cleave, an area-of-effect targeted spell \
		that causes heavy bleeding and blood loss to anyone afflicted."
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
		told me to use them regardless. Soon, he said, I would know them well."

	action_to_add = /datum/action/cooldown/spell/pointed/cleave
	cost = 1


