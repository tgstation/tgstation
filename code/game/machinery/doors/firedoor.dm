/var/const/OPEN = 1
/var/const/CLOSED = 2


/obj/machinery/door/firedoor
	name = "Firelock"
	desc = "Apply crowbar"
	icon = 'Doorfire.dmi'
	icon_state = "door_open"
	var/blocked = 0
	opacity = 0
	density = 0
	var/nextstate = null
	var/net_id

	Bumped(atom/AM)
		if(p_open || operating)	return
		if(!density)	return ..()
		return 0


	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		return


	attackby(obj/item/weapon/C as obj, mob/user as mob)
		src.add_fingerprint(user)
		if(operating)	return//Already doing something.
		if(istype(C, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = C
			if(W.remove_fuel(0, user))
				src.blocked = !src.blocked
				user << text("\red You [blocked?"welded":"unwelded"] the [src]")
				update_icon()
				return

		if (istype(C, /obj/item/weapon/crowbar) || (istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1))
			if(blocked || operating)	return
			if(src.density)
				spawn(0)
					open()
					return
			else //close it up again
				spawn(0)
					close()
					return
		return


	process()
		if(operating || stat & NOPOWER || !nextstate)
			return
		switch(nextstate)
			if(OPEN)
				spawn()
					open()
			if(CLOSED)
				spawn()
					close()
		nextstate = null
		return


	animate(animation)
		switch(animation)
			if("opening")
				flick("door_opening", src)
			if("closing")
				flick("door_closing", src)
		return


	update_icon()
		overlays = null
		if(density)
			icon_state = "door_closed"
			if(blocked)
				overlays += "welded"
		else
			icon_state = "door_open"
			if(blocked)
				overlays += "welded_open"
		return



//border_only fire doors are special when it comes to air groups
/obj/machinery/door/firedoor/border_only

	New()
		..()
		var/turf/simulated/source = get_turf(src)
		var/turf/simulated/T = get_step(source,dir)
		if(!source.CanPass(null, T, 0, 0) || !locate(/obj/machinery/door/firedoor/border_only) in T)
			var/obj/machinery/door/firedoor/F = new(source)
			F.name = name
			F.desc = desc
			F.dir = dir
			spawn(0)
				del src

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group)
			var/direction = get_dir(src,target)
			if(direction)
				return (dir != direction)
			return 1 //It will break the zone when it actually drops, otherwise let it work normally.
		else if(density)
			if(!height)
				var/direction = get_dir(src,target)
				if(direction)
					return (dir != direction)
				return 0
		return 1


	update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = get_turf(src)
		var/turf/simulated/destination = get_step(source,dir)

		if(istype(source)) air_master.tiles_to_update |= source
		if(istype(destination)) air_master.tiles_to_update |= destination
		return 1