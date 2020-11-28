/*
 * Nitrogen Tanks for Vox
 */

/obj/item/tank/internals/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen. Designed specifically for Vox"
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
	icon = 'modular_skyrat/modules/customization/icons/obj/tank.dmi'
	lefthand_file = 'modular_skyrat/modules/customization/icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/customization/icons/mob/inhands/equipment/tanks_righthand.dmi'
	icon_state = "nitrogen_extended"
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
	volume = 3

/obj/item/tank/internals/nitrogen/belt/emergency/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrogen)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
