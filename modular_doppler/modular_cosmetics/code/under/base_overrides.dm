/// ==MEDICAL BREAKER==
/obj/item/clothing/under/rank/medical
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/base/medical.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/base/medical.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(
		BODYSHAPE_HUMANOID,
		BODYSHAPE_DIGITIGRADE
		)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/base/medical.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/base/medical_digi.dmi'
		)

/obj/item/clothing/under/rank/medical/scrubs
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/base/medical.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/base/medical.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(
		BODYSHAPE_HUMANOID,
		BODYSHAPE_DIGITIGRADE
		)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/base/medical.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/base/medical_digi.dmi'
		)

/obj/item/clothing/under/rank/medical/scrubs/blue
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is a grayish blue."

/obj/item/clothing/under/rank/medical/scrubs/green
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"

/obj/item/clothing/under/rank/medical/scrubs/purple
	name = "wine-red scrubs" //              Yes, I know the above word reads purple.
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is a wine red."
	icon_state = "scrubswine"
