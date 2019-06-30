/obj/item/reagent_containers/food/snacks/burger/assburger
	name = "assburger"
	desc = "What the hell, that's not domesticated donkey meat, it's a literal buttburger!"
	tastes = list("butt" = 4)
	foodtype = MEAT | GRAIN | GROSS
	bonus_reagents = list(/datum/reagent/drug/fartium = 10, /datum/reagent/consumable/nutriment = 2)
	icon = 'spacestation413/icons/obj/food/burgerbread.dmi'
	icon_state = "assburger"

/obj/item/reagent_containers/food/snacks/burger/cluwneburger
	name = "cluwneburger"
	desc = "A old burger with a cluwne mask on it. It seems to be staring into your soul..."
	icon_state = "cluwneburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/cluwnification = 2, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/cluwnification = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bun" = 4, "regret" = 2, "something funny" = 1)
	foodtype = GRAIN | TOXIC
