/*
 * False Walls
 */
/obj/structure/wall/false
	var/opening = 0

/obj/structure/wall/false/Destroy()
	var/temploc = loc
	loc = null

	for(var/obj/structure/wall/W in range(temploc,1))
		W.relativewall()
	..()

/obj/structure/wall/false/relativewall()
	if(!density)
		icon_state = "[mineral]fwall_open"
		return
	..()

/obj/structure/wall/false/attack_hand(mob/user)
	if(opening)
		return

	opening = 1
	if(density)
		do_the_flick()
		sleep(4)
		density = 0
		SetOpacity(0)
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

/obj/structure/wall/update_icon()
	relativewall()

/obj/structure/wall/false/proc/do_the_flick()
	if(density)
		flick("[mineral]fwall_opening", src)
	else
		flick("[mineral]fwall_closing", src)

/obj/structure/wall/false/proc/ChangeToWall()
	new /obj/structure/wall(loc)
	qdel(src)

/obj/structure/wall/false/attackby(obj/item/weapon/W, mob/user)
	if(opening)
		user << "<span class='warning'>You must wait until the door has stopped moving.</span>"
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
			user.visible_message("<span class='notice'>[user] tightens some bolts on the wall.</span>", "<span class='warning'>You tighten the bolts on the wall.</span>")
			ChangeToWall()
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				dismantle(user)
	else
		user << "<span class='warning'>You can't reach, close it first!</span>"

	if(istype(W, /obj/item/weapon/pickaxe/plasmacutter) || istype(W, /obj/item/weapon/pickaxe/diamonddrill) || istype(W, /obj/item/weapon/melee/energy/blade))
		dismantle(user)

/obj/structure/wall/false/proc/dismantle(mob/user)
	user.visible_message("<span class='notice'>[user] dismantles the false wall.</span>", "<span class='warning'>You dismantle the false wall.</span>")
	new /obj/structure/girder/displaced(loc)
	if(mineral == "metal")
		if(istype(src, /obj/structure/wall/false/reinforced))
			new /obj/item/stack/sheet/plasteel(loc, 2)
		else
			new /obj/item/stack/sheet/metal(loc, 2)
	else
		var/P = text2path("/obj/item/stack/sheet/mineral/[mineral]")
		new P(loc, 2)
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	qdel(src)

/*
 * False R-Walls
 */

/obj/structure/wall/false/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	walltype = "rwall"

/obj/structure/wall/false/reinforced/ChangeToWall()
	new /obj/structure/wall/r_wall(loc)
	qdel(src)

/obj/structure/wall/false/reinforced/do_the_flick()
	if(density)
		flick("frwall_opening", src)
	else
		flick("frwall_closing", src)

/obj/structure/wall/false/reinforced/update_icon()
	if(density)
		icon_state = "rwall0"
		relativewall()
	else
		icon_state = "frwall_open"



/obj/structure/wall/false/mineral/ChangeToWall()
	var/wallname = text2path("/obj/structure/wall/mineral/[mineral]")
	new wallname(loc)
	qdel(src)

/*
 * Uranium Falsewalls
 */

/obj/structure/wall/false/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = ""
	mineral = "uranium"
	walltype = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/wall/false/mineral/uranium/attackby(obj/item/weapon/W, mob/user)
	radiate()
	..()

/obj/structure/wall/false/mineral/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/wall/false/mineral/uranium/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/obj/structure/wall/W in range(3,src))
				W.radiate()
			last_event = world.time
			active = null
			return
	return
/*
 * Other misc falsewall types
 */

/obj/structure/wall/false/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = ""
	mineral = "gold"
	walltype = "gold"

/obj/structure/wall/false/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon_state = ""
	mineral = "silver"
	walltype = "silver"

/obj/structure/wall/false/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = ""
	mineral = "diamond"
	walltype = "diamond"

/obj/structure/wall/false/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = ""
	mineral = "plasma"
	walltype = "plasma"

/obj/structure/wall/false/mineral/plasma/attackby(obj/item/weapon/W, mob/user)
	if(is_hot(W) > 300)
		message_admins("Plasma falsewall ignited by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma falsewall ignited by [user.ckey]([user]) in ([x],[y],[z])")
		burnbabyburn()
		return
	..()

/obj/structure/wall/false/mineral/plasma/proc/burnbabyburn(user)
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)
	new /obj/structure/girder/displaced(loc)
	qdel(src)

/obj/structure/wall/false/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		burnbabyburn()

/obj/structure/wall/false/mineral/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = ""
	mineral = "bananium"
	walltype = "bananium"

/obj/structure/wall/false/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = ""
	mineral = "sandstone"
	walltype = "sandstone"

/obj/structure/wall/false/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating."
	icon_state = ""
	mineral = "wood"
	walltype = "wood"
