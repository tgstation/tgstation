/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	flag = "energy"
	var/temperature = 100

/obj/item/projectile/temp/on_hit(atom/target, blocked = FALSE)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/M = target
		M.bodytemperature = temperature
	return TRUE

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400
