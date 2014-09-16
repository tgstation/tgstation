
/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/meatbread/New()
	..()
	reagents.add_reagent("nutriment", 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/xenomeatbread/New()
	..()
	reagents.add_reagent("nutriment", 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/spidermeatbread
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/spidermeatbread/New()
	..()
	reagents.add_reagent("nutriment", 30)
	reagents.add_reagent("toxin", 15)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice/New()
	..()
	reagents.add_reagent("toxin", 2)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/bananabread
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/bananabread/New()
	..()
	reagents.add_reagent("banana", 20)
	reagents.add_reagent("nutriment", 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/tofubread
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/tofubread/New()
	..()
	reagents.add_reagent("nutriment", 30)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/bread
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/bread/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/creamcheesebread/New()
	..()
	reagents.add_reagent("nutriment", 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"

/obj/item/weapon/reagent_containers/food/snacks/baguette/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("sodiumchloride", 1)
	bitesize = 3
