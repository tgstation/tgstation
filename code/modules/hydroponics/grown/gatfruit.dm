
// Gatfruit
/obj/item/seeds/gatfruit
	name = "gatfruit seed pack"
	desc = "These seeds grow into pea-shooting revolvers."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "Gatfruit Tree"
	product = /obj/item/food/grown/gatfruit
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	rarity = 60 // Obtainable only with xenobio+superluck.
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	reagents_add = list(/datum/reagent/sulfur = 0.1, /datum/reagent/carbon = 0.1, /datum/reagent/nitrogen = 0.07, /datum/reagent/potassium = 0.05, /datum/reagent/toxin/gatfruit = 0.3)

/obj/item/food/grown/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning gunpowder."
	icon_state = "gatfruit"
	trash_type = /obj/item/gun/ballistic/revolver/peashooter
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("gunpowder" = 1)
	wine_power = 90 //It burns going down, too.

/obj/item/food/grown/gatfruit/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	reagents.flags &= ~INJECTABLE //id rather not have this be filled with initropidril without effort

/obj/item/food/grown/gatfruit/generate_trash(atom/location)
	//if you set this to anything but the revolver i will find you... and... downvote your pr...
	var/obj/item/gun/ballistic/revolver/peashooter/gun = new trash_type(location || drop_location())
	var/potency_percentage = CLAMP01(seed.potency / 100)
	var/amount_to_trans = reagents.total_volume / gun.magazine.max_ammo
	for(var/obj/item/ammo_casing/pea/casing as anything in gun.magazine.ammo_list())
		casing.damage = floor(max(5, LERP(5, casing.max_damage, potency_percentage)))
		if(reagents.total_volume)
			reagents.trans_to(casing, amount_to_trans)
	return gun

