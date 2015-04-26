
// see code/module/crafting/table.dm

////////////////////////////////////////////////CAKE////////////////////////////////////////////////

/datum/table_recipe/carrotcake
	name = "Carrot cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/carrot

/datum/table_recipe/cheesecake
	name = "Cheese cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/cheese

/datum/table_recipe/applecake
	name = "Apple cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/apple

/datum/table_recipe/orangecake
	name = "Orange cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/orange

/datum/table_recipe/limecake
	name = "Lime cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/lime

/datum/table_recipe/lemoncake
	name = "Lemon cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/lemon

/datum/table_recipe/chocolatecake
	name = "Chocolate cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/chocolate

/datum/table_recipe/birthdaycake
	name = "Birthday cake"
	reqs = list(
		/obj/item/clothing/head/cakehat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/birthday

/datum/table_recipe/braincake
	name = "Brain cake"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/brain

/datum/table_recipe/slimecake
	name = "Slime cake"
	reqs = list(
		/obj/item/slime_extract = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/slimecake

/datum/table_recipe/pumpkinspicecake
	name = "Pumpkin spice cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/pumpkinspice