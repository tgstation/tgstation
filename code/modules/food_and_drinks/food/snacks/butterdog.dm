/obj/item/reagent_containers/food/snacks/butterdog
	name = "butterdog"
	desc = "Made from exotic butters."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bitesize = 1
	filling_color = "#F1F49A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter", "exotic butter")
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/butterdog/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)
