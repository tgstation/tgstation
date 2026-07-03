/obj/item/clothing/mask/breath/muzzle
	can_be_adjusted = FALSE

// MARK: Misc mask
/obj/item/clothing/mask/breath/red_gas
	name = "prs-1"
	desc = "Стильная дыхательная маска в виде противогаза, не скрывает лицо."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "red_gas"

/obj/item/clothing/mask/breath/breathscarf
	name = "breathscarf system"
	desc = "Стильный и инновационный шарф, который служит дыхательной маской в экстремальных ситуациях."
	icon = 'icons/map_icons/clothing/mask.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "/obj/item/clothing/mask/breath/breathscarf"
	post_init_icon_state = "breathscarf"
	greyscale_colors = COLOR_PRISONER_BLACK
	greyscale_config = /datum/greyscale_config/breathscarf
	greyscale_config_worn = /datum/greyscale_config/breathscarf/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/datum/greyscale_config/breathscarf
	name = "Breathscarf"
	icon_file = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	json_config = 'code/datums/greyscale/json_configs/bandastation/breathscarf.json'

/datum/greyscale_config/breathscarf/worn
	name = "Breathscarf (Worn)"
	icon_file = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'

// MARK: TSF
/obj/item/clothing/mask/breath/breathscarf/tsf_infiltrator
	greyscale_colors = COLOR_OLIVE

// MARK: USSP
/obj/item/clothing/mask/balaclava/breath
	name = "breathclava"
	clothing_flags = MASKINTERNALS
	visor_flags = MASKINTERNALS
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT|HIDEEARS

// MARK: Etamin ind.
/obj/item/clothing/mask/breath/etamin_mask
	name = "Etamin Ind. mask"
	desc = "Качество, надежность и безопасность - основной залог успеха продукции от Etamin Industries."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/masks.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/masks.dmi'
	icon_state = "ei_mask"
	inhand_icon_state = "gas_atmos"
