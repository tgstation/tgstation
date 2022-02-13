/* Types of tanks!
 * Contains:
 * Oxygen
 * Anesthetic
 * Air
 * Plasma
 * Emergency Oxygen
 * Generic
 */

/// For advanced plasmaman belt tanks, target pressure that the tank will be autofilled to
#define AUTOFILL_TARGET_PRESSURE (ONE_ATMOSPHERE * 25)
/// For advanced plasmaman belt tanks, moles per sheet of plasma, based on crystallizer recipe
#define AUTOFILL_MOLES_PER_SHEET 450

/*
 * Oxygen
 */
/obj/item/tank/internals/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen, this one is blue."
	icon_state = "oxygen"
	tank_holder_icon_state = "holder_oxygen"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back


/obj/item/tank/internals/oxygen/populate_gas()
	air_contents.assert_gas(/datum/gas/oxygen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)


/obj/item/tank/internals/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"
	tank_holder_icon_state = "holder_oxygen_f"
	dog_fashion = null

/obj/item/tank/internals/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"
	tank_holder_icon_state = "holder_oxygen_fr"
	dog_fashion = null

/obj/item/tank/internals/oxygen/empty/populate_gas()
	return

/*
 * Anesthetic
 */
/obj/item/tank/internals/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	inhand_icon_state = "an_tank"
	tank_holder_icon_state = "holder_anesthetic"
	force = 10

/obj/item/tank/internals/anesthetic/populate_gas()
	air_contents.assert_gases(/datum/gas/oxygen, /datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

/*
 * Plasma
 */
/obj/item/tank/internals/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	worn_icon_state = "plasmatank"
	tank_holder_icon_state = null
	flags_1 = CONDUCT_1
	slot_flags = null //they have no straps!
	force = 8


/obj/item/tank/internals/plasma/populate_gas()
	air_contents.assert_gas(/datum/gas/plasma)
	air_contents.gases[/datum/gas/plasma][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/plasma/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/flamethrower))
		var/obj/item/flamethrower/F = W
		if ((!F.status)||(F.ptank))
			return
		if(!user.transferItemToLoc(src, F))
			return
		src.master = F
		F.ptank = src
		F.update_appearance()
	else
		return ..()

