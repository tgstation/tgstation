/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = 1
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	var/mineral = /obj/item/stack/sheet/metal
	var/mineral_amount = 2
	var/walltype = /turf/closed/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = 0
	density = 1
	opacity = 1
	obj_integrity = 100
	max_integrity = 100

	canSmoothWith = list(
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork)
	smooth = SMOOTH_TRUE
	can_be_unanchored = 0
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/falsewall/New(loc)
	..()
	air_update_turf(1)

/obj/structure/falsewall/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/falsewall/ratvar_act()
	new /obj/structure/falsewall/brass(loc)
	qdel(src)

/obj/structure/falsewall/attack_hand(mob/user)
	if(opening)
		return

	opening = 1
	if(density)
		do_the_flick()
		sleep(5)
		if(!QDELETED(src))
			density = 0
			set_opacity(0)
			update_icon()
	else
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = 0
			return
		do_the_flick()
		density = 1
		sleep(5)
		if(!QDELETED(src))
			set_opacity(1)
			update_icon()
	air_update_turf(1)
	opening = 0

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
		icon_state = initial(icon_state)
	else
		icon_state = "fwall_open"

/obj/structure/falsewall/proc/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	T.ChangeTurf(walltype)
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/attackby(obj/item/weapon/W, mob/user, params)
	if(opening)
		to_chat(user, "<span class='warning'>You must wait until the door has stopped moving!</span>")
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(density)
			var/turf/T = get_turf(src)
			if(T.density)
				to_chat(user, "<span class='warning'>[src] is blocked!</span>")
				return
			if(!isfloorturf(T))
				to_chat(user, "<span class='warning'>[src] bolts must be tightened on the floor!</span>")
				return
			user.visible_message("<span class='notice'>[user] tightens some bolts on the wall.</span>", "<span class='notice'>You tighten the bolts on the wall.</span>")
			ChangeToWall()
		else
			to_chat(user, "<span class='warning'>You can't reach, close it first!</span>")

	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			dismantle(user, TRUE)
	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		dismantle(user, TRUE)
	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		D.playDigSound()
		dismantle(user, TRUE)
	else
		return ..()

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled = TRUE)
	user.visible_message("<span class='notice'>[user] dismantles the false wall.</span>", "<span class='notice'>You dismantle the false wall.</span>")
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	deconstruct(disassembled)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/obj/structure/falsewall/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/obj/structure/falsewall/examine_status(mob/user) //So you can't detect falsewalls by examine.
	return null

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	walltype = /turf/closed/wall/r_wall
	mineral = /obj/item/stack/sheet/plasteel

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/closed/wall/mineral/uranium
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
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/closed/wall/mineral/gold
	canSmoothWith = list(/obj/structure/falsewall/gold, /turf/closed/wall/mineral/gold)

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver"
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/closed/wall/mineral/silver
	canSmoothWith = list(/obj/structure/falsewall/silver, /turf/closed/wall/mineral/silver)

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond"
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/closed/wall/mineral/diamond
	canSmoothWith = list(/obj/structure/falsewall/diamond, /turf/closed/wall/mineral/diamond)
	obj_integrity = 800
	max_integrity = 800

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma"
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/closed/wall/mineral/plasma
	canSmoothWith = list(/obj/structure/falsewall/plasma, /turf/closed/wall/mineral/plasma)

/obj/structure/falsewall/plasma/attackby(obj/item/weapon/W, mob/user, params)
	if(W.is_hot() > 300)
		var/turf/T = get_turf(src)
		message_admins("Plasma falsewall ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(T)]",0,1)
		log_game("Plasma falsewall ignited by [key_name(user)] in [COORD(T)]")
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
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/closed/wall/mineral/clown
	canSmoothWith = list(/obj/structure/falsewall/clown, /turf/closed/wall/mineral/clown)


/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/sandstone
	canSmoothWith = list(/obj/structure/falsewall/sandstone, /turf/closed/wall/mineral/sandstone)

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood"
	mineral = /obj/item/stack/sheet/mineral/wood
	walltype = /turf/closed/wall/mineral/wood
	canSmoothWith = list(/obj/structure/falsewall/wood, /turf/closed/wall/mineral/wood)

/obj/structure/falsewall/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron"
	mineral = /obj/item/stack/rods
	walltype = /turf/closed/wall/mineral/iron
	canSmoothWith = list(/obj/structure/falsewall/iron, /turf/closed/wall/mineral/iron)

/obj/structure/falsewall/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor"
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/closed/wall/mineral/abductor
	canSmoothWith = list(/obj/structure/falsewall/abductor, /turf/closed/wall/mineral/abductor)

/obj/structure/falsewall/titanium
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle"
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/closed/wall/mineral/titanium
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/wall/mineral/titanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock/, /turf/closed/wall/shuttle, /obj/structure/window/shuttle, /obj/structure/shuttle/engine, /obj/structure/shuttle/engine/heater, )

/obj/structure/falsewall/plastitanium
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall3"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/closed/wall/mineral/plastitanium
	smooth = SMOOTH_FALSE

/obj/structure/falsewall/brass
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mineral_amount = 1
	canSmoothWith = list(/obj/effect/clockwork/overlay/wall, /obj/structure/falsewall/brass)
	girder_type = /obj/structure/destructible/clockwork/wall_gear/displaced
	walltype = /turf/closed/wall/clockwork
	mineral = /obj/item/stack/tile/brass

/obj/structure/falsewall/brass/New(loc)
	..()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/ratvar/wall/false(T)
	new /obj/effect/temp_visual/ratvar/beam/falsewall(T)
	change_construction_value(4)

/obj/structure/falsewall/brass/Destroy()
	change_construction_value(-4)
	return ..()

/obj/structure/falsewall/brass/ratvar_act()
	if(GLOB.ratvar_awakens)
		obj_integrity = max_integrity
