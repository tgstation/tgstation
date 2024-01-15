// SolFed shotgun (this was gonna be in a proprietary shotgun shell type outside of 12ga at some point, wild right?)

/obj/item/gun/ballistic/shotgun/riot/sol
	name = "\improper Carwo 'Renoster' Shotgun"
	desc = "A twelve gauge shotgun with a six shell capacity underneath. Made for and used by SolFed's various military branches."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "renoster"

	worn_icon = 'modular_skyrat/modules/modular_weapons/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "renoster"

	lefthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "renoster"

	inhand_x_dimension = 32
	inhand_y_dimension = 32

	SET_BASE_PIXEL(-8, 0)

	fire_sound = 'modular_skyrat/modules/modular_weapons/sounds/shotgun_heavy.ogg'
	suppressed_sound = 'modular_skyrat/modules/modular_weapons/sounds/suppressed_heavy.ogg'
	can_suppress = TRUE

	suppressor_x_offset = 9

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_OCLOTHING

/obj/item/gun/ballistic/shotgun/riot/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/shotgun/riot/sol/examine_more(mob/user)
	. = ..()

	. += "The Renoster was designed at its core as a police shotgun. \
		As consequence, it holds all the qualities a police force would want \
		in one. Large shell capacity, sturdy frame, while holding enough \
		capacity for modification to satiate even the most overfunded of \
		peacekeeper forces. Inevitably, the weapon made its way into civilian \
		markets alongside its sale to several military branches that also \
		saw value in having a heavy shotgun."

	return .

/obj/item/gun/ballistic/shotgun/riot/sol/update_appearance(updates)
	if(sawn_off)
		suppressor_x_offset = 0
		SET_BASE_PIXEL(0, 0)

	. = ..()

// Shotgun but EVIL!

/obj/item/gun/ballistic/shotgun/riot/sol/evil
	desc = "A twleve guage shotgun with an eight shell capacity underneath. This one is painted in a tacticool black."

	icon_state = "renoster_evil"
	worn_icon_state = "renoster_evil"
	inhand_icon_state = "renoster_evil"
