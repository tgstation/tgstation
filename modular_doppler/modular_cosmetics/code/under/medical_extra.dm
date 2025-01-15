/*
*	CHEMIST
*/

/obj/item/clothing/under/rank/medical/chemist/pharmacologist
	name = "pharmacologist jumpsuit"
	desc = "A white shirt with left-aligned buttons and an orange stripe, lined with protection against chemical spills."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/medical_extra.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/medical_extra.dmi'
	icon_state = "pharmacologist"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/chemist/pharmacologist/skirt
	name = "pharmacologist jumpskirt"
	icon_state = "pharmacologist_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/medical/scrubs/skirt
	name = "scrub-skirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in a grayish blue, and is a sort of skirt. Or robe. Or scrobe."
	icon_state = "scrubsblue_skirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = null

/obj/item/clothing/under/rank/medical/scrubs/skirt/green
	name = "green scrub-skirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in a neat green, and is a sort of skirt. Or robe. Or scrobe."
	icon_state = "scrubsgreen_skirt"

/obj/item/clothing/under/rank/medical/scrubs/skirt/purple
	name = "wine-red scrub-skirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is a wine red, and is a sort of skirt. Or robe. Or scrobe."
	icon_state = "scrubswine_skirt"

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt/scrubs
	name = "chief medical officer scrub-skirt"
	desc = "It's a sort of skirt, robe, or scrobe, worn by those with the experience to be \"Chief Medical Officer\"."
	icon_state = "cmo_scrubskirt"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = null
