/obj/item/storage/box/fishing_hooks
	name = "fishing hook set"
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 2

/obj/item/storage/box/fishing_hooks/PopulateContents()
	new /obj/item/fishing_hook/magnet(src)
	new /obj/item/fishing_hook/shiny(src)
	new /obj/item/fishing_hook/weighted(src)

/obj/item/storage/box/fishing_hooks/master/PopulateContents()
	. = ..()
	new /obj/item/fishing_hook/stabilized(src)
	new /obj/item/fishing_hook/jaws(src)

/obj/item/storage/box/fishing_lines
	name = "fishing line set"
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 2

/obj/item/storage/box/fishing_lines/PopulateContents()
	new /obj/item/fishing_line/bouncy(src)
	new /obj/item/fishing_line/reinforced(src)
	new /obj/item/fishing_line/cloaked(src)

/obj/item/storage/box/fishing_lines/master/PopulateContents()
	. = ..()
	new /obj/item/fishing_line/auto_reel(src)

///From the fishing mystery box. It's basically a lazarus and a few bottles of strange reagents.
/obj/item/storage/box/fish_revival_kit
	name = "fish revival kit"
	desc = "Become a fish doctor today. A label on the side indicates that fish require two to ten reagent units to be splashed onto them for revival, depending on size."
	illustration = "fish"

/obj/item/storage/box/fish_revival_kit/PopulateContents()
	new /obj/item/lazarus_injector(src)
	new /obj/item/reagent_containers/cup/bottle/fishy_reagent(src)
	new /obj/item/reagent_containers/cup(src) //to splash the reagents on the fish.
	new /obj/item/storage/fish_case(src)
	new /obj/item/storage/fish_case(src)

/obj/item/storage/box/fishing_lures
	name = "fishing lures set"
	desc = "A small tackle box containing all the fishing lures you will ever need to curb randomness."
	icon_state = "plasticbox"
	foldable_result = null
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 9
	storage_type = /datum/storage/box/fishing_lures

/obj/item/storage/box/fishing_lures/PopulateContents()
	new /obj/item/paper/lures_instructions(src)
	var/list/typesof = subtypesof(/obj/item/fishing_lure)
	for(var/type in typesof)
		new type (src)

/obj/item/storage/box/aquarium_props
	name = "aquarium props box"
	desc = "All you need to make your aquarium look good."
	illustration = "fish"
	custom_price = PAYCHECK_LOWER

/obj/item/storage/box/aquarium_props/PopulateContents()
	for(var/prop_type in subtypesof(/obj/item/aquarium_prop))
		new prop_type(src)
