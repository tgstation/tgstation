/*
 * False Walls
 */
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

/*
 * False R-Walls
 */

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

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
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
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			radiation_pulse(get_turf(src), 0, 3, 15, 1)
			for(var/turf/closed/wall/mineral/uranium/T in orange(1,src))
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
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold"
	mineral = "gold"
	walltype = "gold"
	canSmoothWith = list(/obj/structure/falsewall/gold, /turf/closed/wall/mineral/gold)

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver"
	mineral = "silver"
	walltype = "silver"
	canSmoothWith = list(/obj/structure/falsewall/silver, /turf/closed/wall/mineral/silver)

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond"
	mineral = "diamond"
	walltype = "diamond"
	canSmoothWith = list(/obj/structure/falsewall/diamond, /turf/closed/wall/mineral/diamond)

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
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