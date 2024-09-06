/obj/item/storage/box/spaceman_ration
	name = "unlabeled ration container"
	desc = "You get the feeling you sholdn't have been sent this one?"
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	icon_state = "plants"
	illustration = null
	/// How many storage slots this has, yes I'm being lazy
	var/box_storage_slots = 1

/obj/item/storage/box/spaceman_ration/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = box_storage_slots

/obj/item/storage/box/spaceman_ration/PopulateContents()
	return

// Contains your daily need of plants, yum!

/obj/item/storage/box/spaceman_ration/plants
	name = "produce ration container"
	desc = "Contains your allotted ration of produce, which in this case should be peas and a potato."
	box_storage_slots = 2

/obj/item/storage/box/spaceman_ration/plants/PopulateContents()
	new /obj/item/food/grown/peas(src)
	new /obj/item/food/grown/potato(src)

// Alternate diet, themed around martian food a bit more

/obj/item/storage/box/spaceman_ration/plants/alternate
	desc = "Contains your allotted ration of produce, which in this case should be cabbage and an onion."
	icon_state = "plants_alt"

/obj/item/storage/box/spaceman_ration/plants/alternate/PopulateContents()
	new /obj/item/food/grown/cabbage(src)
	new /obj/item/food/grown/onion(src)

// For the moths amogus

/obj/item/storage/box/spaceman_ration/plants/mothic
	desc = "Contains your allotted ration of produce, which in this case should be chili and a potato."
	icon_state = "plants_moth"

/obj/item/storage/box/spaceman_ration/plants/mothic/PopulateContents()
	new /obj/item/food/grown/chili(src)
	new /obj/item/food/grown/potato(src)

// For the lizards amongus

/obj/item/storage/box/spaceman_ration/plants/lizard
	desc = "Contains your allotted ration of produce, which in this case should be two korta nuts and two potatoes."
	icon_state = "plants_lizard"
	box_storage_slots = 4

/obj/item/storage/box/spaceman_ration/plants/lizard/PopulateContents()
	new /obj/item/food/grown/korta_nut(src)
	new /obj/item/food/grown/korta_nut(src)
	new /obj/item/food/grown/potato(src)
	new /obj/item/food/grown/potato(src)

// Contains your allotted meats, tasty!

/obj/item/storage/box/spaceman_ration/meats
	name = "meat ration container"
	desc = "Contains your allotted ration of meat, which in this case should be preserved pork and a random side option."
	icon_state = "meats"

/obj/item/storage/box/spaceman_ration/meats/PopulateContents()
	new /obj/item/food/meat/slab/pig(src)
	var/secondary_meat = pick(/obj/item/food/raw_sausage, /obj/item/food/meat/slab/chicken, /obj/item/food/meat/slab/meatproduct)
	new secondary_meat(src)

// Seafood variant

/obj/item/storage/box/spaceman_ration/meats/fish
	desc = "Contains your allotted ration of meat, which in this case should be preserved pork and a random seafood side option."
	icon_state = "meats_fish"

/obj/item/storage/box/spaceman_ration/meats/fish/PopulateContents()
	new /obj/item/food/meat/slab/pig(src)
	var/secondary_meat = pick(/obj/item/food/meat/slab/rawcrab, /obj/item/food/fishmeat)
	new secondary_meat(src)

// For the lizards amongus

/obj/item/storage/box/spaceman_ration/meats/lizard
	desc = "Contains your allotted ration of meat, which in this case should be preserved pork and a random seafood side option."
	icon_state = "meats_lizard"

/obj/item/storage/box/spaceman_ration/meats/lizard/PopulateContents()
	new /obj/item/food/fishmeat/moonfish(src)
	var/secondary_meat = pick(/obj/item/food/raw_tiziran_sausage, /obj/item/food/liver_pate)
	new secondary_meat(src)

// Paper sack that spawns a random two slices of bread

/obj/item/storage/box/papersack/ration_bread_slice
	name = "bread and cheese ration bag"
	desc = "A dusty old paper sack that should ideally contain your ration of bread and cheese."

/obj/item/storage/box/papersack/ration_bread_slice/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3

/obj/item/storage/box/papersack/ration_bread_slice/PopulateContents()
	var/bread_slice = pick(/obj/item/food/breadslice/plain, /obj/item/food/breadslice/reispan, /obj/item/food/breadslice/root)
	new bread_slice(src)
	new bread_slice(src)
	var/cheese_slice = pick(/obj/item/food/cheese/wedge, /obj/item/food/cheese/firm_cheese_slice, /obj/item/food/cheese/cheese_curds, /obj/item/food/cheese/mozzarella)
	new cheese_slice(src)
