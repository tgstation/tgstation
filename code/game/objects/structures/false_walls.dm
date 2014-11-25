/*
 * False Walls
 */

// Minimum pressure difference to fail building falsewalls.
// Also affects admin alerts.
#define FALSEDOOR_MAX_PRESSURE_DIFF 25.0

/**
* Gets the highest and lowest pressures from the tiles in cardinal directions
* around us, then checks the difference.
*/
/proc/getOPressureDifferential(var/turf/loc)
	var/minp=16777216;
	var/maxp=0;
	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		var/cp=0
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			cp = environment.return_pressure()
		else
			if(istype(T,/turf/simulated))
				continue
		if(cp<minp)minp=cp
		if(cp>maxp)maxp=cp
	return abs(minp-maxp)

// Checks pressure here vs. around us.
/proc/performFalseWallPressureCheck(var/turf/loc)
	var/turf/simulated/lT=loc
	if(!istype(lT) || !lT.zone)
		return 0
	var/datum/gas_mixture/myenv=lT.return_air()
	var/pressure=myenv.return_pressure()

	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			var/pdiff = abs(pressure - environment.return_pressure())
			if(pdiff > FALSEDOOR_MAX_PRESSURE_DIFF)
				return pdiff
	return 0

/proc/performWallPressureCheck(var/turf/loc)
	var/pdiff = getOPressureDifferential(loc)
	if(pdiff > FALSEDOOR_MAX_PRESSURE_DIFF)
		return pdiff
	return 0

/client/proc/pdiff()
	set name = "Get PDiff"
	set category = "Debug"

	if(!mob || !holder)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/pdiff = getOPressureDifferential(T)
	var/fwpcheck=performFalseWallPressureCheck(T)
	var/wpcheck=performWallPressureCheck(T)

	src << "Pressure Differential (cardinals): [pdiff]"
	src << "FWPCheck: [fwpcheck]"
	src << "WPCheck: [wpcheck]"

/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	anchored = 1
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/opening = 0

	canSmoothWith = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall // WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	)

/obj/structure/falsewall/New()
	..()
	relativewall()
	relativewall_neighbours()

/obj/structure/falsewall/Destroy()

	var/temploc = src.loc

	spawn(10)
		for(var/turf/simulated/wall/W in range(temploc,1))
			W.relativewall()

		for(var/obj/structure/falsewall/W in range(temploc,1))
			W.relativewall()

		for(var/obj/structure/falserwall/W in range(temploc,1))
			W.relativewall()
	..()


/obj/structure/falsewall/relativewall()

	if(!density)
		icon_state = "[mineral]fwall_open"
		return

	var/junction=findSmoothingNeighbors()
	icon_state = "[mineral][junction]"

/obj/structure/falsewall/attack_ai(mob/user as mob)
	if(isMoMMI(user))
		src.add_hiddenprint(user)
		attack_hand(user)

/obj/structure/falsewall/attack_hand(mob/user as mob)
	if(opening)
		return

	if(density)
		opening = 1
		icon_state = "[mineral]fwall_open"
		flick("[mineral]fwall_opening", src)
		sleep(15)
		src.density = 0
		SetOpacity(0)
		opening = 0
	else
		opening = 1
		flick("[mineral]fwall_closing", src)
		icon_state = "[mineral]0"
		density = 1
		sleep(15)
		SetOpacity(1)
		src.relativewall()
		opening = 0

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	..()
	if(density)
		icon_state = "[mineral]0"
		src.relativewall()
	else
		icon_state = "[mineral]fwall_open"

/obj/structure/falsewall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opening)
		user << "\red You must wait until the door has stopped moving."
		return

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			user << "\red The wall is blocked!"
			return
		if(istype(W, /obj/item/weapon/screwdriver))
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			if(!mineral || mineral == "metal")
				T.ChangeTurf(/turf/simulated/wall)
			else
				T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
			del(src)

		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT:welding )
				if(!mineral)
					T.ChangeTurf(/turf/simulated/wall)
				else
					T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
				if(mineral != "plasma")//Stupid shit keeps me from pushing the attackby() to plasma walls -Sieve
					T = get_turf(src)
					T.attackby(W,user)
				del(src)
	else
		user << "\blue You can't reach, close it first!"

	if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "plasma")
			T = get_turf(src)
			T.attackby(W,user)
		del(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		T = get_turf(src)
		T.attackby(W,user)
		del(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "plasma")
			T = get_turf(src)
			T.attackby(W,user)
		del(src)

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	..()
	if(density)
		icon_state = "[mineral]0"
		src.relativewall()
	else
		icon_state = "[mineral]fwall_open"

/*
 * False R-Walls
 */

/obj/structure/falserwall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	density = 1
	opacity = 1
	anchored = 1
	var/mineral = "metal"
	var/opening = 0
	canSmoothWith = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall // WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	)

/obj/structure/falserwall/New()
	relativewall_neighbours()
	..()


/obj/structure/falserwall/attack_ai(mob/user as mob)
	if(isMoMMI(user))
		src.add_hiddenprint(user)
		attack_hand(user)

/obj/structure/falserwall/attack_hand(mob/user as mob)
	if(opening)
		return

	if(density)
		opening = 1
		// Open wall
		icon_state = "frwall_open"
		flick("frwall_opening", src)
		sleep(15)
		density = 0
		SetOpacity(0)
		opening = 0
	else
		opening = 1
		icon_state = "r_wall"
		flick("frwall_closing", src)
		density = 1
		sleep(15)
		SetOpacity(1)
		relativewall()
		opening = 0

/obj/structure/falserwall/relativewall()

	if(!density)
		icon_state = "frwall_open"
		return
	var/junction=findSmoothingNeighbors()
	icon_state = "rwall[junction]"

/obj/structure/falserwall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opening)
		user << "\red You must wait until the door has stopped moving."
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		var/turf/T = get_turf(src)
		user.visible_message("[user] tightens some bolts on the r wall.", "You tighten the bolts on the wall.")
		T.ChangeTurf(/turf/simulated/wall/r_wall) //Why not make rwall?
		del(src)

	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/simulated/wall)
			T = get_turf(src)
			T.attackby(W,user)
			del(src)

	else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall)
		T = get_turf(src)
		T.attackby(W,user)
		del(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall)
		T = get_turf(src)
		T.attackby(W,user)
		del(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall)
		T = get_turf(src)
		T.attackby(W,user)
		del(src)


/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = ""
	mineral = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = ""
	mineral = "gold"

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon_state = ""
	mineral = "silver"

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = ""
	mineral = "diamond"

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = ""
	mineral = "plasma"

//-----------wtf?-----------start
/obj/structure/falsewall/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = ""
	mineral = "clown"

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = ""
	mineral = "sandstone"
//------------wtf?------------end