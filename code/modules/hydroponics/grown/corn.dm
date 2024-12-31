// Corn
/obj/item/seeds/corn
	name = "corn seed pack"
	desc = "I don't mean to sound corny..."
	icon_state = "seed-corn"
	species = "corn"
	plantname = "Corn Stalks"
	product = /obj/item/food/grown/corn
	maturation = 8
	potency = 20
	instability = 50 //Corn used to be wheatgrass, before being cultivated for generations.
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing_vegetables.dmi'
	icon_grow = "corn-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "corn-dead" // Same for the dead icon
	mutatelist = list(/obj/item/seeds/corn/snapcorn, /obj/item/seeds/corn/pepper)
	reagents_add = list(/datum/reagent/consumable/nutriment/fat/oil/corn = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/corn
	seed = /obj/item/seeds/corn
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	trash_type = /obj/item/grown/corncob
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/cornmeal = 0, /datum/reagent/consumable/nutriment/fat/oil/corn = 0)
	juice_typepath = /datum/reagent/consumable/corn_starch
	tastes = list("corn" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/whiskey

/obj/item/food/grown/corn/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/oven_baked_corn, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/grown/corn/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/popcorn)

/obj/item/grown/corncob
	seed = /obj/item/seeds/corn
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon_state = "corncob"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	grind_results = list(/datum/reagent/cellulose = 10) //really partially hemicellulose

/obj/item/grown/corncob/attackby(obj/item/grown/W, mob/user, params)
	if(W.get_sharpness())
		to_chat(user, span_notice("You use [W] to fashion a pipe out of the corn cob!"))
		new /obj/item/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
	else
		return ..()

// Snapcorn
/obj/item/seeds/corn/snapcorn
	name = "snapcorn seed pack"
	desc = "Oh snap!"
	icon_state = "seed-snapcorn"
	species = "snapcorn"
	plantname = "Snapcorn Stalks"
	product = /obj/item/grown/snapcorn
	mutatelist = null
	rarity = 10

/obj/item/grown/snapcorn
	seed = /obj/item/seeds/corn/snapcorn
	name = "snap corn"
	desc = "A cob with snap pops."
	icon_state = "snapcorn"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/snap_pops = 1

/obj/item/grown/snapcorn/add_juice()
	..()
	snap_pops = max(round(seed.potency/8), 1)

/obj/item/grown/snapcorn/attack_self(mob/user)
	..()
	to_chat(user, span_notice("You pick a snap pop from the cob."))
	var/obj/item/toy/snappop/S = new /obj/item/toy/snappop(user.loc)
	if(ishuman(user))
		user.put_in_hands(S)
	snap_pops -= 1
	if(!snap_pops)
		new /obj/item/grown/corncob/snap(user.loc)
		qdel(src)

/obj/item/grown/corncob/snap
	seed = /obj/item/seeds/corn/snapcorn
	name = "snap corn cob"
	desc = "A reminder of pranks gone by."

//Pepper-corn - Heh funny.
/obj/item/seeds/corn/pepper
	name = "pepper-corn seed pack"
	desc = "If Peter picked a pack of pepper-corn..."
	icon_state = "seed-peppercorn"
	species = "peppercorn"
	plantname = "Pepper-Corn Stalks"
	product = /obj/item/food/grown/peppercorn
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/blackpepper = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/peppercorn
	seed = /obj/item/seeds/corn/pepper
	name = "ear of pepper-peppercorn"
	desc = "This dusty monster needs god..."
	icon_state = "peppercorn"
	trash_type = /obj/item/grown/corncob/pepper
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/blackpepper = 0)
	tastes = list("pepper" = 1, "sneezing" = 1)

/obj/item/grown/corncob/pepper
	seed = /obj/item/seeds/corn/pepper
	name = "pepper corn cob"
	desc = "A reminder of genetic abominations gone by."
