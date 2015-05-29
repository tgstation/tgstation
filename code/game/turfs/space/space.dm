/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	intact = 0

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	var/transition //These is used in transistions as a way to tell where on the "cube" of space you're transitioning from/to
	var/destination_x
	var/destination_y

/turf/space/New()
	if(!istype(src, /turf/space/transit))
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	if(config)
		if(config.starlight)
			update_starlight()
/turf/space/Destroy()
	return QDEL_HINT_LETMELIVE

/turf/space/proc/update_starlight()
	if(config)
		if(config.starlight)
			for(var/turf/T in orange(src,1))
				if(istype(T,/turf/simulated))
					SetLuminosity(3)
					return
			SetLuminosity(0)

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			user << "<span class='warning'>There is already a catwalk here!</span>"
			return
		if(L)
			if(R.use(1))
				user << "<span class='notice'>You begin constructing catwalk...</span>"
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				qdel(L)
				ReplaceWithCatwalk()
			else
				user << "<span class='warning'>You need two rods to build a catwalk!</span>"
			return
		if(R.use(1))
			user << "<span class='notice'>Constructing support lattice...</span>"
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			user << "<span class='warning'>You need one rod to build a lattice.</span>"
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				user << "<span class='notice'>You build a floor.</span>"
				ChangeTurf(/turf/simulated/floor/plating)
			else
				user << "<span class='warning'>You need one floor tile to build a floor!</span>"
		else
			user << "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>"

/turf/space/Entered(atom/movable/A)
	..()
	if ((!(A) || src != A.loc))
		return

	if(transition)

		if(destination_x)
			A.x = destination_x

		if(destination_y)
			A.y = destination_y

		A.z =  text2num(transition)

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.loc = T

		//now we're on the new z_level, proceed the space drifting
		sleep(0)//Let a diagonal move finish, if necessary
		A.newtonian_move(A.inertia_dir)

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

/turf/space/proc/Assign_Destination()

	if(transition)
		if(x <= TRANSITIONEDGE) 							//west
			destination_x = world.maxx - TRANSITIONEDGE - 2
		else if (x >= (world.maxx - TRANSITIONEDGE - 1)) 	//east
			destination_x = TRANSITIONEDGE + 1
		else if (y <= TRANSITIONEDGE) 						//south
			destination_y = world.maxy - TRANSITIONEDGE - 2
		else if (y >= (world.maxy - TRANSITIONEDGE - 1)) 	//north
			destination_y = TRANSITIONEDGE + 1

/*
  Set the space turf transitions for the "space cube"

  Connections:
     ___     ___
   /_A_/|  /_F_/|
  |   |C| |   |E|
  |_B_|/  |_D_|/

  Note that all maps except F are oriented with north towards A. A and F are oriented with north towards D.
  The characters on the second cube should be upside down in this illustration, but aren't because of a lack of unicode support.
*/
proc/setup_map_transitions() //listamania

	var/list/unplaced_z_levels = 			accessable_z_levels
	var/list/free_zones = 					list("A", "B", "C", "D", "E", "F")
	var/list/zone_connections = 			list("D ","C ","B ","E ","A ","C ","F ","E ","A ","D ","F ","B ","A ","E ","F ","C ","A ","B ","F ","D ","D ","C ","B ","E") //This describes the borders of a cube based on free zones, really!
	var/text_zone_connections = 			list2text(zone_connections)
	var/list/final_zone_connections =		list()
	var/list/turfs_needing_transition =		list()
	var/list/turfs_needing_destinations = 	list()
	var/list/z_level_order = 				list()
	var/z_level
	var/placement
	var/total_processed = 0

	for(var/turf/space/S in world) //Define the transistions of the z levels
		total_processed++
		if (S.x == TRANSITIONEDGE || S.x == (world.maxx - TRANSITIONEDGE - 1) || S.y == TRANSITIONEDGE || S.y == (world.maxy - TRANSITIONEDGE - 1))
			turfs_needing_transition += S

	//if we've processed lots of turfs, switch to background processing to prevent being mistaken for an infinite loop
	if(total_processed > 450000)
		set background = 1

	while(free_zones.len != 0) //Assign the sides of the cube
		if(!unplaced_z_levels || !unplaced_z_levels.len) //if we're somehow unable to fill the cube, pad with deep space
			z_level =  6
		else
			z_level = pick(unplaced_z_levels)
		if(z_level > world.maxz) //A safety if one of the unplaced_z_levels doesn't actually exist
			z_level =  6
		placement = pick(free_zones)
		text_zone_connections = replacetext(text_zone_connections, placement, "[z_level]")

		for(var/turf/space/S in turfs_needing_transition) //pass the identity zone to the relevent turfs
			if(S.transition && prob(50)) //In z = 6 (deep space) it's a bit of a crapshoot in terms of navigation
				continue
			if(S.z == z_level)
				S.transition = num2text(z_level)
				if(!(S in turfs_needing_destinations))
					turfs_needing_destinations += S
				if(S.z != 6) //deep space turfs need to hang around in case they get reassigned a zone
					turfs_needing_transition -= S

		z_level_order += num2text(z_level)
		unplaced_z_levels -= z_level
		free_zones -= placement

	zone_connections = text2list(replacetext(text_zone_connections, " ", "\n")) //Convert the string back into a list

	final_zone_connections.len = z_level_order.len

	var/list/temp = list()

	for(var/j=1, j<= 24, j++)
		temp += zone_connections[j]
		if(temp.len == 4) //Chunks of cardinal directions
			final_zone_connections[z_level_order[j/4]] += temp
			temp = list()

	for(var/turf/space/S in turfs_needing_destinations) //replace the identity zone with the destination z-level
		var/list/directions = final_zone_connections[S.transition]
		if(S.x <= TRANSITIONEDGE)
			S.transition = directions[Z_WEST]
		else if(S.x >= (world.maxx - TRANSITIONEDGE - 1))
			S.transition = directions[Z_EAST]
		else if(S.y <= TRANSITIONEDGE)
			S.transition = directions[Z_SOUTH]
		else
			S.transition = directions[Z_NORTH]

		S.Assign_Destination()

/turf/space/singularity_act()
	return

/turf/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 1
	return 0
