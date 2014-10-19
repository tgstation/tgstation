//This is so damaged or burnt tiles or platings don't get remembered as the default tile
var/list/icons_to_ignore_at_floor_init = list("damaged1","damaged2","damaged3","damaged4",
				"damaged5","panelscorched","floorscorched1","floorscorched2","platingdmg1","platingdmg2",
				"platingdmg3","plating","light_on","light_on_flicker1","light_on_flicker2",
				"light_on_clicker3","light_on_clicker4","light_on_clicker5","light_broken",
				"light_on_broken","light_off","wall_thermite","grass1","grass2","grass3","grass4",
				"asteroid","asteroid_dug",
				"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
				"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
				"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "wood-broken",
				"carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
				"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
				"ironsand12", "ironsand13", "ironsand14", "ironsand15")

/turf/simulated/floor
	//NOTE: Floor code has been refactored, many procs were removed
	//using intact should be safe, you can also use istype
	//also worhy of note: floor_tile is now a path, and not a tile obj
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.040
	heat_capacity = 10000
	intact = 1
	var/lava = 0
	var/broken = 0
	var/burnt = 0
	var/mineral = "metal"
	var/floortype = "metal"
	var/floor_tile = /obj/item/stack/tile/plasteel
	var/list/broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	var/list/burnt_states = list()


/turf/simulated/floor/New()
	..()
	if(icon_state in icons_to_ignore_at_floor_init) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state

//turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
//	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
//		if (!( locate(/obj/machinery/mass_driver, src) ))
//			return 0
//	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/space)
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
				if(2)
					src.ChangeTurf(/turf/space)
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act()
	return

/turf/simulated/floor/proc/update_icon()
	if(lava)
		return 0
	else if(is_plasteel_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
		return 0

	spawn(1)
		if(istype(src,/turf/simulated/floor)) //Was throwing runtime errors due to a chance of it changing to space halfway through.
			if(air)
				update_visuals(air)

	return 1

/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/proc/gets_drilled()
	return

/turf/simulated/floor/is_plasteel_floor()
	if(ispath(floor_tile, /obj/item/stack/tile/plasteel))
		return 1
	else
		return 0

/turf/simulated/floor/proc/fancy_update()
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	make_plating()
	break_tile()

/turf/simulated/floor/proc/break_tile()
	if(broken)
		return
	src.icon_state = pick(broken_states)
	broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(broken || burnt)
		return

	if(is_plasteel_floor())
		src.icon_state = "floorscorched[pick(1,2)]"
	else if(burnt_states)
		src.icon_state = pick(burnt_states)
	else
		src.icon_state = pick(broken_states)
	burnt = 1

/turf/simulated/floor/proc/make_plating()
	make_floor(/turf/simulated/floor/plating)

//wrapped for ChangeTurf that handles fancy flooring properly
/turf/simulated/floor/proc/make_floor(turf/simulated/floor/T as turf)
	SetLuminosity(0)
	fancy_update() //this has a spawn() so it will actually update after ChangeTurf
	var/turf/simulated/floor/W = ChangeTurf(T)
	W.update_icon()
	W.levelupdate()
	return W

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0

	if(istype(C, /obj/item/weapon/crowbar))
		if(broken || burnt)
			broken = 0
			burnt = 0
			user << "<span class='danger'>You remove the broken plating.</span>"
		else
			if(istype(src, /turf/simulated/floor/wood))
				user << "<span class='danger'>You forcefully pry off the planks, destroying them in the process.</span>"
			else
				user << "<span class='danger'>You remove the floor tile.</span>"
				var/obj/item/stack/tile/T = new floor_tile(src)
				if(istype(T, /obj/item/stack/tile/light))
					var/obj/item/stack/tile/light/L = T
					var/turf/simulated/floor/light/F = src
					L.state = F.state
		make_plating()
		playsound(src, 'sound/items/Crowbar.ogg', 80, 1)
		return 0

	return 1
