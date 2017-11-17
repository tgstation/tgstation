/obj/item/reagent_containers/food/snacks/store/bread/haggis
	name = "haggis"
	desc = "a Savoury pudding containing intestines."
	icon = 'hippiestation/icons/obj/food/food.dmi'
	icon_state = "haggis"
	bonus_reagents = list("nutriment" = 10, "vitamin" = 15)
	list_reagents = list("nutriment" = 40, "vitamin" = 10)
	tastes = list("scottish" = 5)
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/haggis
	foodtype = MEAT | GROSS | GRAIN

/obj/item/reagent_containers/food/snacks/breadslice/haggis
	name = "haggis chunk"
	desc = "a Chunk of delicious(?) haggis."
	icon = 'hippiestation/icons/obj/food/food.dmi'
	icon_state = "haggis_chunk"
	foodtype = MEAT | GROSS | GRAIN