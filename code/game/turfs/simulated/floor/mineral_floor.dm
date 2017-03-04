/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 * Shuttle floor (Titanium)
 */

/turf/open/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons



/turf/open/floor/mineral/Initialize()
	broken_states = list("[initial(icon_state)]_dam")
	..()
	if (!icons)
		icons = list()


/turf/open/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

//PLASMA

/turf/open/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")

/turf/open/floor/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn()

/turf/open/floor/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma flooring was ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma flooring was ignited by [key_name(user)] in ([x],[y],[z])")
		ignite(W.is_hot())
		return
	..()

/turf/open/floor/mineral/plasma/proc/PlasmaBurn()
	make_plating()
	atmos_spawn_air("plasma=20;TEMP=1000")

/turf/open/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn()


//GOLD

/turf/open/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")

//SILVER

/turf/open/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")

//TITANIUM (shuttle)

/turf/open/floor/mineral/titanium/blue
	icon_state = "shuttlefloor"
	icons = list("shuttlefloor","shuttlefloor_dam")

/turf/open/floor/mineral/titanium/blue/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/mineral/titanium/yellow
	icon_state = "shuttlefloor2"
	icons = list("shuttlefloor2","shuttlefloor2_dam")

/turf/open/floor/mineral/titanium/yellow/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "shuttlefloor3"
	floor_tile = /obj/item/stack/tile/mineral/titanium
	icons = list("shuttlefloor3","shuttlefloor3_dam")

/turf/open/floor/mineral/titanium/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/mineral/titanium/purple
	icon_state = "shuttlefloor5"
	icons = list("shuttlefloor5","shuttlefloor5_dam")

/turf/open/floor/mineral/titanium/purple/airless
	initial_gas_mix = "TEMP=2.7"

//PLASTITANIUM (syndieshuttle)
/turf/open/floor/mineral/plastitanium
	name = "shuttle floor"
	icon_state = "shuttlefloor4"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium
	icons = list("shuttlefloor4","shuttlefloor4_dam")

/turf/open/floor/mineral/plastitanium/brig
	name = "Brig floor"

//BANANIUM

/turf/open/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")
	var/spam_flag = 0

/turf/open/floor/mineral/bananium/Entered(var/mob/AM)
	.=..()
	if(!.)
		if(istype(AM))
			squeek()

/turf/open/floor/mineral/bananium/attackby(obj/item/weapon/W, mob/user, params)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/attack_hand(mob/user)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/attack_paw(mob/user)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/turf/open/floor/mineral/bananium/proc/squeek()
	if(!spam_flag)
		spam_flag = 1
		playsound(src, "clownstep", 50, 1)
		spawn(10)
			spam_flag = 0

/turf/open/floor/mineral/bananium/airless
	initial_gas_mix = "TEMP=2.7"

//DIAMOND

/turf/open/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")

//URANIUM

/turf/open/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")
	var/last_event = 0
	var/active = null

/turf/open/floor/mineral/uranium/Entered(var/mob/AM)
	.=..()
	if(!.)
		if(istype(AM))
			radiate()

/turf/open/floor/mineral/uranium/attackby(obj/item/weapon/W, mob/user, params)
	.=..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/attack_hand(mob/user)
	.=..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/attack_paw(mob/user)
	.=..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			radiation_pulse(get_turf(src), 3, 3, 1, 0)
			for(var/turf/open/floor/mineral/uranium/T in orange(1,src))
				T.radiate()
			last_event = world.time
			active = 0
			return

// ALIEN ALLOY
/turf/open/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")

/turf/open/floor/mineral/abductor/Initialize()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/open/floor/mineral/abductor/break_tile()
	return //unbreakable

/turf/open/floor/mineral/abductor/burn_tile()
	return //unburnable

/turf/open/floor/mineral/abductor/make_plating()
	return ChangeTurf(/turf/open/floor/plating/abductor2)
