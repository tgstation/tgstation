/datum/design/shard_interfacer
	name = "Shard Interfacer"
	desc = "Stick some Shards in and create a self-recharging power cell"
	id = "shard_interfacer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 100)
	build_path = /obj/item/shard_interfacer
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/obj/item/shard_interfacer
	name = "Shard Interfacer"
	desc = "Stick some Shards in and create a self-recharging power cell"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "shard_interfacer"

/obj/item/shard_interfacer/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/shard/gem))
		to_chat(user, "<span class='notice'>You connect [W] to the [name].</span>")
		var/obj/item/stock_parts/cell/high/gem/interfacer = new /obj/item/stock_parts/cell/high/gem
		qdel(src)
		qdel(W)
		user.put_in_hands(interfacer)
	else
		return ..()

/obj/item/stock_parts/cell/high/gem
	name = "Charged Shard Interfacer"
	desc = "A power cell utilizing a Shattered Gem."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "shard_battery"
	materials = list()
	rating = 5 //self-recharge makes these desirable
	self_recharge = 1 // Infused slime cores self-recharge, over time