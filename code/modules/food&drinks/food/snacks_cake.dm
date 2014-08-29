
/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/carrotcake
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/carrotcake/New()
	..()
	reagents.add_reagent("nutriment", 25)
	reagents.add_reagent("imidazoline", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	name = "carrot cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/braincake/New()
	..()
	reagents.add_reagent("nutriment", 25)
	reagents.add_reagent("alkysine", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/cheesecake/New()
	..()
	reagents.add_reagent("nutriment", 25)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/plaincake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/plaincake/New()
	..()
	reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/orangecake/New()
	..()
	reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/limecake/New()
	..()
	reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/lemoncake/New()
	..()
	reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/chocolatecake/New()
	..()
	reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/birthdaycake
	name = "birthday cake"
	desc = "Happy Birthday little clown..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/birthdaycake/New()
	..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("sprinkles", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	name = "birthday cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/applecake
	name = "apple cake"
	desc = "A cake centred with Apple."
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/applecake/New()
	..()
	reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2
