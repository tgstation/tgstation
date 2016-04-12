//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass", "sand",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"basalt","basalt_dug",
				"basalt0","basalt1","basalt2","basalt3","basalt4",
				"basalt5","basalt6","basalt7","basalt8","basalt9","basalt10","basalt11","basalt12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")

/turf/open/floor
	//NOTE: Floor code has been refactored, many procs were removed and refactored
	//- you should use istype() if you want to find out whether a floor has a certain type
	//- floor_tile is now a path, and not a tile obj
	//- builtin_tile should be dropped if needed for performance reasons (eg singularity_act())
	name = "floor"
	icon = 'icons/turf/floors.dmi'

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	intact = 1
	var/broken = 0
	var/burnt = 0
	var/floor_tile = null //tile that this floor drops
	var/obj/item/stack/tile/builtin_tile = null //needed for performance reasons when the singularity rips off floor tiles
	var/list/broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	var/list/burnt_states = list()

/turf/open/floor/New()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state
	if(floor_tile)
		builtin_tile = new floor_tile

/turf/open/floor/Destroy()
	if(builtin_tile)
		qdel(builtin_tile)
		builtin_tile = null
	return ..()

/turf/open/floor/ex_act(severity, target)
	var/shielded = is_shielded()
	..()
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		src.ChangeTurf(src.baseturf)
	if(target != null)
		ex_act(3)
		return

	switch(severity)
		if(1)
			src.ChangeTurf(src.baseturf)
		if(2)
			switch(pick(1,2;75,3))
				if(1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					src.ChangeTurf(src.baseturf)
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		if(A.level == 3)
			return 1

/turf/open/floor/blob_act()
	return

/turf/open/floor/proc/update_icon()
	update_visuals()
	return 1

/turf/open/floor/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/open/floor/proc/gets_drilled()
	return

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	T.break_tile()

/turf/open/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/open/floor/burn_tile()
	if(broken || burnt)
		return
	if(burnt_states.len)
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/open/floor/proc/make_plating()
	return ChangeTurf(/turf/open/floor/plating)

/turf/open/floor/ChangeTurf(turf/open/floor/T)
	if(!istype(src,/turf/open/floor))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(T,/turf/open/floor))
		return ..()
	var/old_icon = icon_regular_floor
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.icon_regular_floor = old_icon
	W.dir = old_dir
	W.update_icon()
	return W

/turf/open/floor/attackby(obj/item/C, mob/user, params)
	if(!C || !user)
		return 1
	if(..())
		return 1
	if(intact && istype(C, /obj/item/weapon/crowbar))
		if(broken || burnt)
			broken = 0
			burnt = 0
			user << "<span class='danger'>You remove the broken plating.</span>"
		else
			if(istype(src, /turf/open/floor/wood))
				user << "<span class='danger'>You forcefully pry off the planks, destroying them in the process.</span>"
			else
				user << "<span class='danger'>You remove the floor tile.</span>"
				builtin_tile.loc = src
		make_plating()
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
		return 1
	return 0

/turf/open/floor/singularity_pull(S, current_size)
	if(current_size == STAGE_THREE)
		if(prob(30))
			if(builtin_tile)
				builtin_tile.loc = src
				make_plating()
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			if(builtin_tile)
				builtin_tile.loc = src
				make_plating()
	else if(current_size >= STAGE_FIVE)
		if(builtin_tile)
			if(prob(70))
				builtin_tile.loc = src
				make_plating()
		else if(prob(50))
			ReplaceWithLattice()

/turf/open/floor/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/open/floor/engine/cult)

/turf/open/floor/can_have_cabling()
	return !burnt && !broken

/turf/open/floor/initialize()
	..()
	MakeDirty()