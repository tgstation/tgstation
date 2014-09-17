/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	intact = 0

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/space/New()
	if(!istype(src, /turf/space/transit))
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			user << "<span class='warning'>There is already a lattice.</span>"
			return
		if(R.use(1))
			user << "<span class='notice'>Constructing support lattice...</span>"
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			user << "<span class='warning'>You need one rod to build lattice.</span>"
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				user << "<span class='notice'>You build a floor.</span>"
				S.build(src)
			else
				user << "<span class='warning'>You need one floor tile to build a floor.</span>"
		else
			user << "<span class='danger'>The plating is going to need some support. Place metal rods first.</span>"

/turf/space/Entered(atom/movable/A)
	..()
	if ((!(A) || src != A.loc))
		return

	inertial_drift(A)

	if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
		var/move_to_z = src.z
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

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.loc = T

/turf/space/proc/Sandbox_Spacemove(atom/movable/A)
	var/cur_x
	var/cur_y
	var/next_x = src.x
	var/next_y = src.y
	var/target_z
	var/list/y_arr
	var/list/cur_pos = src.get_global_map_pos()
	if(!cur_pos)
		return
	cur_x = cur_pos["x"]
	cur_y = cur_pos["y"]

	if(src.x <= 1)
		next_x = (--cur_x||global_map.len)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
		next_x = world.maxx - 2
	else if (src.x >= world.maxx)
		next_x = (++cur_x > global_map.len ? 1 : cur_x)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
		next_x = 3
	else if (src.y <= 1)
		y_arr = global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
		next_y = world.maxy - 2
	else if (src.y >= world.maxy)
		y_arr = global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
		next_y = 3

	var/turf/T = locate(next_x, next_y, target_z)
	A.Move(T)

/turf/space/handle_slip()
	return
