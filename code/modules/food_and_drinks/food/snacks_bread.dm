
/obj/item/weapon/reagent_containers/food/snacks/store/bread
	icon = 'icons/obj/food/burgerbread.dmi'
	volume = 80
	slices_num = 5
	tastes = list("bread" = 10)


/obj/item/weapon/reagent_containers/food/snacks/breadslice
	icon = 'icons/obj/food/burgerbread.dmi'
	bitesize = 2
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	filling_color = "#FFA500"
	list_reagents = list("nutriment" = 2)
	slot_flags = SLOT_HEAD
	customfoodfilling = 0 //to avoid infinite bread-ception

/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	bonus_reagents = list("nutriment" = 7)
	list_reagents = list("nutriment" = 10)
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/bread
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain
	tastes = list("bread" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	customfoodfilling = 1

/obj/item/weapon/reagent_containers/food/snacks/store/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	bonus_reagents = list("nutriment" = 5, "vitamin" = 10)
	list_reagents = list("nutriment" = 30, "vitamin" = 5)
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"

/obj/item/weapon/reagent_containers/food/snacks/store/bread/xenomeat
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/xenomeat
	bonus_reagents = list("nutriment" = 5, "vitamin" = 10)
	list_reagents = list("nutriment" = 30, "vitamin" = 5)
	tastes = list("bread" = 10, "acid" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/xenomeat
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	filling_color = "#32CD32"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/store/bread/spidermeat
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/spidermeat
	bonus_reagents = list("nutriment" = 5, "vitamin" = 10)
	list_reagents = list("nutriment" = 30, "toxin" = 15, "vitamin" = 5)
	tastes = list("bread" = 10, "cobwebs" = 5)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/spidermeat
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	filling_color = "#7CFC00"
	list_reagents = list("nutriment" = 6, "toxin" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/store/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	bonus_reagents = list("nutriment" = 5, "banana" = 20)
	list_reagents = list("nutriment" = 20, "banana" = 20)
	tastes = list("bread" = 10) // bananjuice will also flavour


/obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	filling_color = "#FFD700"
	list_reagents = list("nutriment" = 4, "banana" = 4)

/obj/item/weapon/reagent_containers/food/snacks/store/bread/tofu
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	bonus_reagents = list("nutriment" = 5, "vitamin" = 10)
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("bread" = 10, "tofu" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	filling_color = "#FF8C00"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/store/bread/creamcheese
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/creamcheese
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("bread" = 10, "cheese" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	filling_color = "#FF8C00"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/store/bread/mimana
	name = "mimana bread"
	desc = "Best eaten in silence."
	icon_state = "mimanabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/mimana
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 20, "mutetoxin" = 5, "nothing" = 5, "vitamin" = 5)
	tastes = list("bread" = 10, "silence" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/mimana
	name = "mimana bread slice"
	desc = "A slice of silence!"
	icon_state = "mimanabreadslice"
	filling_color = "#C0C0C0"
	list_reagents = list("nutriment" = 2, "mutetoxin" = 1, "nothing" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/custom
	name = "bread slice"
	icon_state = "tofubreadslice"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 2)
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	bitesize = 3
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("bread" = 1)

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bitesize = 2
