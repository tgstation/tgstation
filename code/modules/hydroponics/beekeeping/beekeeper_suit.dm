
/obj/item/clothing/head/utility/beekeeper_head
	name = "beekeeper hat"
	desc = "Keeps the lil buzzing buggers out of your eyes."
	icon_state = "beekeeper"
	inhand_icon_state = null
	clothing_flags = THICKMATERIAL | SNUG_FIT
	pickup_sound = null
	drop_sound = null
	equip_sound = null

/obj/item/clothing/head/utility/beekeeper_head/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_HEAD, /datum/bodypart_texture/mesh/white)

/obj/item/clothing/suit/utility/beekeeper_suit
	name = "beekeeper suit"
	desc = "Keeps the lil buzzing buggers away from your squishy bits."
	icon_state = "beekeeper"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	clothing_flags = THICKMATERIAL
	allowed = list(/obj/item/melee/flyswatter, /obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/beaker, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants)
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK
	bodyshapes_with_variations = BODYSHAPE_DIGITIGRADE

/obj/item/clothing/suit/utility/beekeeper_suit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_CHEST, /datum/bodypart_texture/mesh/white)
