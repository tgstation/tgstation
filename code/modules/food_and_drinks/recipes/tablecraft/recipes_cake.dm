
// see code/module/crafting/table.dm

////////////////////////////////////////////////CAKE////////////////////////////////////////////////

/datum/crafting_recipe/food/carrotcake
	name = "Carrot cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/carrot
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/cheesecake
	name = "Cheese cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/cheese
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/applecake
	name = "Apple cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/apple
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/orangecake
	name = "Orange cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/orange
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/limecake
	name = "Lime cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/lime
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/lemoncake
	name = "Lemon cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/lemon
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/chocolatecake
	name = "Chocolate cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/chocolate
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/birthdaycake
	name = "Birthday cake"
	reqs = list(
		/obj/item/clothing/head/hardhat/cakehat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/birthday
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/braincake
	name = "Brain cake"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/brain
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/slimecake
	name = "Slime cake"
	reqs = list(
		/obj/item/slime_extract = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/slimecake
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/pumpkinspicecake
	name = "Pumpkin spice cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/pumpkinspice
	subcategory = CAT_CAKE

/datum/crafting_recipe/food/cak
	name = "Living cat/cake hybrid"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/birthday = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/simple_animal/pet/cat/cak
	subcategory = CAT_CAKE //Cat! Haha, get it? CAT? GET IT???
