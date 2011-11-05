
/obj/item/weapon/tank/jetpack
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack0"
	w_class = 4.0
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	var
		datum/effect/effect/system/ion_trail_follow/ion_trail
		on = 0.0
		stabilization_on = 0


	New()
		..()
		src.ion_trail = new /datum/effect/effect/system/ion_trail_follow()
		src.ion_trail.set_up(src)
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
		return


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 10)
			usr << text("\red <B>The meter on the [src.name] indicates you are almost out of air!</B>")
			playsound(usr, 'alert.ogg', 50, 1)
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
		src.on = !( src.on )
		if(src.name == "Void Jetpack (oxygen)")         //Slight change added by me. i didn't make it an if-elseif because some of you might want to add other types of resprited packs :3 -Agouri
			src.icon_state = text("voidjetpack[]", src.on)
		else if(src.name == "Black Jetpack (oxygen)")
			src.icon_state = text("black_jetpack[]", src.on)
		else
			src.icon_state = text("jetpack[]", src.on)
		if(src.on)
			src.ion_trail.start()
		else
			src.ion_trail.stop()
		return


	proc/allow_thrust(num, mob/living/user as mob)
		if (!( src.on ))
			return 0
		if ((num < 0.005 || src.air_contents.total_moles() < num))
			src.ion_trail.stop()
			return 0

		var/datum/gas_mixture/G = src.air_contents.remove(num)

		if (G.oxygen >= 0.005)
			return 1
		if (G.toxins > 0.001)
			if (user)
				var/d = G.toxins / 2
				d = min(abs(user.health + 100), d, 25)
				user.take_organ_damage(0,d)
			return (G.oxygen >= 0.0025 ? 0.5 : 0)
		else
			if (G.oxygen >= 0.0025)
				return 0.5
			else
				return 0
		del(G)
		return


/obj/item/weapon/tank/jetpack/void_jetpack
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "voidjetpack0"
	item_state =  "jetpack-void"


/obj/item/weapon/tank/jetpack/black_jetpack
	name = "Black Jetpack (Oxygen)"
	desc = "A black model of jetpacks."
	icon_state = "black_jetpack0"
	item_state =  "jetpack-black"
