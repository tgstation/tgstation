/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	desc = "The final frontier."
	icon_state = "0"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/space/New()
	if(!istype(src, /turf/space/transit))
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.start_pulling(t)
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/space/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			if(R.amount < 2)
				user << "\red You don't have enough rods to do that."
				return
			user << "\blue You begin to build a catwalk."
			if(do_after(user,30))
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				user << "\blue You build a catwalk!"
				R.use(2)
				ChangeTurf(/turf/simulated/floor/plating/airless/catwalk)
				qdel(L)
				return

		user << "\blue Constructing support lattice ..."
		playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
		ReplaceWithLattice()
		R.use(1)
		return

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			qdel(L)
			playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
			S.build(src)
			S.use(1)
			return
		else
			user << "\red The plating is going to need some support."
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	if(movement_disabled)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return
	..()
	if ((!(A) || src != A.loc))	return

	inertial_drift(A)

	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return
		if(A.z > 6) return
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
			if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
				qdel(A)
				return

			if(istype(A, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks travel Z levels  ... And moving this shit down here so it only fires when they're actually trying to change z-level.
				del(A) //The disk's Destroy() proc ensures a new one is created
				return

			var/list/disk_search = A.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(disk_search))
				if(istype(A, /mob/living))
					var/mob/living/MM = A
					if(MM.client && !MM.stat)
						MM << "\red Something you are carrying is preventing you from leaving. Don't play stupid; you know exactly what it is."
						if(MM.x <= TRANSITIONEDGE)
							MM.inertia_dir = 4
						else if(MM.x >= world.maxx -TRANSITIONEDGE)
							MM.inertia_dir = 8
						else if(MM.y <= TRANSITIONEDGE)
							MM.inertia_dir = 1
						else if(MM.y >= world.maxy -TRANSITIONEDGE)
							MM.inertia_dir = 2
					else
						for(var/obj/item/weapon/disk/nuclear/N in disk_search)
							del(N)//Make the disk respawn it is on a clientless mob or corpse
				else
					for(var/obj/item/weapon/disk/nuclear/N in disk_search)
						del(N)//Make the disk respawn if it is floating on its own
				return

			var/move_to_z = src.z

			// Prevent MoMMIs from leaving the derelict.
			if(istype(A, /mob/living))
				var/mob/living/MM = A
				if(MM.client && !MM.stat)
					if(MM.locked_to_z!=0)
						if(src.z == MM.locked_to_z)
							MM << "\red You cannot leave this area."
							if(MM.x <= TRANSITIONEDGE)
								MM.inertia_dir = 4
							else if(MM.x >= world.maxx -TRANSITIONEDGE)
								MM.inertia_dir = 8
							else if(MM.y <= TRANSITIONEDGE)
								MM.inertia_dir = 1
							else if(MM.y >= world.maxy -TRANSITIONEDGE)
								MM.inertia_dir = 2
							return
						else
							MM << "\red You find your way back."
							move_to_z=MM.locked_to_z

			var/safety = 1

			while(move_to_z == src.z)
				var/move_to_z_str = pickweight(accessable_z_levels)
				move_to_z = text2num(move_to_z_str)
				safety++
				if(safety > 10)
					break

			if(!move_to_z)
				return

			A.z = move_to_z

			if(src.x <= TRANSITIONEDGE)
				A.x = world.maxx - TRANSITIONEDGE - 2
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
				A.x = TRANSITIONEDGE + 1
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (src.y <= TRANSITIONEDGE)
				A.y = world.maxy - TRANSITIONEDGE -2
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
				A.y = TRANSITIONEDGE + 1
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)


			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
