//Anvil recipes
/datum/design/dwarven/warhammer
	name = "Dwarven warhammer"
	desc = "Warhammer fit for only the mightiest of the dwarves!"
	id = "dwarven_warhammer"
	build_type = DWARVEN_ANVIL
	materials = list(MAT_CATEGORY_RIGID = 20000)
	build_path = /obj/item/twohanded/war_hammer

/datum/design/dwarven/waraxe
	name = "Dwarven waraxe"
	desc = "War war war war war!"
	id = "dwarven_waraxe"
	build_type = DWARVEN_ANVIL
	materials = list(MAT_CATEGORY_RIGID = 10000)
	build_path = /obj/item/hatchet/dwarven/axe

/datum/design/dwarven/javelin
	name = "Dwarven javelin"
	desc = "Throw em and you know em."
	id = "dwarven_javelin"
	build_type = DWARVEN_ANVIL
	materials = list(MAT_CATEGORY_RIGID = 5000)
	build_path = /obj/item/hatchet/dwarven/javelin

/datum/design/dwarven/dwarven_platemail
	name = "Dwarven platemail"
	desc = "Nothing will pierce through that!"
	id = "dwarven_platemail"
	build_type = DWARVEN_ANVIL
	materials = list(MAT_CATEGORY_RIGID = 20000)
	build_path = /obj/item/clothing/suit/armor/vest/dwarven_platemail

/datum/design/dwarven/dwarven_chain
	name = "Dwarven chainmail"
	desc = "You can at least move in those."
	id = "dwarven_chainmail"
	build_type = DWARVEN_ANVIL
	materials = list(MAT_CATEGORY_RIGID = 10000)
	build_path = /obj/item/clothing/suit/armor/vest/dwarven_chainmail

/datum/design/dwarven/dwarven_helmet
	name = "Dwarven helmet"
	desc = "Dorf man dorf man."
	id = "dwarven_helmet"
	build_type = DWARVEN_ANVIL
	materials = list(MAT_CATEGORY_RIGID = 5000)
	build_path = /obj/item/clothing/head/helmet/dwarven_helmet

/datum/design/dwarven/iron_pickaxe
	name = "iron pickaxe"
	desc = "self explanatory."
	id = "dwarven_ironpick"
	build_type = DWARVEN_ANVIL
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/clothing/head/helmet/dwarven_helmet

/datum/design/dwarven/silver_pickaxe
	name = "Silver pickaxe"
	desc = "self explanatory."
	id = "dwarven_silverpick"
	build_type = DWARVEN_ANVIL
	materials = list(/datum/material/silver = 5000)
	build_path = /obj/item/clothing/head/helmet/dwarven_helmet

/datum/design/dwarven/diamond_pickaxe
	name = "Diamond pickaxe"
	desc = "self explanatory."
	id = "dwarven_diamondpick"
	build_type = DWARVEN_ANVIL
	materials = list(/datum/material/diamond = 5000)
	build_path = /obj/item/clothing/head/helmet/dwarven_helmet

//workshop now

/datum/design/dwarven/dwarven_workshop
	name = "Dwarven workshop"
	desc = "You can build shit in one of these."
	id = "dwarven_workshop"
	build_type = DWARVEN_WORKSHOP
	materials = list(/datum/material/wood = 20000)
	build_path = /obj/item/dwarven/blueprint/workshop

/datum/design/dwarven/dwarven_anvil
	name = "Dwarven anvil"
	desc = "You can make armor in one of these."
	id = "dwarven_anvil"
	build_type = DWARVEN_WORKSHOP
	materials = list(/datum/material/dwarven = 20000)
	build_path = /obj/item/dwarven/blueprint/anvil

/datum/design/dwarven/dwarven_press
	name = "Dwarven press"
	desc = "You can make dwarven alloy in one of these."
	id = "dwarven_press"
	build_type = DWARVEN_WORKSHOP
	materials = list(/datum/material/silver = 20000)
	build_path = /obj/item/dwarven/blueprint/press

/datum/design/dwarven/dwarven_forge
	name = "Dwarven forge"
	desc = "You can smelt in one of these."
	id = "dwarven_forge"
	build_type = DWARVEN_WORKSHOP
	materials = list(/datum/material/iron = 20000)
	build_path = /obj/item/dwarven/blueprint/forge
