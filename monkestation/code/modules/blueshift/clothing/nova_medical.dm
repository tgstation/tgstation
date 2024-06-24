/obj/item/clothing/under/rank/medical
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/medical_digi.dmi'

/obj/item/clothing/under/rank/medical/doctor/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/medical.dmi'


/obj/item/clothing/under/rank/medical/scrubs/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/medical.dmi'
	icon_state = "scrubswhite" // Because for some reason TG's scrubs dont have an icon on their basetype
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one seems to be the original Scrub."
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/chemist/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/medical.dmi'

// Add a 'medical/virologist/nova' here if you make Virologist uniforms

/obj/item/clothing/under/rank/medical/paramedic/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/medical.dmi'

/obj/item/clothing/under/rank/medical/chief_medical_officer/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/medical.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/medical.dmi'

/*
*	DOCTOR
*/

/obj/item/clothing/under/rank/medical/doctor/nova/utility
	name = "medical utility uniform"
	desc = "A utility uniform worn by Medical doctors."
	icon_state = "util_med"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/doctor/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/*
*	SCRUBS
*/

/obj/item/clothing/under/rank/medical/scrubs/nova/red
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in a deep red."
	icon_state = "scrubsred"

/obj/item/clothing/under/rank/medical/scrubs/nova/white
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in a cream white colour."
	icon_state = "scrubswhite"

/*
*	CHEMIST
*/

/obj/item/clothing/under/rank/medical/chemist/nova/formal
	name = "chemist's formal jumpsuit"
	desc = "A white shirt with left-aligned buttons and an orange stripe, lined with protection against chemical spills."
	icon_state = "pharmacologist"

/obj/item/clothing/under/rank/medical/chemist/nova/formal/skirt
	name = "chemist's formal jumpskirt"
	icon_state = "pharmacologist_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/under/rank/medical/chemist/skirt


/*
*	PARAMEDIC
*/

/obj/item/clothing/under/rank/medical/paramedic/nova/light
	name = "light paramedic uniform"
	desc = "A brighter variant of the typical Paramedic uniform made with special fibers that provide minor protection against biohazards, this one has the reflective strips removed."
	icon_state = "paramedic_light"

/obj/item/clothing/under/rank/medical/paramedic/nova/light/skirt
	name = "light paramedic skirt"
	desc = "A brighter variant of the typical Paramedic uniform made with special fibers that provide minor protection against biohazards, this one has had it's legs replaced with a skirt."
	icon_state = "paramedic_light_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/*
*	CHIEF MEDICAL OFFICER
*/

/obj/item/clothing/under/rank/medical/chief_medical_officer/nova/imperial //Rank pins of the Brigadier General
	desc = "A teal, sterile naval suit with a rank badge denoting the Officer of the Medical Corps. Doesn't protect against blaster fire."
	name = "chief medical officer's naval jumpsuit"
	icon_state = "impcmo"
