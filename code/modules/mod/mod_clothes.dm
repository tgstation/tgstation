/obj/item/clothing/head/mod
	name = "\improper MOD helmet"
	desc = "A helmet for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-helmet"
	base_icon_state = "helmet"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD

// Even without a hat stabilizer, hats can be worn - however, they'll fall off very easily
/obj/item/clothing/head/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)
	AddComponent(/datum/component/hat_stabilizer, loose_hat = TRUE)
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_HEAD, /datum/bodypart_texture/mesh/space)

/obj/item/clothing/suit/mod
	name = "\improper MOD chestplate"
	desc = "A chestplate for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-chestplate"
	base_icon_state = "chestplate"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/flashlight,
		/obj/item/tank/jetpack/captain,
	)
	armor_type = /datum/armor/none
	body_parts_covered = CHEST|GROIN
	heat_protection = CHEST|GROIN
	cold_protection = CHEST|GROIN
	drop_sound = null

/obj/item/clothing/suit/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_CHEST, /datum/bodypart_texture/mesh/space)

/obj/item/clothing/gloves/mod
	name = "\improper MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-gauntlets"
	base_icon_state = "gauntlets"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	equip_sound = null
	pickup_sound = null
	drop_sound = null

/obj/item/clothing/gloves/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)

/obj/item/clothing/shoes/mod
	name = "\improper MOD boots"
	desc = "A pair of boots for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-boots"
	base_icon_state = "boots"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	item_flags = IGNORE_DIGITIGRADE
	fastening_type = SHOES_SLIPON
	equip_sound = null
	/// Reference to the component that manages the footstep sounds
	VAR_PRIVATE/datum/component/shoe_footstep/footstep_component

/obj/item/clothing/shoes/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)

/obj/item/clothing/shoes/mod/Destroy()
	footstep_component = null
	return ..()

/obj/item/clothing/shoes/mod/proc/update_footstep_sounds()
	QDEL_NULL(footstep_component)
	switch(slowdown)
		if(0.3 to INFINITY)
			footstep_component = AddComponent(/datum/component/shoe_footstep, list('maplestation_modules/sound/items/rigstep_chonk.ogg'), volume = 50)
		if(0.2 to 0.3)
			footstep_component = AddComponent(/datum/component/shoe_footstep, list('maplestation_modules/sound/items/rigstep_heavy.ogg'), volume = 50)
		if(0.1 to 0.2)
			footstep_component = AddComponent(/datum/component/shoe_footstep, list('maplestation_modules/sound/items/rigstep_medium.ogg'), volume = 50)
		if(-INFINITY to 0.1)
			footstep_component = AddComponent(/datum/component/shoe_footstep, list('maplestation_modules/sound/items/rigstep.ogg'), volume = 50)

/obj/item/clothing/glasses/mod
	name = "\improper MOD glasses"
	desc = "A pair of glasses for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-glasses"
	base_icon_state = "glasses"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	equip_sound = null
	pickup_sound = null
	drop_sound = null

/obj/item/clothing/glasses/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)

/obj/item/clothing/neck/mod
	name = "\improper MOD tie"
	desc = "An tie for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-tie"
	base_icon_state = "tie"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	equip_sound = null
	pickup_sound = null
	drop_sound = null

/obj/item/clothing/neck/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)
