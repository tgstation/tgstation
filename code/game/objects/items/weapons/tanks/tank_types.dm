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
	name = "Gas Tank (Oxygen)"
	desc = "A tank of oxygen"
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			playsound(usr, 'sound/effects/alert.ogg', 50, 1)


/obj/item/weapon/tank/oxygen/yellow
	name = "Gas Tank (Oxygen)"
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/weapon/tank/oxygen/red
	name = "Gas Tank (Oxygen)"
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"


/*
 * Anesthetic
 */
/obj/item/weapon/tank/anesthetic
	name = "Gas Tank (Sleeping Agent)"
	desc = "A N2O/O2 gas mix"
	icon_state = "anesthetic"
	item_state = "an_tank"

/obj/item/weapon/tank/anesthetic/New()
	..()

	src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD

	var/datum/gas/sleeping_agent/trace_gas = new()
	trace_gas.moles = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

	src.air_contents.trace_gases += trace_gas
	return

/*
 * Air
 */
/obj/item/weapon/tank/air
	name = "Gas Tank (Air Mix)"
	desc = "Mixed anyone?"
	icon_state = "oxygen"


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 1 && loc==usr)
			usr << "\red <B>The meter on the [src.name] indicates you are almost out of air!</B>"
			usr << sound('sound/effects/alert.ogg')

/obj/item/weapon/tank/air/New()
	..()

	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	src.air_contents.nitrogen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return


/*
 * Plasma
 */
/obj/item/weapon/tank/plasma
	name = "Gas Tank (BIOHAZARD)"
	desc = "Contains dangerous plasma. Do not inhale."
	icon_state = "plasma"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = null	//they have no straps!


/obj/item/weapon/tank/plasma/New()
	..()

	src.air_contents.toxins = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/plasma/proc/release()
	var/datum/gas_mixture/removed = air_contents.remove(air_contents.total_moles())

	loc.assume_air(removed)

/obj/item/weapon/tank/plasma/proc/ignite()
	var/fuel_moles = air_contents.toxins + air_contents.oxygen/6
	var/strength = 1

	var/turf/ground_zero = get_turf(loc)
	loc = null

	if(air_contents.temperature > (T0C + 400))
		strength = fuel_moles/15

		explosion(ground_zero, strength, strength*2, strength*3, strength*4)

	else if(air_contents.temperature > (T0C + 250))
		strength = fuel_moles/20

		explosion(ground_zero, 0, strength, strength*2, strength*3)

	else if(air_contents.temperature > (T0C + 100))
		strength = fuel_moles/25

		explosion(ground_zero, 0, 0, strength, strength*3)

	else
		ground_zero.assume_air(air_contents)
		ground_zero.hotspot_expose(1000, 125)

	if(src.master)
		del(src.master)
	del(src)

/obj/item/weapon/tank/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = W
		if ((!F.status)||(F.ptank))	return
		src.master = F
		F.ptank = src
		user.before_take_item(src)
		src.loc = F
	return

/*
 * Emergency Oxygen
 */
/obj/item/weapon/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	force = 4.0
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 3 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


	New()
		..()
		src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 0.2 && loc==usr)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			usr << sound('sound/effects/alert.ogg')

/obj/item/weapon/tank/emergency_oxygen/engi
	icon_state = "emergency_engi"
	name = "extended-capacity emergency oxygen tank"
	volume = 6

/obj/item/weapon/tank/emergency_oxygen/double
	icon_state = "emergency_double"
	name = "Double Emergency Oxygen Tank"
	volume = 10
