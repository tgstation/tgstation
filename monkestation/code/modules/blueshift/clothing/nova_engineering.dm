/obj/item/clothing/under/rank/engineering
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/engineering_digi.dmi'

/obj/item/clothing/under/rank/engineering/engineer/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/engineering.dmi'

/obj/item/clothing/under/rank/engineering/chief_engineer/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/engineering.dmi'

/obj/item/clothing/under/rank/engineering/atmospheric_technician/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/engineering.dmi'

/*
*	ENGINEER
*/

/obj/item/clothing/under/rank/engineering/engineer/nova/utility
	name = "engineering utility uniform"
	desc = "A utility uniform worn by Engineering personnel."
	icon_state = "util_eng"
	can_adjust = FALSE

/obj/item/clothing/under/rank/engineering/engineer/nova/utility/syndicate
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/engineering/engineer/nova/trouser
	name = "engineering trousers"
	desc = "An engineering-orange set of trousers. Their waistband proudly displays an 'anti-radiation' symbol, though the effectiveness of radiation-proof-pants-only is still up for debate."
	icon_state = "workpants_orange"
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS

/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem
	name = "chemical hazard jumpsuit"
	desc = "A high visibility jumpsuit with additional protection from gas and chemical hazards, at the cost of less fire-proofing."
	icon_state = "hazard_green"
	armor_type = /datum/armor/clothing_under/nova_hazard_chem
	resistance_flags = ACID_PROOF
	alt_covers_chest = TRUE

/datum/armor/clothing_under/nova_hazard_chem
	fire = 20
	acid = 60

/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem/emt
	name = "chemical hazard EMT jumpsuit"
	desc = "An EMT jumpsuit used for first responders in situations involving gas and/or chemical hazards. The label reads, \"Not designed for prolonged exposure\"."
	icon_state = "hazard_white"
	armor_type = /datum/armor/clothing_under/hazard_chem_emt

/*
*	CHIEF ENGINEER
*/

/datum/armor/clothing_under/hazard_chem_emt
	fire = 10
	acid = 50

/obj/item/clothing/under/rank/engineering/chief_engineer/nova/imperial
	desc = "A gray naval suit with a lead-lined vest and a rank badge denoting the Officer of the Internal Engineering Division. Doesn't come with a death machine building guide."
	name = "chief engineer's naval jumpsuit"
	icon_state = "impce"

/*
*	ATMOS TECH
*/
/datum/armor/clothing_under/atmos_adv
	bio = 40
	fire = 70
	acid = 70

/obj/item/clothing/under/rank/engineering/atmospheric_technician/nova/utility/advanced
	name = "advanced atmospherics uniform"
	desc = "A jumpsuit worn by advanced atmospherics crews."
	icon_state = "util_atmos"
	armor_type = /datum/armor/clothing_under/atmos_adv
	icon_state = "util_eng"
	can_adjust = FALSE
