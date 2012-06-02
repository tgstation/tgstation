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
		air_contents.adjustGases((3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))
		return


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 0.2 && loc==usr)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			usr << sound('alert.ogg')

/obj/item/weapon/tank/emergency_oxygen/engi
	icon_state = "emergency_engi"
	name = "extended-capacity emergency oxygen tank"
	volume = 6


/obj/item/weapon/tank/emergency_oxygen/double
	icon_state = "emergency_double"
	name = "Double Emergency Oxygen Tank"
	volume = 10

/obj/item/weapon/tank/emergency_oxygen/anesthetic
	icon_state = "emergency_sleep"
	name = "emergency sleeping gas tank"
	desc = "Contains an Oxygen/N2O mix."
	distribute_pressure = ONE_ATMOSPHERE

	New()
		..()
		var/datum/gas/sleeping_agent/trace_gas = new()
		trace_gas.moles = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
		air_contents.adjustGases((3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD, traces = list(trace_gas))
		return