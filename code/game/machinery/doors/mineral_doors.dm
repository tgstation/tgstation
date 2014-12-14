//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/mineral_door
	name = "mineral door"
	density = 1
	anchored = 1
	opacity = 1
	use_power = 0
	machine_flags = 0
	icon = 'icons/obj/doors/mineral_doors.dmi'
	prefix = "metal" //Corresponds to the mineral type

	var/soundeffect = 'sound/effects/stonedoor_openclose.ogg'
	var/hardness = 3
	var/oreAmount = 7

	New(location)
		..()
		icon_state = "[prefix]door_closed"
		name = "[prefix] door"

	Bumped(atom/user)
		if(density)
			return TryToSwitchState(user)
		return

	attack_ai(mob/user as mob) //those aren't really machinery, they're just big fucking slabs of a mineral
		if(isAI(user)) //so the AI can't open it
			return
		else if(isrobot(user) && get_dist(user,src) <= 1) //but robots can, not remotely though
			return TryToSwitchState(user) //also >nesting if statements

	attack_paw(mob/user as mob)
		return TryToSwitchState(user)

	attack_hand(mob/user as mob)
		return TryToSwitchState(user)

	proc/TryToSwitchState(atom/user)
		if(operating) return

		if (ismob(user))
			var/mob/M = user
			if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //This is what we call blind trust
				return
			if(world.time - M.last_bumped <= 10) //It was 60 previously, damn thats slow
				return
			M.last_bumped = world.time
			if(!M.restrained() && !M.small)
				add_fingerprint(user)
				SwitchState()
			return

		else if(istype(user, /obj/mecha))
			open()

		else if (istype(user, /obj/machinery/bot))
			open()

		return

	proc/SwitchState()
		if(!density)
			close()
		else
			open()

	open()
		playsound(loc, soundeffect, 100, 1)
		..()

	close()
		playsound(loc, soundeffect, 100, 1)
		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/pickaxe))
			var/obj/item/weapon/pickaxe/digTool = W
			user << "You start digging the [name]."
			if(do_after(user,digTool.digspeed*hardness) && src)
				user << "You finished digging."
				return Dismantle()
		else if(istype(W, /obj/item/weapon/card))
			user << "You swipe your card at the [name], petulantly expecting a result."
			return
		else
			hardness -= W.force/100
			user << "You hit the [name] with your [W.name]!"
			CheckHardness()
		return

	proc/CheckHardness()
		if(hardness <= 0)
			Dismantle(1)

	proc/Dismantle(devastated = 0) //Rework to spawn one and edit stack quantity
		if(!devastated)
			if (prefix == "metal")
				var/ore = /obj/item/stack/sheet/metal
				for(var/i = 1, i <= oreAmount, i++)
					new ore(get_turf(src))
			else
				var/ore = text2path("/obj/item/stack/sheet/mineral/[prefix]")
				for(var/i = 1, i <= oreAmount, i++)
					new ore(get_turf(src))
		else
			if (prefix == "metal")
				var/ore = /obj/item/stack/sheet/metal
				for(var/i = 3, i <= oreAmount, i++)
					new ore(get_turf(src))
			else
				var/ore = text2path("/obj/item/stack/sheet/mineral/[prefix]")
				for(var/i = 3, i <= oreAmount, i++)
					new ore(get_turf(src))
		qdel(src)

	ex_act(severity = 1)
		switch(severity)
			if(1)
				Dismantle(1)
			if(2)
				if(prob(20))
					Dismantle(1)
				else
					hardness--
					CheckHardness()
			if(3)
				hardness -= 0.1
				CheckHardness()
		return


/obj/machinery/door/mineral_door/iron
	prefix = "metal"

/obj/machinery/door/mineral_door/silver
	prefix = "silver"

/obj/machinery/door/mineral_door/gold
	prefix = "gold"
	hardness = 1

/obj/machinery/door/mineral_door/uranium
	prefix = "uranium"
	luminosity = 2

/obj/machinery/door/mineral_door/sandstone
	prefix = "sandstone"
	hardness = 0.5

/obj/machinery/door/mineral_door/transparent
	opacity = 0

	close()
		..()
		opacity = 0

/obj/machinery/door/mineral_door/transparent/plasma
	prefix = "plasma"
	hardness = 4

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				TemperatureAct(100)
		..()

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			TemperatureAct(exposed_temperature)

	proc/TemperatureAct(temperature)
		for(var/turf/simulated/floor/target_tile in range(2,loc))

			var/datum/gas_mixture/napalm = new //Napalm? Whelp

			var/toxinsToDeduce = temperature/10

			napalm.toxins = toxinsToDeduce //Mineral walls says fix when fire_act works
			napalm.temperature = 200+T0C

			target_tile.assume_air(napalm)
			spawn (0) target_tile.hotspot_expose(temperature, 400,surfaces=1)

			hardness -= toxinsToDeduce/100
			CheckHardness()

/obj/machinery/door/mineral_door/transparent/diamond
	prefix = "diamond"
	hardness = 10

/obj/machinery/door/mineral_door/wood
	prefix = "wood"
	hardness = 1
	soundeffect = 'sound/effects/doorcreaky.ogg'

	Dismantle(devastated = 0)
		if(!devastated)
			for(var/i = 1, i <= oreAmount, i++)
				new/obj/item/stack/sheet/wood(get_turf(src))
		del(src)

/obj/machinery/door/mineral_door/wood/cultify()
	return

/obj/machinery/door/mineral_door/resin
	prefix = "resin"
	hardness = 1.5
	var/close_delay = 100
	soundeffect = 'sound/effects/attackblob.ogg'

	TryToSwitchState(atom/user)
		if(isalien(user))
			..()
		return

	open()
		..()
		spawn(close_delay)
			if(!operating && !density)
				close()

	Dismantle(devastated = 0)
		del(src)

	CheckHardness()
		playsound(loc, soundeffect, 100, 1)
		..()

