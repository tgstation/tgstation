/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/weapon/tank/internals/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back


/obj/item/weapon/tank/internals/oxygen/New()
	..()
	air_contents.assert_gas("o2")
	air_contents.gases["o2"][MOLES] = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/internals/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"
	dog_fashion = null

/obj/item/weapon/tank/internals/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"
	dog_fashion = null


/*
 * Anesthetic
 */
/obj/item/weapon/tank/internals/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"
	force = 10

/obj/item/weapon/tank/internals/anesthetic/New()
	..()
	air_contents.assert_gases("o2", "n2o")
	air_contents.gases["o2"][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	air_contents.gases["n2o"][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return

/*
 * Air
 */
/obj/item/weapon/tank/internals/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "oxygen"
	force = 10
	dog_fashion = /datum/dog_fashion/back

/obj/item/weapon/tank/internals/air/New()
	..()
	air_contents.assert_gases("o2","n2")
	air_contents.gases["o2"][MOLES] = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	air_contents.gases["n2"][MOLES] = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return


/*
 * Plasma
 */
/obj/item/weapon/tank/internals/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags = CONDUCT
	slot_flags = null	//they have no straps!
	force = 8


/obj/item/weapon/tank/internals/plasma/New()
	..()
	air_contents.assert_gas("plasma")
	air_contents.gases["plasma"][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/internals/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = W
		if ((!F.status)||(F.ptank))
			return
		if(!user.transferItemToLoc(src, F))
			return
		src.master = F
		F.ptank = src
		F.update_icon()
	else
		return ..()

/obj/item/weapon/tank/internals/plasma/full/New()
	..()
	air_contents.assert_gas("plasma")
	air_contents.gases["plasma"][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return


/*
 * Plasmaman Plasma Tank
 */

/obj/item/weapon/tank/internals/plasmaman
	name = "plasma internals tank"
	desc = "A tank of plasma gas designed specifically for use as internals, particularly for plasma-based lifeforms. If you're not a Plasmaman, you probably shouldn't use this."
	icon_state = "plasmaman_tank"
	item_state = "plasmaman_tank"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/weapon/tank/internals/plasmaman/New()
	..()
	air_contents.assert_gas("plasma")
	air_contents.gases["plasma"][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/internals/plasmaman/full/New()
	..()
	air_contents.assert_gas("plasma")
	air_contents.gases["plasma"][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/internals/plasmaman/belt
	icon_state = "plasmaman_tank_belt"
	item_state = "plasmaman_tank_belt"
	slot_flags = SLOT_BELT
	force = 5
	volume = 6
	w_class = WEIGHT_CLASS_SMALL //thanks i forgot this

/obj/item/weapon/tank/internals/plasmaman/belt/full/New()
	..()
	air_contents.assert_gas("plasma")
	air_contents.gases["plasma"][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return



/*
 * Emergency Oxygen
 */
/obj/item/weapon/tank/internals/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/weapon/tank/internals/emergency_oxygen/New()
	..()
	air_contents.assert_gas("o2")
	air_contents.gases["o2"][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/internals/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6

/obj/item/weapon/tank/internals/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 10
