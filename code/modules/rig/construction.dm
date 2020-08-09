/obj/item/rig/construction
	desc = "A part used in RIG construction."

/obj/item/rig/construction/helmet
	name = "RIG helmet"
	icon_state = "rig-helmet"

/obj/item/rig/construction/chestplate
	name = "RIG chestplate"
	icon_state = "rig-chestplate"

/obj/item/rig/construction/gauntlets
	name = "RIG gauntlets"
	icon_state = "rig-gauntlets"

/obj/item/rig/construction/boots
	name = "RIG boots"
	icon_state = "rig-boots"

/obj/item/rig/construction/shell
	name = "RIG shell"
	icon_state = "rig-shell"
	desc = "An empty RIG shell."

/obj/item/rig/construction/core
	name = "RIG core"
	icon_state = "rig-core"
	desc = "A mystical crystal able to convert cell power into energy usable by RIGs."

/obj/item/rig/armor
	name = "RIG external armor"
	icon_state = "engi-armor"
	inhand_icon_state = "armor"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/theme = "engi"

/obj/item/rig/armor/Initialize()
	. = ..()
	icon_state  = "[theme]-armor"
