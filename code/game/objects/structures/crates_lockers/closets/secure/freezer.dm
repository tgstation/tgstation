/obj/structure/closet/secure_closet/freezer
	icon_state = "freezer"

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen Cabinet"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/kitchen/PopulateContents()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
	new /obj/item/weapon/reagent_containers/food/condiment/rice(src)
	new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "This refrigerator looks quite dusty, is there anything edible still inside?"
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance/PopulateContents()
	..()
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/weapon/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"

/obj/structure/closet/secure_closet/freezer/meat/PopulateContents()
	..()
	for(var/i = 0, i < 4, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(src)
/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"

/obj/structure/closet/secure_closet/freezer/fridge/PopulateContents()
	..()
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/weapon/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/weapon/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	desc = "This contains cold hard cash."
	req_access = list(ACCESS_HEADS_VAULT)

/obj/structure/closet/secure_closet/freezer/money/PopulateContents()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/stack/spacecash/c1000(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/stack/spacecash/c500(src)
	for(var/i = 0, i < 6, i++)
		new /obj/item/stack/spacecash/c200(src)

/obj/structure/closet/secure_closet/freezer/cream_pie
	name = "cream pie closet"
	desc = "Contains pies filled with cream and/or custard, you sickos."
	req_access = list(ACCESS_THEATRE)

/obj/structure/closet/secure_closet/freezer/pie/PopulateContents()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/pie/cream(src)
