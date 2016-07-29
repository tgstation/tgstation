/*
 * False Walls
 */
<<<<<<< HEAD
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = 1
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	var/mineral = "metal"
	var/walltype = "metal"
	var/opening = 0
	density = 1
	opacity = 1

	canSmoothWith = list(
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust)
	smooth = SMOOTH_TRUE
	can_be_unanchored = 0

/obj/structure/falsewall/New(loc)
	..()
	air_update_turf(1)

/obj/structure/falsewall/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/falsewall/CanAtmosPass(turf/T)
	return !density

/obj/structure/falsewall/attack_hand(mob/user)
	if(opening)
		return

	opening = 1
	if(density)
		do_the_flick()
		sleep(5)
		if(!qdeleted(src))
			density = 0
			SetOpacity(0)
			update_icon()
	else
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = 0
			return
		do_the_flick()
		density = 1
		sleep(5)
		if(!qdeleted(src))
			SetOpacity(1)
			update_icon()
	air_update_turf(1)
	opening = 0

/obj/structure/falsewall/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		qdel(src)

/obj/structure/falsewall/proc/do_the_flick()
	if(density)
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
		icon_state = "fwall_opening"
	else
		icon_state = "fwall_closing"

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	if(density)
		smooth = SMOOTH_TRUE
		queue_smooth(src)
		icon_state = "wall"
	else
		icon_state = "fwall_open"

/obj/structure/falsewall/proc/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	if(!walltype || walltype == "metal")
		T.ChangeTurf(/turf/closed/wall)
	else
		T.ChangeTurf(text2path("/turf/closed/wall/mineral/[walltype]"))
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/attackby(obj/item/weapon/W, mob/user, params)
	if(opening)
		user << "<span class='warning'>You must wait until the door has stopped moving!</span>"
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(density)
			var/turf/T = get_turf(src)
			if(T.density)
				user << "<span class='warning'>[src] is blocked!</span>"
				return
			if(!istype(T, /turf/open/floor))
				user << "<span class='warning'>[src] bolts must be tightened on the floor!</span>"
				return
			user.visible_message("<span class='notice'>[user] tightens some bolts on the wall.</span>", "<span class='notice'>You tighten the bolts on the wall.</span>")
			ChangeToWall()
		else
			user << "<span class='warning'>You can't reach, close it first!</span>"

	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			dismantle(user)
	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		dismantle(user)
	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		D.playDigSound()
		dismantle(user)
	else
		return ..()

/obj/structure/falsewall/proc/dismantle(mob/user)
	user.visible_message("<span class='notice'>[user] dismantles the false wall.</span>", "<span class='notice'>You dismantle the false wall.</span>")
	new /obj/structure/girder/displaced(loc)
	if(mineral == "metal")
		if(istype(src, /obj/structure/falsewall/reinforced))
			new /obj/item/stack/sheet/plasteel(loc)
			new /obj/item/stack/sheet/plasteel(loc)
		else
			new /obj/item/stack/sheet/metal(loc)
			new /obj/item/stack/sheet/metal(loc)
	else
		var/P = text2path("/obj/item/stack/sheet/mineral/[mineral]")
		new P(loc)
		new P(loc)
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	qdel(src)

/obj/structure/falsewall/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0
=======

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

	to_chat(src, "Pressure Differential (cardinals): [pdiff]")
	to_chat(src, "FWPCheck: [fwpcheck]")
	to_chat(src, "WPCheck: [wpcheck]")

/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	anchored = 1
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/opening = 0

	// WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	canSmoothWith = "/turf/simulated/wall=0&/obj/structure/falsewall=0&/obj/structure/falserwall=0"

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
		set_opacity(0)
		opening = 0
	else
		opening = 1
		flick("[mineral]fwall_closing", src)
		icon_state = "[mineral]0"
		density = 1
		sleep(15)
		set_opacity(1)
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
		to_chat(user, "<span class='warning'>You must wait until the door has stopped moving.</span>")
		return

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			to_chat(user, "<span class='warning'>The wall is blocked!</span>")
			return
		if(isscrewdriver(W))
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			if(!mineral || mineral == "metal")
				T.ChangeTurf(/turf/simulated/wall)
			else
				T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
			qdel(src)

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
				qdel(src)
	else
		to_chat(user, "<span class='notice'>You can't reach, close it first!</span>")

	if( istype(W, /obj/item/weapon/pickaxe) )
		var/obj/item/weapon/pickaxe/used_pick = W
		if(!(used_pick.diggables & DIG_WALLS))
			return
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ChangeTurf(/turf/simulated/wall)
		else
			T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[mineral]"))
		if(mineral != "plasma")
			T = get_turf(src)
			T.attackby(W,user)
		qdel(src)

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	..()
	if(density)
		icon_state = "[mineral]0"
		src.relativewall()
	else
		icon_state = "[mineral]fwall_open"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
 * False R-Walls
 */

<<<<<<< HEAD
/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	walltype = "rwall"

/obj/structure/falsewall/reinforced/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	T.ChangeTurf(/turf/closed/wall/r_wall)
	if(delete)
		qdel(src)
	return T
