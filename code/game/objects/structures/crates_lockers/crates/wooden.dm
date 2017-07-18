/obj/structure/closet/crate/wooden
	name = "wooden crate"
	desc = "Works just as well as a metal one."
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 6
	icon_state = "wooden"

/obj/structure/closet/crate/wooden/toy
	name = "toy box"
	desc = "It has the words \"Clown + Mime\" written underneath of it with marker."

/obj/structure/closet/crate/wooden/toy/PopulateContents()
	. = ..()
	new	/obj/item/device/megaphone/clown(src)
	new	/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_laughter(src)
	new /obj/item/weapon/pneumatic_cannon/pie(src)
	new /obj/item/weapon/reagent_containers/food/snacks/pie/cream(src)
	new /obj/item/weapon/storage/crayons(src)