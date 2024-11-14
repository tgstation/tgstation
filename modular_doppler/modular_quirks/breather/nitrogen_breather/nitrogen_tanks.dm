/obj/item/tank/internals/nitrogen
	name = "nitrogen tank"
	desc = "A small tank of nitrogen, for crew who don't breathe the standard air mix."
	icon_state = "oxygen_fr"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/nitrogen/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/nitrogen/full/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/nitrogen/belt
	icon = 'modular_doppler/modular_quirks/breather/nitrogen_breather/icons/tank.dmi'
	worn_icon = 'modular_doppler/modular_quirks/breather/nitrogen_breather/icons/belt.dmi'
	lefthand_file = 'modular_doppler/modular_quirks/breather/nitrogen_breather/icons/tanks_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_quirks/breather/nitrogen_breather/icons/tanks_righthand.dmi'
	icon_state = "nitrogen_extended"
	inhand_icon_state = "nitrogen"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 24
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tank/internals/nitrogen/belt/full/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/nitrogen/belt/emergency
	name = "emergency nitrogen tank"
	desc = "Used for emergencies. Contains very little nitrogen, so try to conserve it until you actually need it."
	icon_state = "nitrogen"
	worn_icon_state = "nitrogen_extended"
	volume = 3

/obj/item/tank/internals/nitrogen/belt/emergency/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/datum/design/nitrogen_tank_belt
	name = "Compact Nitrogen Tank"
	desc = "A small, compact nitrogen tank that can fit on someones belt"
	id = "nitrogen_tank_belt" // added one more requirment since the Jaws of Life are a bit OP
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*0.75)
	build_path = /obj/item/tank/internals/nitrogen/belt
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO

/datum/design/nitrogen_tank
	name = "Nitrogen Tank"
	desc = "A full sized nitrogen tank"
	id = "nitrogen_tank" // added one more requirment since the Jaws of Life are a bit OP
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/tank/internals/nitrogen/belt
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_CARGO


