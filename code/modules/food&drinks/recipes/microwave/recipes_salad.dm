////////////////////////////////////////////////SALADS////////////////////////////////////////////////

/datum/recipe/salad/herb
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/herbsalad
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/herbsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked

/datum/recipe/salad/aesir
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad

/datum/recipe/salad/valid
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked