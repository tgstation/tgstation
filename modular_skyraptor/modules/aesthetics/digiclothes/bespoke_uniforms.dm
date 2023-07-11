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



























/// Old testing greyscale-based trek uniforms
/*/datum/greyscale_config/skyraptor_uniform
	name = "NK006 Uniform"
	icon_file = 'icons/obj/clothing/under/trek.dmi'
	json_config = 'code/datums/greyscale/json_configs/trek.json'
	//All Trek uniforms are different icon_states in the same json so we dont have seperate jsons for all the different types

/datum/greyscale_config/skyraptor_uniform/worn
	name = "Worn NK006 Uniform"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/skyraptor_trek.dmi'
	//The worn json is exactly the same, so it's easier to just inherit it (EXPERIMENTAL - SUCCESS. TODO: REMOVE ALL (duplicate-of-obj)_WORN CONFIGS)

/datum/greyscale_config/skyraptor_uniform/worn_digi
	name = "Worn Digitigrade NK006 Uniform"
	icon_file = 'modular_skyraptor/modules/aesthetics/digiclothes/icons/skyraptor_trek_digi.dmi'
	//The worn json is exactly the same, so it's easier to just inherit it (EXPERIMENTAL - SUCCESS. TODO: REMOVE ALL (duplicate-of-obj)_WORN CONFIGS)





// I was going to make hodge-podge Trek-esque uniforms out of base spess suits anyways
// MIGHT AS WELL JUST CANONICALLY GIVE EVERYONE 'FLEET LOOKING UNIFORMS INSTEAD

/obj/item/clothing/under/trek/skyraptor_cmd
	name = "command uniform"
	desc = "The standard uniform of Command crew.  Durably woven for damage resistance, and tightly fit."
	icon_state = "trek_voy"
	inhand_icon_state = "jumpsuit"
	greyscale_config = /datum/greyscale_config/skyraptor_uniform
	greyscale_config_worn = /datum/greyscale_config/skyraptor_uniform/worn
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	greyscale_colors = "#6600ff"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 50, ACID = 50, WOUND = 10)
	strip_delay = 50
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/trek/skyraptor_cmd/Initialize(mapload)
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/skyraptor_uniform/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/skyraptor_uniform/worn_digi
	create_storage(max_slots = 3, max_specific_storage = WEIGHT_CLASS_SMALL)
	..()

/obj/item/clothing/under/trek/skyraptor_sup
	name = "support uniform"
	desc = "The standard uniform of Support crew.  Fire and acid resistant weave protects against faulty engines, and cargo pockets grant that extra bit of storage."
	icon_state = "trek_voy"
	inhand_icon_state = "jumpsuit"
	greyscale_config = /datum/greyscale_config/skyraptor_uniform
	greyscale_config_worn = /datum/greyscale_config/skyraptor_uniform/worn
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	greyscale_colors = "#ff6600"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 80, ACID = 40)
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/trek/skyraptor_sup/Initialize(mapload)
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/skyraptor_uniform/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/skyraptor_uniform/worn_digi
	create_storage(max_slots = 5, max_specific_storage = WEIGHT_CLASS_NORMAL)
	..()

/obj/item/clothing/under/trek/skyraptor_spc
	name = "specialist uniform"
	desc = "The standard uniform of Specialist crew.  The weave has nylon integrated for better resistance to biological agents."
	icon_state = "trek_voy"
	inhand_icon_state = "jumpsuit"
	greyscale_config = /datum/greyscale_config/skyraptor_uniform
	greyscale_config_worn = /datum/greyscale_config/skyraptor_uniform/worn
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	greyscale_colors = "#aaff00"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 50, FIRE = 20, ACID = 30)
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/trek/skyraptor_spc/Initialize(mapload)
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/skyraptor_uniform/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/skyraptor_uniform/worn_digi
	create_storage(max_slots = 3, max_specific_storage = WEIGHT_CLASS_SMALL)
	..()

/obj/item/clothing/under/trek/skyraptor_all
	name = "off-duty uniform"
	desc = "The standard uniform of off-duty crew.  It's more durable than your skivvies, and the pockets are pretty deep."
	icon_state = "trek_voy"
	inhand_icon_state = "jumpsuit"
	greyscale_config = /datum/greyscale_config/skyraptor_uniform
	greyscale_config_worn = /datum/greyscale_config/skyraptor_uniform/worn
	supported_bodytypes = list(BODYTYPE_HUMANOID, BODYTYPE_DIGITIGRADE)
	greyscale_colors = "#ffffff"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 20, ACID = 30) //assistant clothes get the worst out of each above protection category, but still better than nothing
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/trek/skyraptor_all/Initialize(mapload)
	greyscale_config_worn_bodytypes = list()
	greyscale_config_worn_bodytypes["[BODYTYPE_HUMANOID]"] = /datum/greyscale_config/skyraptor_uniform/worn
	greyscale_config_worn_bodytypes["[BODYTYPE_DIGITIGRADE]"] = /datum/greyscale_config/skyraptor_uniform/worn_digi
	create_storage(max_slots = 3, max_specific_storage = WEIGHT_CLASS_NORMAL) //they don't get extra pockets, but they do get deeper ones, like Support crew
	..()*/
