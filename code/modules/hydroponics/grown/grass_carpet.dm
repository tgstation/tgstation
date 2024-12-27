// Grass
/obj/item/seeds/grass
	name = "grass seed pack"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	product = /obj/item/food/grown/grass
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	instability = 10
	growthstages = 2
	icon_grow = "grass-grow"
	icon_dead = "grass-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/grass/carpet, /obj/item/seeds/grass/fairy)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/hydrogen = 0.05)

/obj/item/food/grown/grass
	seed = /obj/item/seeds/grass
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	bite_consumption_mod = 0.5 // Grazing on grass
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50
	wine_power = 15

/obj/item/food/grown/grass/attack_self(mob/user)
	to_chat(user, span_notice("You prepare the astroturf."))
	var/grassAmt = 1 + round(seed.potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/food/grown/grass/G in user.loc) // The grass on the floor
		if(G.type != type)
			continue
		grassAmt += 1 + round(G.seed.potency * tile_coefficient)
		qdel(G)
	new stacktype(user.drop_location(), grassAmt)
	qdel(src)

//Fairygrass
/obj/item/seeds/grass/fairy
	name = "fairygrass seed pack"
	desc = "These seeds grow into a more mystical grass."
	icon_state = "seed-fairygrass"
	species = "fairygrass"
	plantname = "Fairygrass"
	product = /obj/item/food/grown/grass/fairy
	icon_grow = "fairygrass-grow"
	icon_dead = "fairygrass-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/blue)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/hydrogen = 0.05, /datum/reagent/drug/space_drugs = 0.15)
	graft_gene = /datum/plant_gene/trait/glow/blue
	mutatelist = null

/obj/item/food/grown/grass/fairy
	seed = /obj/item/seeds/grass/fairy
	name = "fairygrass"
	desc = "Blue, glowing, and smells fainly of mushrooms."
	icon_state = "fairygrassclump"
	bite_consumption_mod = 1
	stacktype = /obj/item/stack/tile/fairygrass

// Carpet
/obj/item/seeds/grass/carpet
	name = "carpet seed pack"
	desc = "These seeds grow into stylish carpet samples."
	icon_state = "seed-carpet"
	species = "carpet"
	plantname = "Carpet"
	product = /obj/item/food/grown/grass/carpet
	mutatelist = null
	rarity = 10

/obj/item/food/grown/grass/carpet
	seed = /obj/item/seeds/grass/carpet
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"
	stacktype = /obj/item/stack/tile/carpet
	can_distill = FALSE
