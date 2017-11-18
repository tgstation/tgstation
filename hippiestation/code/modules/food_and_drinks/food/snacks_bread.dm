/obj/item/reagent_containers/food/snacks/store/bread/haggis
	name = "haggis"
	desc = "A savoury pudding containing intestines."
	icon = 'hippiestation/icons/obj/food/food.dmi'
	icon_state = "haggis"
	list_reagents = list("nutriment" = 50, "vitamin" = 25)
	tastes = list("scottish" = 5)
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/haggis
	foodtype = MEAT | GROSS | GRAIN

/obj/item/reagent_containers/food/snacks/breadslice/haggis
	name = "haggis chunk"
	desc = "A chunk of delicious(?) haggis."
	icon = 'hippiestation/icons/obj/food/food.dmi'
	icon_state = "haggis_chunk"
	list_reagents = list("nutriment" = 10, "vitamin" = 5)
	trash = /obj/item/trash/plate
	foodtype = MEAT | GROSS | GRAIN