// Grass
/obj/item/seeds/grass
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/grass
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	growthstages = 2
	icon_grow = "grass-grow"
	icon_dead = "grass-dead"
	mutatelist = list(/obj/item/seeds/grass/carpet)
	reagents_add = list("nutriment" = 0.02, "hydrogen" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	seed = /obj/item/seeds/grass
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	filling_color = "#32CD32"
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/grass/attack_self(mob/user)
	user << "<span class='notice'>You prepare the astroturf.</span>"
	var/grassAmt = 1 + round(seed.potency / 50) // The grass we're holding
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/grass/G in user.loc) // The grass on the floor
		grassAmt += 1 + round(G.seed.potency)
		qdel(G)
	while(grassAmt > 0)
		var/obj/item/stack/tile/GT = new /obj/item/stack/tile/grass(user.loc)
		if(grassAmt >= GT.max_amount)
			GT.amount = GT.max_amount
		else
			GT.amount = grassAmt
			for(var/obj/item/stack/tile/grass/GR in user.loc)
				if(GR != GT && GR.amount < GR.max_amount)
					GR.attackby(GT, user) //we try to transfer all old unfinished stacks to the new stack we created.
		grassAmt -= GT.max_amount
	qdel(src)
	return

// Carpet
/obj/item/seeds/grass/carpet
	name = "pack of carpet seeds"
	desc = "These seeds grow into stylish carpet samples."
	icon_state = "seed-carpet"
	species = "carpet"
	plantname = "Carpet"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/carpet
	mutatelist = list(/obj/item/seeds/grass/carpet)
	rarity = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/carpet
	seed = /obj/item/seeds/grass/carpet
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"

/obj/item/weapon/reagent_containers/food/snacks/grown/carpet/attack_self(mob/user)
	user << "<span class='notice'>You roll out the red carpet.</span>"
	var/carpetAmt = 1 + round(seed.potency / 50) // The carpet we're holding
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/carpet/C in user.loc) // The carpet on the floor
		carpetAmt += 1 + round(C.seed.potency / 50)
		qdel(C)
	while(carpetAmt > 0)
		var/obj/item/stack/tile/CT = new /obj/item/stack/tile/carpet(user.loc)
		if(carpetAmt >= CT.max_amount)
			CT.amount = CT.max_amount
		else
			CT.amount = carpetAmt
			for(var/obj/item/stack/tile/carpet/CA in user.loc)
				if(CA != CT && CA.amount < CA.max_amount)
					CA.attackby(CT, user) //we try to transfer all old unfinished stacks to the new stack we created.
		carpetAmt -= CT.max_amount
	qdel(src)
	return