/obj/item/tank/internals/plasma/full/populate_gas()
	air_contents.assert_gas(/datum/gas/plasma)
	air_contents.gases[/datum/gas/plasma][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/plasma/empty/populate_gas()
	return

/*
 * Plasmaman Plasma Tank
 */

/obj/item/tank/internals/plasmaman
	name = "plasma internals tank"
	desc = "A tank of plasma gas designed specifically for use as internals, particularly for plasma-based lifeforms. If you're not a Plasmaman, you probably shouldn't use this."
	icon_state = "plasmaman_tank"
	inhand_icon_state = "plasmaman_tank"
	tank_holder_icon_state = null
	force = 10
	distribute_pressure = TANK_PLASMAMAN_RELEASE_PRESSURE

/obj/item/tank/internals/plasmaman/populate_gas()
	air_contents.assert_gas(/datum/gas/plasma)
	air_contents.gases[/datum/gas/plasma][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/plasmaman/full/populate_gas()
	air_contents.assert_gas(/datum/gas/plasma)
	air_contents.gases[/datum/gas/plasma][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)


/obj/item/tank/internals/plasmaman/belt
	icon_state = "plasmaman_tank_belt"
	inhand_icon_state = "plasmaman_tank_belt"
	worn_icon_state = "plasmaman_tank_belt"
	tank_holder_icon_state = null
	worn_icon = null
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 6 //same size as the engineering ones but plasmamen have special lungs that consume less plasma per breath
	w_class = WEIGHT_CLASS_SMALL //thanks i forgot this

/obj/item/tank/internals/plasmaman/belt/full/populate_gas()
	air_contents.assert_gas(/datum/gas/plasma)
	air_contents.gases[/datum/gas/plasma][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/plasmaman/belt/empty/populate_gas()
	return

/// Advanced plasma internals: Accepts plasma sheets, converts any input plasma sheets to 450 moles of 293.15K plasma and fills the tank up to 2533kPa
/obj/item/tank/internals/plasmaman/belt/advanced
	name = "advanced plasma internals tank"
	desc = "A tank of plasma gas designed specifically for use as internals, particularly for plasma-based lifeforms. If you're not a Plasmaman, you probably shouldn't use this. Contains a slot for inputting plasma sheets."
	icon_state = "plasmaman_tank_belt_advanced"
	inhand_icon_state = "plasmaman_tank_belt_advanced"
	worn_icon_state = "plasmaman_tank_belt_advanced"

/obj/item/tank/internals/plasmaman/belt/advanced/examine()
	. = ..()
	. += span_notice("There is a slot for inserting <b>plasma sheets</b> to be autofill the tank with breathable plasma gas.")

/obj/item/tank/internals/plasmaman/belt/advanced/attackby(obj/item/attacking_object, mob/user)
	if(istype(attacking_object, /obj/item/stack/sheet/mineral/plasma))
		if(air_contents.return_pressure() >= AUTOFILL_TARGET_PRESSURE)
			balloon_alert(user, "tank too full to autofill!")
			return TRUE
		var/obj/item/stack/sheet/mineral/plasma/plasma_sheets = attacking_object
		var/datum/gas_mixture/temporary = new /datum/gas_mixture
		temporary.temperature = T20C
		temporary.add_gas(/datum/gas/plasma)
		temporary.gases[/datum/gas/plasma][MOLES] = AUTOFILL_MOLES_PER_SHEET * plasma_sheets.amount
		var/moles_to_remove = temporary.gas_pressure_calculate(air_contents, AUTOFILL_TARGET_PRESSURE) // prevents the tank from exploding if i dont know, someone put supercold antinoblium in there
		if(moles_to_remove < MOLAR_ACCURACY)
			balloon_alert(user, "tank too full to autofill!")
			return TRUE
		var/datum/gas_mixture/removed = temporary.remove(moles_to_remove)
		air_contents.merge(removed) // actually refill the tank
		var/sheets_to_use = CEILING(removed.total_moles() / AUTOFILL_MOLES_PER_SHEET, 1)
		plasma_sheets.use(sheets_to_use)
		balloon_alert(user, "used [sheets_to_use] sheets to refill tank!")
		return TRUE
	..()

/obj/item/tank/internals/plasmaman/belt/advanced/empty/populate_gas()
	return

/obj/item/tank/internals/plasmaman/belt/advanced/full/populate_gas()
	air_contents.assert_gas(/datum/gas/plasma)
	air_contents.gases[/datum/gas/plasma][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)


/*
 * Emergency Oxygen
 */
/obj/item/tank/internals/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	worn_icon_state = "emergency"
	tank_holder_icon_state = "holder_emergency"
	worn_icon = null
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/tank/internals/emergency_oxygen/populate_gas()
	air_contents.assert_gas(/datum/gas/oxygen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)


/obj/item/tank/internals/emergency_oxygen/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	worn_icon_state = "emergency_engi"
	tank_holder_icon_state = "holder_emergency_engi"
	worn_icon = null
	volume = 6 // should last 24 minutes if full

/obj/item/tank/internals/emergency_oxygen/engi/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	worn_icon_state = "emergency_engi"
	tank_holder_icon_state = "holder_emergency_engi"
	volume = 12 //If it's double of the above, shouldn't it be double the volume??

/obj/item/tank/internals/emergency_oxygen/double/empty/populate_gas()
	return

// *
// * GENERIC
// *

/obj/item/tank/internals/generic
	name = "gas tank"
	desc = "A generic tank used for storing and transporting gasses. Can be used for internals."
	icon_state = "generic"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back

/obj/item/tank/internals/generic/populate_gas()
	return

#undef AUTOFILL_MOLES_PER_SHEET
#undef AUTOFILL_TARGET_PRESSURE
