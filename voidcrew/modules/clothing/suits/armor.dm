/obj/item/clothing/suit/armor/vest/solgov
	name = "\improper SolGov armor vest"
	desc = "A standard armor vest fielded for SolGov's infantry."
	icon = 'voidcrew/icons/obj/clothing/suits.dmi'
	icon_state = "armor_solgov"

/obj/item/clothing/suit/armor/vest/solgov/Initialize()
	. = ..()
	//allowed |= list(/obj/item/gun/energy/laser/terra, /obj/item/gun/energy/pulse/terra, /obj/item/tank)

/obj/item/clothing/suit/armor/vest/solgov/rep
	name = "\improper SolGov Inspector armor vest"
	desc = "A type I armor vest emblazoned with the SolGov logo."
	icon_state = "armor_alt_solgov"
