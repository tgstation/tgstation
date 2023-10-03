// .35 Sol mini revolver

/obj/item/gun/ballistic/revolver/sol
	name = "\improper Trappiste 'Eland' Revolver"
	desc = "A small revolver with a comically short barrel and cylinder space for eight .35 Sol Short rounds."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "eland"

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c35sol

	suppressor_x_offset = 3

	w_class = WEIGHT_CLASS_SMALL

	can_suppress = TRUE

/obj/item/gun/ballistic/revolver/sol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/revolver/sol/examine_more(mob/user)
	. = ..()

	. += "The Eland is one of the few Trappiste weapons not made for military contract. \
		Instead, the Eland started life as a police weapon, offered as a gun to finally \
		outmatch all others in the cheap police weapons market. Unfortunately, this \
		coincided with nearly every SolFed police force realising they are actually \
		comically overfunded. With military weapons bought for police forces taking \
		over the market, the Eland instead found home in the civilian personal defense \
		market. That is likely the reason you are looking at this one now."

	return .

/obj/item/ammo_box/magazine/internal/cylinder/c35sol
	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 8

// .585 super revolver

/obj/item/gun/ballistic/revolver/takbok
	name = "\improper Trappiste 'Takbok' Revolver"
	desc = "A hefty revolver with an equally large cylinder capable of holding five .585 Trappiste rounds."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/trappiste_fabriek/guns32x.dmi'
	icon_state = "takbok"

	fire_sound = 'modular_skyrat/modules/modular_weapons/sounds/revolver_heavy.ogg'
	suppressed_sound = 'modular_skyrat/modules/modular_weapons/sounds/suppressed_heavy.ogg'

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c585trappiste

	suppressor_x_offset = 5

	can_suppress = TRUE

	fire_delay = 1 SECONDS
	recoil = 3

/obj/item/gun/ballistic/revolver/takbok/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_TRAPPISTE)

/obj/item/gun/ballistic/revolver/takbok/examine_more(mob/user)
	. = ..()

	. += "The Takbok is a unique design for Trappiste for the sole reason that it \
		was made at first to be a one-off. Founder of partner company Carwo Defense, \
		Darmaan Khaali Carwo herself, requested a sporting revolver from Trappiste. \
		What was delivered wasn't a target revolver, it was a target crusher. The \
		weapon became popular as Carwo crushed many shooting competitions using \
		the Takbok, with the design going on several production runs up until \
		2523 when the popularity of the gun fell off. Due to the number of revolvers \
		made, they are still easy enough to find if you look despite production \
		having already ceased many years ago."

	return .

/obj/item/ammo_box/magazine/internal/cylinder/c585trappiste
	ammo_type = /obj/item/ammo_casing/c585trappiste
	caliber = CALIBER_585TRAPPISTE
	max_ammo = 5
