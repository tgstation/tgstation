//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "mineral door"
	density = 1
	anchored = 1
	opacity = 1

	icon = 'mineral_doors.dmi'
	icon_state = "iron"

	var/mineralType = "iron"
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0
	var/hardness = 1
	var/oreAmount = 7

	New(location)
		..()
		icon_state = mineralType
		name = "[mineralType] door"
		update_nearby_tiles(need_rebuild=1)

	Del()
		update_nearby_tiles()
		..()

	Bumped(atom/user)
		..()
		if(!state)
			return TryToSwitchState(user)
		return

	attack_ai(mob/user as mob) //those aren't machinery, they're just big fucking slabs of a mineral
		if(isAI(user)) //so the AI can't open it
			return
		else if(isrobot(user)) //but cyborgs can
			if(get_dist(user,src) <= 1) //not remotely though
				return TryToSwitchState(user)

	attack_paw(mob/user as mob)
		return TryToSwitchState(user)

	attack_hand(mob/user as mob)
		return TryToSwitchState(user)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group) return 0
		if(istype(mover, /obj/effect/beam))
			return !opacity
		return !density

	proc/TryToSwitchState(atom/user)
		if(isSwitchingStates) return
		if(ismob(user))
			var/mob/M = user
			if(world.time - user.last_bumped <= 60) return //NOTE do we really need that?
			if(M.client && !M:handcuffed)
				SwitchState()
		else if(istype(user, /obj/mecha))
			SwitchState()

	proc/SwitchState()
		if(state)
			Close()
		else
			Open()

	proc/Open()
		isSwitchingStates = 1
		playsound(loc, 'stonedoor_openclose.ogg', 100, 1)
		flick("[mineralType]opening",src)
		sleep(10)
		density = 0
		opacity = 0
		state = 1
		update_icon()
		isSwitchingStates = 0

	proc/Close()
		isSwitchingStates = 1
		playsound(loc, 'stonedoor_openclose.ogg', 100, 1)
		flick("[mineralType]closing",src)
		sleep(10)
		density = 1
		opacity = 1
		state = 0
		update_icon()
		isSwitchingStates = 0

	update_icon()
		if(state)
			icon_state = "[mineralType]open"
		else
			icon_state = mineralType

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/pickaxe))
			var/obj/item/weapon/pickaxe/digTool = W
			user << "You start digging the [name]."
			if(do_after(user,digTool.digspeed*hardness) && src)
				user << "You finished digging."
				Dismantle()
		else if(istype(W,/obj/item/weapon)) //not sure, can't not just weapons get passed to this proc?
			hardness -= W.force/100
			user << "You hit the [name] with your [W.name]!"
			CheckHardness()
		else
			attack_hand(user)
		return

	proc/CheckHardness()
		if(hardness <= 0)
			Dismantle(1)

	proc/Dismantle(devastated = 0)
		if(!devastated)
			var/ore = text2path("/obj/item/weapon/ore/[mineralType]")
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
		del(src)

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

	proc/update_nearby_tiles(need_rebuild) //Copypasta from airlock code
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/north = get_step(source,NORTH)
		var/turf/simulated/south = get_step(source,SOUTH)
		var/turf/simulated/east = get_step(source,EAST)
		var/turf/simulated/west = get_step(source,WEST)

		if(istype(source)) air_master.tiles_to_update += source
		if(istype(north)) air_master.tiles_to_update += north
		if(istype(south)) air_master.tiles_to_update += south
		if(istype(east)) air_master.tiles_to_update += east
		if(istype(west)) air_master.tiles_to_update += west

		return 1

/obj/structure/mineral_door/iron
	mineralType = "iron"
	hardness = 3

/obj/structure/mineral_door/silver
	mineralType = "silver"
	hardness = 3

/obj/structure/mineral_door/gold
	mineralType = "gold"

/obj/structure/mineral_door/uranium
	mineralType = "uranium"
	hardness = 3

	New()
		..()
		ul_SetLuminosity(3)

/obj/structure/mineral_door/sandstone
	mineralType = "sandstone"
	hardness = 0.5

/obj/structure/mineral_door/transparent
	opacity = 0

	Close()
		..()
		opacity = 0

/obj/structure/mineral_door/transparent/plasma
	mineralType = "plasma"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				TemperatureAct(100)
		..()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			TemperatureAct(exposed_temperature)

	proc/TemperatureAct(temperature)
		for(var/turf/simulated/floor/target_tile in range(2,loc))

			var/datum/gas_mixture/napalm = new

			var/toxinsToDeduce = temperature/10

			napalm.toxins = toxinsToDeduce
			napalm.temperature = 400+T0C
			napalm.update_values()

			target_tile.assume_air(napalm)
			spawn (0) target_tile.hotspot_expose(temperature, 400)

			hardness -= toxinsToDeduce/100
			CheckHardness()

/obj/structure/mineral_door/transparent/diamond
	mineralType = "diamond"
	hardness = 10

/obj/structure/mineral_door/wood
	mineralType = "wood"
	hardness = 1

	Open()
		isSwitchingStates = 1
		playsound(loc, 'doorcreaky.ogg', 100, 1)
		flick("[mineralType]opening",src)
		sleep(10)
		density = 0
		opacity = 0
		state = 1
		update_icon()
		isSwitchingStates = 0

	Close()
		isSwitchingStates = 1
		playsound(loc, 'doorcreaky.ogg', 100, 1)
		flick("[mineralType]closing",src)
		sleep(10)
		density = 1
		opacity = 1
		state = 0
		update_icon()
		isSwitchingStates = 0

	Dismantle(devastated = 0)
		if(!devastated)
			for(var/i = 1, i <= oreAmount, i++)
				new/obj/item/stack/sheet/wood(get_turf(src))
		del(src)

/obj/structure/mineral_door/resin
	mineralType = "resin"
	hardness = 5

	Open()
		isSwitchingStates = 1
		playsound(loc, 'attackblob.ogg', 100, 1)
		flick("[mineralType]opening",src)
		sleep(10)
		density = 0
		opacity = 0
		state = 1
		update_icon()
		isSwitchingStates = 0

	Close()
		isSwitchingStates = 1
		playsound(loc, 'attackblob.ogg', 100, 1)
		flick("[mineralType]closing",src)
		sleep(10)
		density = 1
		opacity = 1
		state = 0
		update_icon()
		isSwitchingStates = 0

	Dismantle(devastated = 0)
		del(src)
