/datum/greyscale_config/skyraptor_uniform
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
	..()