
// see code/module/crafting/table.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/table_recipe/meatbread
	name = "Meat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/plain = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/meat

/datum/table_recipe/xenomeatbread
	name = "Xenomeat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/xeno = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/xenomeat

/datum/table_recipe/spidermeatbread
	name = "Spidermeat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet/spider = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/spidermeat

/datum/table_recipe/banananutbread
	name = "Banana nut bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/banana

/datum/table_recipe/tofubread
	name = "Tofu bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/tofu

/datum/table_recipe/creamcheesebread
	name = "Cream cheese bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/creamcheese

/datum/table_recipe/mimanabread
	name = "Mimana bread"
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mimana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/mimana
