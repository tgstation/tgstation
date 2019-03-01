/obj/item/twohanded/spear/pearl
	name = "pearl spear"
	desc = "an ellegant weapon for the servants of high class gems."

/obj/item/twohanded/spear/pearl/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/pearlspear
	name = "Summon Pearl Spear"
	desc = "Master the magical properties of your gem, and preform your own dance."
	isclockcult = FALSE
	weapon_type = /obj/item/twohanded/spear/pearl
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "summons"
	background_icon_state = "bg_spell"