=======
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

	// WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	canSmoothWith = "/turf/simulated/wall=0&/obj/structure/falsewall=0&/obj/structure/falserwall=0"

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
		set_opacity(0)
		opening = 0
	else
		opening = 1
		icon_state = "r_wall"
		flick("frwall_closing", src)
		density = 1
		sleep(15)
		set_opacity(1)
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
		to_chat(user, "<span class='warning'>You must wait until the door has stopped moving.</span>")
		return

	if(isscrewdriver(W))
		var/turf/T = get_turf(src)
		user.visible_message("[user] tightens some bolts on the r wall.", "You tighten the bolts on the wall.")
		T.ChangeTurf(/turf/simulated/wall/r_wall) //Why not make rwall?
		qdel(src)

	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT.remove_fuel(0,user) )
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/simulated/wall)
			T = get_turf(src)
			T.attackby(W,user)
			qdel(src)

	else if( istype(W, /obj/item/weapon/pickaxe) )
		var/obj/item/weapon/pickaxe/used_pick = W
		if(!(used_pick.diggables & DIG_WALLS))
			return
		var/turf/T = get_turf(src)
		T.ChangeTurf(/turf/simulated/wall)
		T = get_turf(src)
		T.attackby(W,user)
		qdel(src)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
<<<<<<< HEAD
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	mineral = "uranium"
	walltype = "uranium"
	var/active = null
	var/last_event = 0
	canSmoothWith = list(/obj/structure/falsewall/uranium, /turf/closed/wall/mineral/uranium)

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/attack_hand(mob/user)
=======
	icon_state = ""
	mineral = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user as mob)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
<<<<<<< HEAD
			radiation_pulse(get_turf(src), 0, 3, 15, 1)
			for(var/turf/closed/wall/mineral/uranium/T in orange(1,src))
=======
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3,src))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold"
	mineral = "gold"
	walltype = "gold"
	canSmoothWith = list(/obj/structure/falsewall/gold, /turf/closed/wall/mineral/gold)
=======
	icon_state = ""
	mineral = "gold"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
<<<<<<< HEAD
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver"
	mineral = "silver"
	walltype = "silver"
	canSmoothWith = list(/obj/structure/falsewall/silver, /turf/closed/wall/mineral/silver)
=======
	icon_state = ""
	mineral = "silver"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
<<<<<<< HEAD
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond"
	mineral = "diamond"
	walltype = "diamond"
	canSmoothWith = list(/obj/structure/falsewall/diamond, /turf/closed/wall/mineral/diamond)
=======
	icon_state = ""
	mineral = "diamond"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
<<<<<<< HEAD
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma"
	mineral = "plasma"
	walltype = "plasma"
	canSmoothWith = list(/obj/structure/falsewall/plasma, /turf/closed/wall/mineral/plasma)

/obj/structure/falsewall/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(W.is_hot() > 300)
		message_admins("Plasma falsewall ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma falsewall ignited by [key_name(user)] in ([x],[y],[z])")
		burnbabyburn()
	else
		return ..()

/obj/structure/falsewall/plasma/proc/burnbabyburn(user)
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	atmos_spawn_air("plasma=400;TEMP=1000")
	new /obj/structure/girder/displaced(loc)
	qdel(src)

/obj/structure/falsewall/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		burnbabyburn()

/obj/structure/falsewall/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium"
	mineral = "bananium"
	walltype = "bananium"
	canSmoothWith = list(/obj/structure/falsewall/clown, /turf/closed/wall/mineral/clown)


/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	mineral = "sandstone"
	walltype = "sandstone"
	canSmoothWith = list(/obj/structure/falsewall/sandstone, /turf/closed/wall/mineral/sandstone)

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood"
	mineral = "wood"
	walltype = "wood"
	canSmoothWith = list(/obj/structure/falsewall/wood, /turf/closed/wall/mineral/wood)

/obj/structure/falsewall/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron"
	mineral = "metal"
	walltype = "iron"
	canSmoothWith = list(/obj/structure/falsewall/iron, /turf/closed/wall/mineral/iron)

/obj/structure/falsewall/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor"
	mineral = "abductor"
	walltype = "abductor"
	canSmoothWith = list(/obj/structure/falsewall/abductor, /turf/closed/wall/mineral/abductor)

/obj/structure/falsewall/titanium
	name = "titanium wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle"
	mineral = "titanium"
	walltype = "shuttle"
	canSmoothWith = list(/turf/closed/wall/mineral/titanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock/, /turf/closed/wall/shuttle, /obj/structure/window/shuttle, /obj/structure/shuttle/engine, /obj/structure/shuttle/engine/heater, )

/obj/structure/falsewall/plastitanium
	name = "plastitanium wall"
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall3"
	mineral = "plastitanium"
	walltype = "syndieshuttle"
	smooth = SMOOTH_FALSE
=======
	icon_state = ""
	mineral = "plasma"

/obj/structure/falsewall/plastic
	name = "plastic wall"
	desc = "A wall made of colorful plastic blocks attached together."
	icon_state = ""
	mineral = "plastic"

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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
