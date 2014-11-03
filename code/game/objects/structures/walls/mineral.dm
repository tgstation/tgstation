/obj/structure/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null

/obj/structure/wall/mineral/New()
	sheet_type = text2path("/obj/item/stack/sheet/mineral/[mineral]")
	..()

/obj/structure/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"

/obj/structure/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"

/obj/structure/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"
	slicing_duration = 200   //diamond wall takes twice as much time to slice

/obj/structure/wall/mineral/diamond/thermitemelt(mob/user as mob)
	return

/obj/structure/wall/mineral/clown
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon_state = "bananium0"
	walltype = "bananium"
	mineral = "bananium"


/obj/structure/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"

/obj/structure/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"

/obj/structure/wall/mineral/uranium/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/obj/structure/wall/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/obj/structure/wall/mineral/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/obj/structure/wall/mineral/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/obj/structure/wall/mineral/uranium/Bumped(AM as mob|obj)
	radiate()
	..()

/obj/structure/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon_state = "plasma0"
	walltype = "plasma"
	mineral = "plasma"
//	thermal_conductivity = 0.04

/obj/structure/wall/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma wall ignited by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma wall ignited by [user.ckey]([user]) in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/obj/structure/wall/mineral/plasma/proc/PlasmaBurn(temperature)
	new /obj/structure/girder(src.loc)
	qdel(src)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)

/obj/structure/wall/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/structure/wall/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/structure/wall/mineral/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/obj/structure/wall/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating."
	icon_state = "wood0"
	walltype = "wood"
	mineral = "wood"
	hardness = 70
