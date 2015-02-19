
/obj/item/weapon/reagent_containers/food/snacks/pie
	trash = /obj/item/trash/plate
	bitesize = 3
	w_class = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/plain
	name = "plain pie"
	desc = "A simple pie, still delicious."
	icon_state = "pie"
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/pie
	list_reagents = list("nutriment" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pie/cream
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/cream/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	reagents.reaction(hit_atom, TOUCH)
	del(src) // Not qdel, because it'll hit other mobs then the floor for runtimes.


/obj/item/weapon/reagent_containers/food/snacks/pie/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	list_reagents = list("nutriment" = 1, "vitamin" = 2)


/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	list_reagents = list("nutriment" = 1, "vitamin" = 5)


/obj/item/weapon/reagent_containers/food/snacks/pie/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	list_reagents = list("nutriment" = 1, "vitamin" = 2)



/obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	bitesize = 4
	list_reagents = list("nutriment" = 1, "vitamin" = 4)


/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	list_reagents = list("nutriment" = 1, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie/New()
	..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent("omnizine", 5)


/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 1, "vitamin" = 5)



/obj/item/weapon/reagent_containers/food/snacks/pie/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	list_reagents = list("nutriment" = 1, "vitamin" = 3)



/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	list_reagents = list("nutriment" = 1, "vitamin" = 2)


/obj/item/weapon/reagent_containers/food/snacks/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	list_reagents = list("nutriment" = 1, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/pie/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	list_reagents = list("nutriment" = 1, "vitamin" = 4)