/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	anchored = 1
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	var/walltype = "metal"
	var/opening = 0
	density = 1
	opacity = 1

	canSmoothWith = list(
	/turf/simulated/wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/reinforced  // WHY DO WE SMOOTH WITH FALSE R-WALLS WHEN WE DON'T SMOOTH WITH REAL R-WALLS.
	)


/obj/structure/falsewall/New()
	..()
	relativewall_neighbours()

/obj/structure/falsewall/Destroy()

	var/temploc = loc
	loc = null

	for(var/turf/simulated/wall/W in range(temploc,1))
		W.relativewall()

	for(var/obj/structure/falsewall/W in range(temploc,1))
		W.relativewall()
	..()


/obj/structure/falsewall/relativewall()

	if(!density)
		icon_state = "[walltype]fwall_open"
		return

	var/junction = findSmoothingNeighbors()
	icon_state = "[walltype][junction]"
	return

/obj/structure/falsewall/attack_hand(mob/user)
	if(opening)
		return

	opening = 1
	if(density)
		do_the_flick()
		sleep(4)
		density = 0
		SetOpacity(0)
		update_icon(0)
	else
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = 0
			return
		do_the_flick()
		density = 1
		sleep(4)
		SetOpacity(1)
		update_icon()
	opening = 0

/obj/structure/falsewall/proc/do_the_flick()
	if(density)
		flick("[walltype]fwall_opening", src)
	else
		flick("[walltype]fwall_closing", src)

/obj/structure/falsewall/update_icon(relativewall = 1)//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	if(density)
		icon_state = "[walltype]0"
		if(relativewall)
			relativewall()
	else
		icon_state = "[walltype]fwall_open"

/obj/structure/falsewall/proc/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	if(!walltype || walltype == "metal")
		T.ChangeTurf(/turf/simulated/wall)
	else
		T.ChangeTurf(text2path("/turf/simulated/wall/mineral/[walltype]"))
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/attackby(obj/item/weapon/W, mob/user, params)
	if(opening)
		user << "<span class='warning'>You must wait until the door has stopped moving!</span>"
		return

	if(density)
		var/turf/T = get_turf(src)
		if(T.density)
			user << "<span class='warning'>[src] is blocked!</span>"
			return
		if(istype(W, /obj/item/weapon/screwdriver))
			if (!istype(T, /turf/simulated/floor))
				user << "<span class='warning'>[src] bolts must be tightened on the floor!</span>"
				return
			user.visible_message("<span class='notice'>[user] tightens some bolts on the wall.</span>", "<span class='notice'>You tighten the bolts on the wall.</span>")
			ChangeToWall()
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				dismantle(user)
	else
		user << "<span class='warning'>You can't reach, close it first!</span>"

	if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		dismantle(user)

	if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		D.playDigSound()
		dismantle(user)

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

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	walltype = "rwall"

/obj/structure/falsewall/reinforced/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	T.ChangeTurf(/turf/simulated/wall/r_wall)
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/reinforced/do_the_flick()
	if(density)
		flick("frwall_opening", src)
	else
		flick("frwall_closing", src)

/obj/structure/falsewall/reinforced/update_icon(relativewall = 1)
	if(density)
		icon_state = "rwall0"
		src.relativewall()
	else
		icon_state = "frwall_open"

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = ""
	mineral = "uranium"
	walltype = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W, mob/user, params)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.irradiate(4)
			for(var/turf/simulated/wall/mineral/uranium/T in orange(1,src))
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
	walltype = "gold"

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon_state = ""
	mineral = "silver"
	walltype = "silver"

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = ""
	mineral = "diamond"
	walltype = "diamond"

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = ""
	mineral = "plasma"
	walltype = "plasma"

/obj/structure/falsewall/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(is_hot(W) > 300)
		message_admins("Plasma falsewall ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma falsewall ignited by [key_name(user)] in ([x],[y],[z])")
		burnbabyburn()
		return
	..()

/obj/structure/falsewall/plasma/proc/burnbabyburn(user)
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)
	new /obj/structure/girder/displaced(loc)
	qdel(src)

/obj/structure/falsewall/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		burnbabyburn()

//-----------wtf?-----------start
/obj/structure/falsewall/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = ""
	mineral = "bananium"
	walltype = "bananium"


/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = ""
	mineral = "sandstone"
	walltype = "sandstone"
//------------wtf?------------end

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating."
	icon_state = ""
	mineral = "wood"
	walltype = "wood"
