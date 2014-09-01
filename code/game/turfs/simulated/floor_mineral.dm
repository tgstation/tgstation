
/turf/simulated/floor/mineral
	name = "mineral floor"
	desc = "Yell at firecage if this somehow exists."
	icon_state = ""
	var/last_event = 0
	var/active = null

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	mineral = "plasma"
	floortype = "plasma"
	floor_tile = new/obj/item/stack/tile/mineral/plasma

/turf/simulated/floor/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma floor ignited by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma floor ignited by [user.ckey]([user]) in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/turf/simulated/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/floor/mineral/plasma/proc/PlasmaBurn(temperature)
	spawn(2)
	src.ChangeTurf(/turf/simulated/floor/plating)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	mineral = "gold"
	floortype = "gold"
	floor_tile = new/obj/item/stack/tile/mineral/gold

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	mineral = "silver"
	floortype = "silver"
	floor_tile = new/obj/item/stack/tile/mineral/silver

/turf/simulated/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	mineral = "clown"
	floortype = "clown"
	floor_tile = new/obj/item/stack/tile/mineral/bananium

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	mineral = "diamond"
	floortype = "diamond"
	floor_tile = new/obj/item/stack/tile/mineral/diamond

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	mineral = "uranium"
	floortype = "uranium"
	floor_tile = new/obj/item/stack/tile/mineral/uranium

/turf/simulated/floor/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/floor/mineral/uranium/T in range(3,src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/simulated/floor/mineral/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/turf/simulated/floor/mineral/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/turf/simulated/floor/mineral/uranium/Entered(AM as mob|obj)
	if(AM)
		radiate()
		..()