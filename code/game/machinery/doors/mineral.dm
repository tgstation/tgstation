//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/mineral
	name = "mineral door"
	use_power = 0
	machine_flags = 0
	icon = 'icons/obj/doors/mineral.dmi'
	prefix = "metal" //Corresponds to the mineral type

	soundeffect = 'sound/effects/stonedoor_openclose.ogg'
	var/hardness = 3
	var/oreAmount = 7

/obj/machinery/door/mineral/New(location)
	..()
	icon_state = "[prefix]door_closed"
	name = "[prefix] door"

/obj/machinery/door/mineral/Bumped(atom/user)
	if(operating) return

	if(istype(user, /obj/mecha))
		open()
	else if (istype(user, /obj/machinery/bot))
		open()
	else if(ismob(user))
		var/mob/M = user
		if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //This is what we call blind trust
			return
		if(world.time - M.last_bumped <= 10) //It was 60 previously, damn thats slow
			return
		M.last_bumped = world.time
		TryToSwitchState(user)
	return


/obj/machinery/door/mineral/attack_ai(mob/user as mob) //those aren't really machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && get_dist(user,src) <= 1) //but robots can, not remotely though
		return TryToSwitchState(user) //also >nesting if statements

/obj/machinery/door/mineral/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/mineral/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/machinery/door/mineral/proc/TryToSwitchState(mob/user as mob)
	if(operating) return

	if(!user.restrained() && !user.small)
		add_fingerprint(user)
		SwitchState()
	return

/obj/machinery/door/mineral/proc/SwitchState()
	if(!density)
		return close()
	else
		return open()

/obj/machinery/door/mineral/open()
	playsound(get_turf(src), soundeffect, 100, 1)
	return ..()

/obj/machinery/door/mineral/close()
	playsound(get_turf(src), soundeffect, 100, 1)
	return ..()

/obj/machinery/door/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/digTool = W
		user << "You start digging \the [src]."
		if(do_after(user,digTool.digspeed*hardness) && src)
			user << "You finished digging."
			return Dismantle()
	else if(istype(W, /obj/item/weapon/card))
		user << "You swipe your card at \the [src], petulantly expecting a result."
		return
	else
		hardness -= W.force/100
		user << "You hit \the [src] with your [W.name]!"
		CheckHardness()
	return

/obj/machinery/door/mineral/proc/CheckHardness()
	if(hardness <= 0)
		Dismantle(1)
	return

/obj/machinery/door/mineral/proc/Dismantle(devastated = 0)
	var/obj/item/stack/ore
	if(src.prefix == "metal")
		ore = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
	else
		var/P = text2path("/obj/item/stack/sheet/mineral/[prefix]")
		ore = new P(get_turf(src))
	ore.amount = oreAmount
	if(devastated) ore.amount -= 2
	qdel(src)
	return

/obj/machinery/door/mineral/ex_act(severity = 1)
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


/obj/machinery/door/mineral/iron
	prefix = "metal"

/obj/machinery/door/mineral/silver
	prefix = "silver"

/obj/machinery/door/mineral/gold
	prefix = "gold"
	hardness = 1

/obj/machinery/door/mineral/uranium
	prefix = "uranium"
	luminosity = 2

/obj/machinery/door/mineral/sandstone
	prefix = "sandstone"
	hardness = 0.5

/obj/machinery/door/mineral/transparent
	opacity = 0

	close()
		..()
		opacity = 0

/obj/machinery/door/mineral/transparent/plasma
	prefix = "plasma"
	hardness = 4

/obj/machinery/door/mineral/transparent/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			TemperatureAct(100)
	return ..()

/obj/machinery/door/mineral/transparent/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/machinery/door/mineral/transparent/plasma/proc/TemperatureAct(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))

		var/datum/gas_mixture/napalm = new //Napalm? Whelp. There should be a better way for this.

		var/toxinsToDeduce = temperature/10

		napalm.toxins = toxinsToDeduce
		napalm.temperature = 200+T0C

		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400,surfaces=1)

		hardness -= toxinsToDeduce/100
		CheckHardness()
	return

/obj/machinery/door/mineral/transparent/diamond
	prefix = "diamond"
	hardness = 10

/obj/machinery/door/mineral/wood
	prefix = "wood"
	hardness = 1
	soundeffect = 'sound/effects/doorcreaky.ogg'

/obj/machinery/door/mineral/wood/Dismantle(devastated = 0)
	var/obj/item/stack/resource = new/obj/item/stack/sheet/wood
	if(!devastated)
		resource.amount = oreAmount
		new resource(get_turf(src))
	qdel(src)
	return

/obj/machinery/door/mineral/wood/cultify()
	return

/obj/machinery/door/mineral/resin
	prefix = "resin"
	hardness = 1.5
	var/close_delay = 100
	soundeffect = 'sound/effects/attackblob.ogg'

/obj/machinery/door/mineral/resin/TryToSwitchState(atom/user)
	if(isalien(user))
		..()
	return

/obj/machinery/door/mineral/resin/open()
	..()
	spawn(close_delay)
		if(!operating && !density)
			close()

/obj/machinery/door/mineral/resin/Dismantle(devastated = 0)
	qdel(src)
	return

/obj/machinery/door/mineral/resin/CheckHardness()
	playsound(get_turf(src), soundeffect, 100, 1)
	return ..()

