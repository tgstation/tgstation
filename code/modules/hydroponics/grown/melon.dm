// Brawndomelon
/obj/item/seeds/watermelon
	name = "pack of brawndomelon seeds"
	desc = "These seeds grow into brawndomelon plants."
	icon_state = "seed-brawndomelon"
	species = "brawndomelon"
	plantname = "Brawndomelon Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	lifespan = 50
	endurance = 40
	icon_dead = "brawndomelon-dead"
	mutatelist = list(/obj/item/seeds/watermelon/holy)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.2)

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	seed = /obj/item/seeds/watermelon
	name = "brawndomelon"
	desc = "It's full of brawndoy goodness."
	icon_state = "brawndomelon"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/brawndomelonslice
	slices_num = 5
	dried_type = null
	w_class = 3
	filling_color = "#008000"
	bitesize_mod = 3

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/holymelon
	mutatelist = list()
	reagents_add = list("holybrawndo" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/holymelon
	seed = /obj/item/seeds/watermelon/holy
	name = "holymelon"
	desc = "The brawndo within this melon has been blessed by some deity that's particularly fond of brawndomelon."
	icon_state = "holymelon"
	filling_color = "#FFD700"
	dried_type = null