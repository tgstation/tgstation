/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	desc = "The final frontier."
	icon_state = "0"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	intact = 0 //No seriously, that's not a joke. Allows cable to be laid properLY on catwalks
	dynamic_lighting = 0
	luminosity = 1
	can_border_transition = 1

/turf/space/New()
	if(loc)
		var/area/A = loc
		A.area_turfs += src

	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/canBuildCatwalk()
	if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	return locate(/obj/structure/lattice) in contents


/turf/space/canBuildLattice(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/sheet/wood)))
		return 1
	return BUILD_FAILURE

/turf/space/canBuildPlating(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if((locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/tile/wood)))
		return 1
	return BUILD_FAILURE

// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	inertial_drift(A)

/turf/space/proc/Sandbox_Spacemove(atom/movable/A as mob|obj)
	var/cur_x
	var/cur_y
	var/next_x
	var/next_y
	var/target_z
	var/list/y_arr

	if(src.x <= 1)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			qdel(A)
			A = null
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (--cur_x||global_map.len)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			A = null
			return

		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > global_map.len ? 1 : cur_x)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			A = null
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

	else if (src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor)||istype(A, /obj/effect/space_dust))
			qdel(A)
			A = null
			return
		var/list/cur_pos = src.get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	return

/turf/space/singularity_act()
	return

/turf/space/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	return ..(N, tell_universe, 1, allow)

/turf/space/lighting_build_overlays()
	return
