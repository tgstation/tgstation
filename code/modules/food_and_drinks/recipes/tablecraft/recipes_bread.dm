
// see code/module/crafting/table.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/crafting_recipe/food/meatbread
	name = "Meat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/plain = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/meat
	category = CAT_BREAD

/datum/crafting_recipe/food/xenomeatbread
	name = "Xenomeat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/xeno = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/xenomeat
	category = CAT_BREAD

/datum/crafting_recipe/food/spidermeatbread
	name = "Spidermeat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/spider = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/spidermeat
	category = CAT_BREAD

/datum/crafting_recipe/food/banananutbread
	name = "Banana nut bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/banana
	category = CAT_BREAD

/datum/crafting_recipe/food/tofubread
	name = "Tofu bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/tofu
	category = CAT_BREAD

/datum/crafting_recipe/food/creamcheesebread
	name = "Cream cheese bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/creamcheese
	category = CAT_BREAD

/datum/crafting_recipe/food/mimanabread
	name = "Mimana bread"
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana/mime = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/mimana
	category = CAT_BREAD

/datum/crafting_recipe/food/butteredtoast
	name = "Buttered Toast"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/butter = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/butteredtoast
	category = CAT_BREAD

/datum/crafting_recipe/food/butterbiscuit
	name = "Butter Biscuit"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/butter = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/butterbiscuit
	category = CAT_BREAD

