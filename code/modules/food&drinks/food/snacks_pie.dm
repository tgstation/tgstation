
/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/pie/New()
	..()
	peakReagents = list("nutriment", 4, "banana", 5, "vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	reagents.reaction(hit_atom, TOUCH)
	del(src) // Not qdel, because it'll hit other mobs then the floor for runtimes.

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis/New()
	..()
	peakReagents = list("nutriment", 4, "berryjuice", 5, "vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/meatpie/New()
	..()
	desc = pick("An old barber recipe, very delicious!","There's no I in team, but there is an I in Meat, Meat pie.")
	peakReagents = list("nutriment", 10, "vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/tofupie/New()
	..()
	peakReagents = list("nutriment", 10, "vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie/New()
	..()
	peakReagents = list("nutriment", 5, "amatoxin", 3, "mushroomhallucinogen", 1, "vitamin", 4)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/plump_pie/New()
	..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		peakReagents = list("nutriment", 8, "vitamin", 4, "omnizine", 5)
	else
		peakReagents = list("nutriment", 8, "vitamin", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie/New()
	..()
	peakReagents = list("nutriment", 10, "vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/applepie/New()
	..()
	peakReagents = list("nutriment", 4, "vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/cherrypie/New()
	..()
	peakReagents = list("nutriment", 4, "vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	coolFood = FALSE

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie/New()
	..()
	peakReagents = list("nutriment", 15, "vitamin", 3)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	coolFood = FALSE
