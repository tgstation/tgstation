


/obj/item/weapon/grenade/gas
	name = "Plasma Fire Grenade"
	desc = "A compressed plasma grenade, used to start horrific plasma fires."
	origin_tech = "materials=3;magnets=4;syndicate=4"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	var/spawn_contents = "plasma=100;TEMP=1000"

/obj/item/weapon/grenade/gas/prime()
	var/turf/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(spawn_contents)
		target_turf.air_update_turf()
	qdel(src)

/obj/item/weapon/grenade/gas/knockout
	name = "Knockout Grenade"
	desc = "A grenade that floods the area with nitrous oxide, putting everyone to sleep."
	spawn_contents = "n2o=100;TEMP=293.15"

/obj/item/weapon/grenade/gas/freeze
	name = "Freon Grenade"
	desc = "A grenade which freezes over everything near its detonation area."
	spawn_contents = "freon=100;TEMP=120"