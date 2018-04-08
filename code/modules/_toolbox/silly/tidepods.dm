/datum/reagent/toxin/tide
	name = "Laundry Detergent"
	id = "tide"
	description = "A detergent for cleaning your clothing. Despite popular opinion, ingesting is a bad idea."
	reagent_state = LIQUID
	color = "#66ffcc"
	metabolization_rate = 0.3
	toxpwr = 2
	taste_description = "memes"

/obj/item/reagent_containers/food/snacks/tidepod
	name = "detergent pod"
	desc = "It looks kind of tasty."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "tidepod"
	list_reagents = list("tide" = 5)
	filling_color = "#66ffcc"
	tastes = list("memes" = 1)
	bitesize = 5
	w_class = 1
	//unique_rename = 0

/obj/item/reagent_containers/food/snacks/tidepod/machine_wash(obj/machinery/washing_machine/WM)
	qdel(src)
	return

/obj/item/storage/box/tidepods
	name = "Detergent Pods"
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "tidepods"
	desc = "Detergent pods for cleaning your clothing. Despite popular opinion, ingesting is a bad idea."
	can_hold = list(/obj/item/reagent_containers/food/snacks/tidepod)
	w_class = 3
	max_w_class = 1
	illustration = null

/obj/item/storage/box/tidepods/New()
	for(var/i=storage_slots,i>0,i--)
		new /obj/item/reagent_containers/food/snacks/tidepod(src)
	. = ..()

/datum/supply_pack/misc/tidepods
	name = "Laundry Supplies"
	cost = 500
	contains = list(
		/obj/item/storage/box/tidepods,
		/obj/item/storage/box/tidepods,
		/obj/item/storage/box/tidepods)
	crate_name = "laundry crate"

/datum/crafting_recipe/food/podpizza
	name = "Pod pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/tidepod = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/tidepod
	subcategory = CAT_PIZZA

/obj/item/reagent_containers/food/snacks/pizza/tidepod
	name = "pod pizza"
	icon = 'icons/oldschool/objects.dmi'
	desc = "Greasy pizza with delicious pods."
	icon_state = "tidepodpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/tidepod
	bonus_reagents = list("nutriment" = 5, "vitamin" = 8)
	list_reagents = list("nutriment" = 15, "tomatojuice" = 6, "vitamin" = 8, "tide" = 15)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "memes" = 1)

/obj/item/reagent_containers/food/snacks/pizzaslice/tidepod
	name = "pod pizza slice"
	icon = 'icons/oldschool/objects.dmi'
	desc = "A nutritious slice of pod pizza."
	icon_state = "tidepodpizzaslice"
	filling_color = "#A52A2A"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "memes" = 1)