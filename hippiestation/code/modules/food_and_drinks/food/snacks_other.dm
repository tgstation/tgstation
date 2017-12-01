/obj/item/reagent_containers/food/snacks/neep_tatty_haggis
	name = "neep tatty haggis"
	desc = "Oi mate! No neeps, but double beets! SCAM!!!"
	icon_state = "neep_tatty_haggis"
	icon = 'hippiestation/icons/obj/food/food.dmi'
	bonus_reagents = list("nutriment" = 20, "vitamin" = 10, "iron" = 10)
	trash = /obj/item/trash/plate
	foodtype = GRAIN | VEGETABLES | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/taco/leg
	desc = "An untraditional taco with leg, cheese, and lettuce."
	icon = 'hippiestation/icons/obj/food/food.dmi'
	icon_state = "legtaco"
	bonus_reagents = list("nutriment" = 3, "vitamin" = 2)
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	filling_color = "F0D830"
	tastes = list("taco" = 2, "leg" = 4, "cheese" = 2, "lettuce" = 1)
	foodtype = MEAT | DAIRY | GRAIN | VEGETABLES | GROSS
