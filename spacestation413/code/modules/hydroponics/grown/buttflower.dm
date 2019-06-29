/obj/item/seeds/buttseed
	name = "pack of replica butt seeds"
	desc = "Replica butts...has science gone too far?"
	icon = 'icons/obj/hydroponics/seeds2.dmi'
	icon_state = "seed-butt"
	species = "butt"
	plantname = "Replica Butt Flower"
	product = /obj/item/reagent_containers/food/snacks/grown/shell/buttflower
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 1
	growing_icon = 'icons/obj/hydroponics/growing2.dmi'
	potency = 20
	growthstages = 3
	reagents_add = list("fartium" = 4)

/obj/item/reagent_containers/food/snacks/grown/shell/buttflower
	seed = /obj/item/seeds/buttseed
	icon = 'icons/obj/hydroponics/harvest2.dmi'
	name = "buttflower"
	desc = "Gives off a pungent aroma once it blooms."
	icon_state = "buttflower"
	trash = /obj/item/organ/butt 
