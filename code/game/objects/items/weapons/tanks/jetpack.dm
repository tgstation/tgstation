//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = 4.0
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	var/datum/effect/effect/system/ion_trail_follow/ion_trail
	var/on = 0.0
	var/stabilization_on = 0
	var/volume_rate = 500              //Needed for borg jetpack transfer
	icon_action_button = "action_jetpack"

	New()
		..()
		src.ion_trail = new /datum/effect/effect/system/ion_trail_follow()
		src.ion_trail.set_up(src)
		return


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			playsound(usr, 'sound/effects/alert.ogg', 50, 1)
		return


	verb/toggle_rockets()
		set name = "Toggle Jetpack Stabilization"
		set category = "Object"
		src.stabilization_on = !( src.stabilization_on )
		usr << "You toggle the stabilization [stabilization_on? "on":"off"]."
		return


	verb/toggle()
		set name = "Toggle Jetpack"
		set category = "Object"
		on = !on
		if(on)
			icon_state = "[icon_state]-on"
//			item_state = "[item_state]-on"
			ion_trail.start()
		else
			icon_state = initial(icon_state)
//			item_state = initial(item_state)
			ion_trail.stop()
		return


	proc/allow_thrust(num, mob/living/user as mob)
		if(!(src.on))
			return 0
		if((num < 0.005 || src.air_contents.total_moles() < num))
			src.ion_trail.stop()
			return 0

		var/datum/gas_mixture/G = src.air_contents.remove(num)

		var/allgases = G.carbon_dioxide + G.nitrogen + G.oxygen + G.toxins	//fuck trace gases	-Pete
		if(allgases >= 0.005)
			return 1

		del(G)
		return

	ui_action_click()
		toggle()


/obj/item/weapon/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return

/obj/item/weapon/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return

/obj/item/weapon/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"

	New()
		..()
		src.ion_trail = new /datum/effect/effect/system/ion_trail_follow()
		src.ion_trail.set_up(src)
		src.air_contents.carbon_dioxide = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return

	examine()
		set src in usr
		..()
		if(air_contents.carbon_dioxide < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			playsound(usr, 'sound/effects/alert.ogg', 50, 1)
		return
