
// see code/datums/recipe.dm

////////////////////////////////////////////////CAKE////////////////////////////////////////////////

/datum/recipe/cake/carrot
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/carrotcake

/datum/recipe/cake/cheese
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/cheesecake

/datum/recipe/cake/plain
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/plaincake

/datum/recipe/cake/birthday
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/clothing/head/cakehat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/birthdaycake

/datum/recipe/cake/apple
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/applecake

/datum/recipe/cake/orange
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/orangecake

/datum/recipe/cake/lime
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/limecake

/datum/recipe/cake/lemon
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/lemoncake

/datum/recipe/cake/chocolate
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/chocolatecake

/datum/recipe/cake/brain
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/organ/brain
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sliceable/store/braincake
