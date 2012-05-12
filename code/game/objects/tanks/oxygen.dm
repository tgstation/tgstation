
/obj/item/weapon/tank/oxygen
	name = "Gas Tank (Oxygen)"
	desc = "A tank of oxygen"
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


	New()
		..()
		air_contents.adjustGases((6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))
		return


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			playsound(usr, 'alert.ogg', 50, 1)


/obj/item/weapon/tank/oxygen/yellow
	name = "Gas Tank (Oxygen)"
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"


/obj/item/weapon/tank/oxygen/red
	name = "Gas Tank (Oxygen)"
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"
