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
/obj/item/weapon/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/weapon/tank/oxygen/New()
	..()
	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/weapon/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"


/*
 * Anesthetic
 */
/obj/item/weapon/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"

/obj/item/weapon/tank/anesthetic/New()
	..()

	src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD

	var/datum/gas/sleeping_agent/trace_gas = new()
	trace_gas.moles = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

	src.air_contents.trace_gases += trace_gas
	return

/*
 * Air
 */
/obj/item/weapon/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "oxygen"


/obj/item/weapon/tank/air/New()
	..()

	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	src.air_contents.nitrogen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return


/*
 * Plasma
 */
/obj/item/weapon/tank/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags = CONDUCT
	slot_flags = null	//they have no straps!


/obj/item/weapon/tank/plasma/New()
	..()

	src.air_contents.toxins = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = W
		if ((!F.status)||(F.ptank))	return
		src.master = F
		F.ptank = src
		user.unEquip(src)
		src.loc = F
	return

/obj/item/weapon/tank/plasma/full/New()
	..()
	src.air_contents.toxins = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/*
 * Emergency Oxygen
 */
/obj/item/weapon/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/weapon/tank/emergency_oxygen/New()
	..()
	src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6

/obj/item/weapon/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 10
