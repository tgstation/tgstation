
// see code/datums/recipe.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/recipe/bread
	reagents = list("flour" = 15)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/bread

/datum/recipe/bread/meat
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/meatbread

/datum/recipe/bread/xenomeat
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/xenomeatbread

/datum/recipe/bread/spidermeat
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/spidermeat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/spidermeatbread

/datum/recipe/bread/banana
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/bananabread

/datum/recipe/bread/tofu
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/tofubread

/datum/recipe/bread/creamcheese
	reagents = list("flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/creamcheesebread

/datum/recipe/bread/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/baguette

/datum/recipe/bread/customizable_bun
	items = list(/obj/item/weapon/reagent_containers/food/snacks/dough)
	result = /obj/item/weapon/reagent_containers/food/snacks/bun
