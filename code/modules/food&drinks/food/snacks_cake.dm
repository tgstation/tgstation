
/obj/item/weapon/reagent_containers/food/snacks/store/cake
	icon = 'icons/obj/food/piecake.dmi'
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/plain
	slices_num = 5
	bitesize = 3
	volume = 80
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice
	icon = 'icons/obj/food/piecake.dmi'
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	customfoodfilling = 0 //to avoid infinite cake-ception

/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/cake
	bonus_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/plain
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	filling_color = "#FFD700"
	customfoodfilling = 1

/obj/item/weapon/reagent_containers/food/snacks/store/cake/carrot
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "oculine" = 5, "vitamin" = 10)
	list_reagents = list("nutriment" = 20, "oculine" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	name = "carrot cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	filling_color = "#FFA500"
	list_reagents = list("nutriment" = 4, "oculine" = 2, "vitamin" = 1)


/obj/item/weapon/reagent_containers/food/snacks/store/cake/brain
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	slices_num = 5
	bonus_reagents = list("nutriment" = 5, "mannitol" = 10, "vitamin" = 10)
	list_reagents = list("nutriment" = 20, "mannitol" = 10, "vitamin" = 5)


/obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	filling_color = "#FF69B4"
	list_reagents = list("nutriment" = 4, "mannitol" = 2, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/store/cake/cheese
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	slices_num = 5
	bonus_reagents = list("vitamin" = 10)


/obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	filling_color = "#FFFACD"


/obj/item/weapon/reagent_containers/food/snacks/store/cake/orange
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/store/cake/lime
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	filling_color = "#00FF00"


/obj/item/weapon/reagent_containers/food/snacks/store/cake/lemon
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 10)


/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	filling_color = "#FFEE00"


/obj/item/weapon/reagent_containers/food/snacks/store/cake/chocolate
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 10)


/obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	filling_color = "#A0522D"


/obj/item/weapon/reagent_containers/food/snacks/store/cake/birthday
	name = "birthday cake"
	desc = "Happy Birthday little clown..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	slices_num = 5
	bonus_reagents = list("nutriment" = 7, "sprinkles" = 10, "vitamin" = 5)
	list_reagents = list("nutriment" = 20, "sprinkles" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	name = "birthday cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	filling_color = "#DC143C"
	list_reagents = list("nutriment" = 4, "sprinkles" = 2, "vitamin" = 1)


/obj/item/weapon/reagent_containers/food/snacks/store/cake/apple
	name = "apple cake"
	desc = "A cake centred with Apple."
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	slices_num = 5
	bonus_reagents = list("nutriment" = 3, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	filling_color = "#FF4500"

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/custom
	name = "cake slice"
	icon_state = "plaincake_slice"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/store/cake/slimecake
	name = "Slime cake"
	desc = "A cake made of slimes. Probably not electrified."
	icon_state = "slimecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/slimecake
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/slimecake
	name = "slime cake slice"
	desc = "A slice of slime cake."
	icon_state = "slimecake_slice"
	filling_color = "#00FFFF"

/obj/item/weapon/reagent_containers/food/snacks/store/cake/pumpkinspice
	name = "pumpkin spice cake"
	desc = "A hollow cake with real pumpkin."
	icon_state = "pumpkinspicecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/pumpkinspice
	bonus_reagents = list("nutriment" = 3, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/pumpkinspice
	name = "pumpkin spice cake slice"
	desc = "A spicy slice of pumpkin goodness."
	icon_state = "pumpkinspicecakeslice"
	filling_color = "#FFD700"