/obj/item/reagent_containers/food/snacks/kebab/rat
	name = "rat-kebab"
	desc = "Not so delicious rat meat, on a stick."
	icon_state = "ratkebab"
	icon = 'hippiestation/icons/obj/food/food.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("rat meat" = 1, "metal" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/kebab/rat/double
	name = "double rat-kebab"
	icon_state = "doubleratkebab"
	tastes = list("rat meat" = 2, "metal" = 1)
	bonus_reagents = list("nutriment" = 6, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/kebab/butt
	name = "butt-kebab"
	desc = "Butt on a stick."
	icon_state = "buttkebab"
	icon = 'hippiestation/icons/obj/food/food.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("butt" = 2, "metal" = 1)
	foodtype = MEAT | GROSS