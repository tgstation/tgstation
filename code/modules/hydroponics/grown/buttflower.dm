/*//Buttflower
/obj/item/seeds/buttseed
	name = "pack of replica butt seeds"
	desc = "Replica butts...has science gone too far?"
	icon_state = "seed-butt"
	species = "butt"
	plantname = "Replica Butt Flower"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/buttflower
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 1
	potency = 20
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = /obj/item/seeds/berry
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	gender = PLURAL
	filling_color = "#FF00FF"
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/buttflower
	seed = /obj/item/seeds/buttseed
	name = "buttflower"
	desc = "Gives off a pungent aroma once it blooms."
	icon_state = "buttflower" //coder spriting ftw
	trash = /obj/item/organ/internal/butt

/obj/item/weapon/reagent_containers/food/snacks/grown/buttflower/add_juice()
	if(..())
		reagents.add_reagent("fartium", 1 + round((potency / 10), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

	*/