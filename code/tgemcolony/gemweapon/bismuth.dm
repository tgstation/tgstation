/obj/item/pickaxe/bismuth
	name = "bismuth pick"

/obj/item/pickaxe/bismuth/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/bismuthpick
	name = "Shapeshift Pickaxe"
	desc = "A tool used to mine materials, or shatter gems"
	isclockcult = FALSE
	weapon_type = /obj/item/pickaxe/bismuth
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "summons"
	background_icon_state = "bg_spell"