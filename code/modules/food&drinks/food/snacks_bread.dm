
/obj/item/weapon/reagent_containers/food/snacks/store/bread
	slices_num = 5


/obj/item/weapon/reagent_containers/food/snacks/breadslice
	trash = /obj/item/trash/plate
	bitesize = 2
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	list_reagents = list("nutriment" = 5)
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/bread
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain

/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"



/obj/item/weapon/reagent_containers/food/snacks/store/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	list_reagents = list("nutriment" = 10, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"

/obj/item/weapon/reagent_containers/food/snacks/store/bread/xenomeat
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/xenomeat
	list_reagents = list("nutriment" = 10, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/xenomeat
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	filling_color = "#32CD32"

/obj/item/weapon/reagent_containers/food/snacks/store/bread/spidermeat
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/spidermeat
	list_reagents = list("nutriment" = 10, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/spidermeat
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	filling_color = "#7CFC00"

/obj/item/weapon/reagent_containers/food/snacks/store/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	list_reagents = list("nutriment" = 10, "banana" = 10, "vitamin" = 10)


/obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/store/bread/tofu
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	list_reagents = list("nutriment" = 10, "vitamin" = 10)



/obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	filling_color = "#FF8C00"



/obj/item/weapon/reagent_containers/food/snacks/store/bread/creamcheese
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/creamcheese
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	filling_color = "#FF8C00"

/obj/item/weapon/reagent_containers/food/snacks/breadslice/custom
	name = "Custom breadslice"
	desc = "Who knows what it contains?"
	icon_state = "tofubreadslice"
	filling_color = "#FF8C00"

/obj/item/weapon/reagent_containers/food/snacks/breadslice/custom/New()
	..()
	overlays.Cut()
	var/image/I = new(src.icon, "breadslicecustom_filling")
	I.color = filling_color
	overlays += I



/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	list_reagents = list("nutriment" = 6, "blackpepper" = 1, "sodiumchloride" = 1, "vitamin" = 1)
	bitesize = 3
	w_class = 3