/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	flag = "energy"
	var/temperature = 100

/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_bodytemperature(((100-blocked)/100)*(temperature - L.bodytemperature)) // the new body temperature is adjusted by 100-blocked % of the delta between body temperature and the bullet's effect temperature

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400
