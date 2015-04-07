/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	intact = 0

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	var/destination_x
	var/destination_y
	var/destination_z

/turf/space/New()
	if(!istype(src, /turf/space/transit))
		icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
	update_starlight()

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
			user << "<span class='warning'>There is already a catwalk here.</span>"
			return
		if(L)
			if(R.use(1))
				user << "<span class='notice'>Constructing catwalk...</span>"
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				qdel(L)
				ReplaceWithCatwalk()
			else
				user << "<span class='warning'>You need two rods to build a catwalk.</span>"
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
				user << "<span class='warning'>You need one floor tile to build a floor.</span>"
		else
			user << "<span class='danger'>The plating is going to need some support. Place metal rods first.</span>"

/turf/space/Entered(atom/movable/A)
	..()
	if ((!(A) || src != A.loc))
		return

	if(destination_z)

		if(destination_x)
			A.x = destination_x

		if(destination_y)
			A.y = destination_y

		A.z = destination_z

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.loc = T

		//now we're on the new z_level, proceed the space drifting
		sleep(0)//Let a diagonal move finish, if necessary
		A.newtonian_move(A.inertia_dir)

/turf/space/handle_slip()
	return

/*
Arranges all playable z levels (SS13, derelict, old sat and mining) in a grid.
Normally a 2x2 grid, but if the number of z levels is other than 4 it might be 1x2, 2x1, 2x3 or 3x2.
The grid is randomized, but all transitions are bidirectional. Passing through the north edge
of the grid will warp you to the south edge and vice versa, et cetera, quod erat demonstrandum
*/
proc/setup_map_transitions()
	var/list/grid_levels = accessible_z_levels.Copy()
	var/list/edge_turfs = list()

	var/grid_width = Ceiling(sqrt(grid_levels.len))
	var/grid_height = Ceiling(grid_levels.len / grid_width)

	if(prob(50)) //choose between horizontal and vertical rectangle for grid (e.g. 2x3 vs 3x2)
		var/swap_temp = grid_width
		grid_width = grid_height
		grid_height = swap_temp

	while(grid_levels.len < grid_width * grid_height) //pad grid with deep spess if needed (3 or 5 levels)
		grid_levels += ZLEVEL_DEEPSPACE

	if(grid_levels.len > 6) //too many z levels
		world.log << "Numbers of accessible z levels above 6 are not supported"

	shuffle(grid_levels) //randomize grid

	for(var/turf/space/S in world) //gather all map edge turfs
		if (S.x == TRANSITIONEDGE || S.x == (world.maxx - TRANSITIONEDGE - 1) || S.y == TRANSITIONEDGE || S.y == (world.maxy - TRANSITIONEDGE - 1))
			edge_turfs += S

	//if we've processed lots of turfs, switch to background processing to prevent being mistaken for an infinite loop
	if(edge_turfs.len > 8000)
		set background = 1

	for(var/turf/space/S in edge_turfs)
		var/index = grid_levels.Find(S.z) - 1 // indexing from 0 for easy xy transform
		if(index == -1)
			continue

		var/grid_x = index % grid_width
		var/grid_y = round(index / grid_width)

		if(S.x <= TRANSITIONEDGE) 							//west
			S.destination_x = world.maxx - TRANSITIONEDGE - 2
			grid_x = Wrap(grid_x - 1, 0, grid_width)
		else if (S.x >= (world.maxx - TRANSITIONEDGE - 1)) 	//east
			S.destination_x = TRANSITIONEDGE + 1
			grid_x = (grid_x + 1) % grid_width //fast wrap
		else if (S.y <= TRANSITIONEDGE) 					//south
			S.destination_y = world.maxy - TRANSITIONEDGE - 2
			grid_y = Wrap(grid_y - 1, 0, grid_height)
		else if (S.y >= (world.maxy - TRANSITIONEDGE - 1)) 	//north
			S.destination_y = TRANSITIONEDGE + 1
			grid_y = (grid_y + 1) % grid_height //fast wrap

		index = grid_x + grid_y * grid_width
		S.destination_z = grid_levels[index + 1]

/turf/space/singularity_act()
	return

/turf/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 1
	return 0
