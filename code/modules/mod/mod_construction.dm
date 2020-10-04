/obj/item/mod/construction
	desc = "A part used in MOD construction."

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	icon_state = "mod-helmet"

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	icon_state = "mod-chestplate"

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	icon_state = "mod-gauntlets"

/obj/item/mod/construction/boots
	name = "MOD boots"
	icon_state = "mod-boots"

/obj/item/mod/construction/shell
	name = "MOD shell"
	icon_state = "mod-shell"
	desc = "An empty MOD shell."

/obj/item/mod/construction/core
	name = "MOD core"
	icon_state = "mod-core"
	desc = "A mystical crystal able to convert cell power into energy usable by MODs."

/obj/item/mod/armor
	name = "MOD external armor"
	icon_state = "armor"
	inhand_icon_state = "armor"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	modhthand_file = 'icons/mob/inhands/clothing_modhthand.dmi'
	var/theme = "engineering"

/obj/item/mod/armor/Initialize()
	. = ..()
	icon_state  = "[theme]-armor"
