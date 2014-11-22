
/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/pie/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("banana",5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		H.lip_style = "pie"
		H.update_body()
	else
		new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	playsound(loc, 'sound/items/splat2.ogg', 20, 1)
	reagents.reaction(hit_atom, TOUCH)
	del(src) // Not qdel, because it'll hit other mobs then the floor for runtimes.

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("berryjuice", 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/meatpie/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/tofupie/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie/New()
	..()
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("amatoxin", 3)
	reagents.add_reagent("mushroomhallucinogen", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"

/obj/item/weapon/reagent_containers/food/snacks/plump_pie/New()
	..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("tricordrazine", 5)
		bitesize = 2
	else
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"

/obj/item/weapon/reagent_containers/food/snacks/applepie/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"

/obj/item/weapon/reagent_containers/food/snacks/cherrypie/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie/New()
	..()
	reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	bitesize = 2
