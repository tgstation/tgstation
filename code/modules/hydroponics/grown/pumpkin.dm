// Pumpkin
/obj/item/seeds/pumpkin
	name = "pumpkin seed pack"
	desc = "These seeds grow into pumpkin vines."
	icon_state = "seed-pumpkin"
	plant_icon_offset = 4
	species = "pumpkin"
	plantname = "Pumpkin Vines"
	product = /obj/item/food/grown/pumpkin
	lifespan = 50
	endurance = 40
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "pumpkin-grow"
	icon_dead = "pumpkin-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/pumpkin/blumpkin)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/food/grown/pumpkin
	seed = /obj/item/seeds/pumpkin
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/pumpkinjuice
	wine_power = 20
	///Which type of lantern this gourd produces when carved.
	var/carved_type = /obj/item/clothing/head/utility/hardhat/pumpkinhead

/obj/item/food/grown/pumpkin/attackby(obj/item/W as obj, mob/user as mob, list/modifiers, list/attack_modifiers)
	if(W.get_sharpness())
		user.show_message(span_notice("You carve a face into [src]!"), MSG_VISUAL)
		new carved_type(user.loc)
		qdel(src)
		return
	else
		return ..()

// Blumpkin
/obj/item/seeds/pumpkin/blumpkin
	name = "blumpkin seed pack"
	desc = "These seeds grow into blumpkin vines."
	icon_state = "seed-blumpkin"
	species = "blumpkin"
	plantname = "Blumpkin Vines"
	product = /obj/item/food/grown/pumpkin/blumpkin
	mutatelist = null
	reagents_add = list(/datum/reagent/ammonia = 0.2, /datum/reagent/chlorine = 0.1, /datum/reagent/consumable/nutriment = 0.2)
	rarity = PLANT_MODERATELY_RARE

/obj/item/food/grown/pumpkin/blumpkin
	seed = /obj/item/seeds/pumpkin/blumpkin
	name = "blumpkin"
	desc = "The pumpkin's toxic sibling."
	icon_state = "blumpkin"
	bite_consumption_mod = 3
	juice_typepath = /datum/reagent/consumable/blumpkinjuice
	wine_power = 50
	carved_type = /obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin
