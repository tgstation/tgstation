// Peacekeeper jumpsuit

/obj/item/clothing/under/sol_peacekeeper
	name = "sol peacekeeper uniform"
	desc = "A military-grade uniform with military grade comfort (none at all), often seen on \
		SolFed's various peacekeeping forces, and usually alongside a blue helmet."
	icon = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms.dmi'
	icon_state = "peacekeeper"
	worn_icon = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms_worn.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms_worn_digi.dmi'
	worn_icon_state = "peacekeeper"
	armor_type = /datum/armor/clothing_under/rank_security
	inhand_icon_state = null
	has_sensor = SENSOR_COORDS
	random_sensor = FALSE

// EMT jumpsuit
/datum/armor/clothing_under/rank_medical
	bio = 50

/obj/item/clothing/under/sol_emt
	name = "sol emergency medical uniform"
	desc = "A copy of SolFed's peacekeeping uniform, recolored and re-built with paramedics in mind."
	icon = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms.dmi'
	icon_state = "emt"
	worn_icon = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms_worn.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms_worn_digi.dmi'
	worn_icon_state = "emt"
	armor_type = /datum/armor/clothing_under/rank_medical
	inhand_icon_state = null
	has_sensor = SENSOR_COORDS
	random_sensor = FALSE

// Solfed flak jacket, for marshals

/obj/item/clothing/suit/armor/vest/det_suit/sol
	name = "'Gordyn' flak vest"
	desc = "A light armored jacket common on SolFed personnel who need armor, but find a full vest \
		too impractical or uneeded."
	icon = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms.dmi'
	icon_state = "flak"
	worn_icon = 'monkestation/code/modules/blueshift/icons/goofsec/uniforms_worn.dmi'
	worn_icon_state = "flak"
