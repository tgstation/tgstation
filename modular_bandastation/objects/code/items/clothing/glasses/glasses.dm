// MARK: CentCom
/obj/item/clothing/glasses/hud/security/sunglasses/soo
	name = "special ops officer's HUDSunglasses"
	desc = "Продвинутый ИЛС-визор, стилизованный под солнцезащитные очки. Никто не укроется."
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS

/obj/item/clothing/glasses/hud/security/sunglasses/centcom_officer
	name = "fleet officer's HUDSunglasses"
	desc = "Продвинутый ИЛС-визор, стилизованный под солнцезащитные очки. Почти никто не укроется."
	vision_flags = SEE_MOBS

// MARK: TSF
/obj/item/clothing/glasses/hud/security/sunglasses/tsf
	name = "HUDSunglasses"
	icon_state = "sunhudmed"

/obj/item/clothing/glasses/thermal/eyepatch/tsf_commander
	clothing_traits = list(TRAIT_SECURITY_HUD)
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS

// MARK: Miscellaneous
/obj/item/clothing/glasses/meson/sunglasses
	name = "meson HUDSunglasses"
	desc = "Солнцезащитные очки со встроенным мезонным сканером, который может видеть сквозь стены и рельеф."
	icon = 'modular_bandastation/objects/icons/obj/clothing/glasses.dmi'
	icon_state = "hudsunmeson"
	inhand_icon_state = "glasses"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/eyes.dmi'
	worn_icon_state = "hudsunmeson"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/meson/sunglasses/Initialize(mapload)
	. = ..()
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/hudsunmesonremoval)

	AddElement( \
		/datum/element/slapcrafting, \
		slapcraft_recipes = slapcraft_recipe_list \
	)

/datum/crafting_recipe/hudsunmeson
	name = "Meson HUDSunglasses"
	result = /obj/item/clothing/glasses/meson/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT
	crafting_flags = CRAFT_SKIP_MATERIALS_PARITY

/datum/crafting_recipe/hudsunmesonremoval
	name = "Meson HUD Removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson/sunglasses = 1)
	category = CAT_EQUIPMENT
	crafting_flags = CRAFT_SKIP_MATERIALS_PARITY
