/datum/shipping/plants
	name = "Plants"
	value = 50
	sell_type = /obj/item/weapon/reagent_containers/food/snacks/grown

/datum/shipping/seeds
	name = "Seeds"
	value = 200
	sell_type = /obj/item/seeds

/datum/shipping/seeds/ship_obj(var/atom/movable/AM)
	if(istype(AM, /obj/item/seeds))
		var/obj/item/seeds/S = AM
		SSshuttle.points += value * (S.potency / 10)
		profit_made_total += value * (S.potency / 10)
		profit_made += value * (S.potency / 10)
		amount_sold++
		amount_sold_total++
		if(prob(25))
			lower_value(rand(3, 1))