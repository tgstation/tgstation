/turf/open/space
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	name = "\proper space"
	intact = 0

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	var/destination_z
	var/destination_x
	var/destination_y

	var/global/datum/gas_mixture/space/space_gas = new
	plane = PLANE_SPACE
	light_power = 0.25
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED


/turf/open/space/basic/New()	//Do not convert to Initialize
	//This is used to optimize the map loader
	return

/turf/open/space/Initialize()
	icon_state = SPACE_ICON_STATE
	air = space_gas

	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(requires_activation)
		SSair.add_to_active(src)

	if (light_power && light_range)
		update_light()

	if (opacity)
		has_opaque_atom = TRUE

/turf/open/space/attack_ghost(mob/dead/observer/user)
	if(destination_z)
		var/turf/T = locate(destination_x, destination_y, destination_z)
		user.forceMove(T)

/turf/open/space/Initalize_Atmos(times_fired)
	return

/turf/open/space/TakeTemperature(temp)

/turf/open/space/RemoveLattice()
	return

/turf/open/space/AfterChange()
	..()
	atmos_overlay_types = null

/turf/open/space/Assimilate_Air()
	return

/turf/open/space/proc/update_starlight()
	if(config.starlight)
		for(var/t in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			if(isspaceturf(t))
				//let's NOT update this that much pls
				continue
			set_light(2)
			return
		set_light(0)

/turf/open/space/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/open/space/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		if(istype(area_restriction) && !istype(get_area(src), area_restriction))
			return
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, "<span class='warning'>There is already a catwalk here!</span>")
			return
		if(L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a catwalk.</span>")
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, "<span class='warning'>You need two rods to build a catwalk!</span>")
			return
		if(R.use(1))
			to_chat(user, "<span class='notice'>You construct a lattice.</span>")
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				ChangeTurf(/turf/open/floor/plating)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/open/space/Entered(atom/movable/A)
	..()
	if ((!(A) || src != A.loc))
		return

	if(destination_z)
		A.x = destination_x
		A.y = destination_y
		A.z = destination_z

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.loc = T

		//now we're on the new z_level, proceed the space drifting
		stoplag()//Let a diagonal move finish, if necessary
		A.newtonian_move(A.inertia_dir)

/turf/open/space/proc/Sandbox_Spacemove(atom/movable/A)
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

/turf/open/space/handle_slip()
	return

/turf/open/space/singularity_act()
	return

/turf/open/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 1
	return 0

/turf/open/space/is_transition_turf()
	if(destination_x || destination_y || destination_z)
		return 1


/turf/open/space/acid_act(acidpwr, acid_volume)
	return 0


/turf/open/space/rcd_vals(mob/user, obj/item/weapon/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 2)
	return FALSE

/turf/open/space/rcd_act(mob/user, obj/item/weapon/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a floor.</span>")
			ChangeTurf(/turf/open/floor/plating)
			return TRUE
	return FALSE