/obj/item/clothing/under/rank/medical/doctor/mossmed
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel.  This is from a world where medical was olive and green, to soothe."
	name = "mossmed jumpsuit"
	icon_state = "mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_under.dmi'

/obj/item/clothing/under/rank/medical/doctor/mossmed/skirt
	name = "mossmed jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel.  This is from a world where medical was olive and green, to soothe."
	icon_state = "mossmed_skirt"
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/medical/chief_medical_officer/mossmed
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection.  This is from a world where medical was olive and green, to soothe."
	name = "chief mossmedical officer's jumpsuit"
	icon_state = "cmo_mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_under.dmi'

/obj/item/clothing/under/rank/medical/chief_medical_officer/mossmed/skirt
	name = "chief mossmedical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection.  This is from a world where medical was olive and green, to soothe."
	icon_state = "cmo_mossmed_skirt"
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY



/// Labcoats
/obj/item/clothing/suit/toggle/labcoat/mossmed
	name = "mossmed labcoat"
	desc = "More olive than the standard model."
	icon_state = "labcoat_mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_suits.dmi'

/obj/item/clothing/suit/toggle/labcoat/cmo/mossmed
	name = "chief mossmedical officer's labcoat"
	desc = "More chartreuse than the standard model."
	icon_state = "labcoat_cmo_mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_suits.dmi'



/// Wintercoat - mossmed general
/obj/item/clothing/suit/hooded/wintercoat/medical/mossmed
	name = "mossmed winter coat"
	desc = "A soothing olive-green winter coat with dyed chartreuse cotton lining,."
	icon_state = "coatmossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_suits.dmi'
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/mossmed

/obj/item/clothing/head/hooded/winterhood/medical/mossmed
	desc = "An olive and green winter coat hood."
	icon_state = "hood_mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_head.dmi'



/// Wintercoat - mossmed CMO
/obj/item/clothing/suit/hooded/wintercoat/medical/cmo/mossmed
	name = "chief mossmedical officer's winter coat"
	desc = "A winter coat in a vibrant shade of chartreuse, with shiny golden zippers for the pockets & a giant gold cross on the back."
	icon_state = "coatcmo_mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_suits.dmi'
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo/mossmed

/obj/item/clothing/head/hooded/winterhood/medical/cmo/mossmed
	desc = "A chartreuse winter coat hood."
	icon_state = "hood_cmo_mossmed"
	icon = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/med_head.dmi'



/// Adding new content to lockers, etc
/obj/item/storage/bag/garment/chief_medical/PopulateContents()
	. = ..()
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/mossmed(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/mossmed/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/medical/cmo/mossmed(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo/mossmed(src)

/obj/machinery/vending/wardrobe/medi_wardrobe
	premium = list(/obj/item/clothing/under/rank/medical/doctor/mossmed = 4,
		/obj/item/clothing/under/rank/medical/doctor/mossmed/skirt = 4,
		/obj/item/clothing/suit/hooded/wintercoat/medical/mossmed = 4,
		/obj/item/clothing/suit/toggle/labcoat/mossmed = 4)
