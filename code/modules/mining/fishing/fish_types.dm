var/list/types_of_fish = list(/obj/item/weapon/fish/iron,
								/obj/item/weapon/fish/gold,
								/obj/item/weapon/fish/silver,
								/obj/item/weapon/fish/diamond,
								/obj/item/weapon/fish/uranium,
								/obj/item/weapon/fish/bananium,
								/obj/item/weapon/fish/plasma,
								/obj/item/weapon/fish/plant,
								/obj/item/weapon/fish/bread,
								/obj/item/weapon/fish/robotic,
								/obj/item/weapon/fish/monkey)
/obj/item/weapon/fish
	name = "fish"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fish_iron"
	desc = "A fish."
	var/list/min_harvest_drops = list(new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/fish(),
										new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/fish(),
										new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/fish())
	var/list/harvest_drops = list()
	var/harvest_times = 1

/obj/item/weapon/fish/attackby(obj/item/C, mob/user, params)
	if(is_sharp(C))
		user << "You butcher [src] inefficiently, wasting most of the fish."
		for(var/obj/item/I in min_harvest_drops)
			new I.type(loc)
		harvest_times--
		if(harvest_times == 0)
			qdel(src)
		return
// ORE FISH (the incentive to get miners to actually fish)
/obj/item/weapon/fish/iron
	name = "ironclad"
	icon_state = "fish_iron"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/iron/fish(),
						new /obj/item/weapon/ore/iron/fish(),
						new /obj/item/weapon/ore/iron/fish(),
						new /obj/item/weapon/ore/iron/fish(),
						new /obj/item/weapon/ore/iron/fish())
	harvest_times = 3

/obj/item/weapon/fish/gold
	name = "midas's fish"
	icon_state = "fish_gold"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/gold/fish(),
						new /obj/item/weapon/ore/gold/fish(),
						new /obj/item/weapon/ore/gold/fish(),
						new /obj/item/weapon/ore/gold/fish(),
						new /obj/item/weapon/ore/gold/fish())
	harvest_times = 3

/obj/item/weapon/fish/silver
	name = "sliver"
	icon_state = "fish_silver"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/silver/fish(),
						new /obj/item/weapon/ore/silver/fish(),
						new /obj/item/weapon/ore/silver/fish(),
						new /obj/item/weapon/ore/silver/fish(),
						new /obj/item/weapon/ore/silver/fish())
	harvest_times = 3

/obj/item/weapon/fish/diamond
	name = "nurse's best friend"
	icon_state = "fish_diamond"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/diamond/fish(),
						new /obj/item/weapon/ore/diamond/fish(),
						new /obj/item/weapon/ore/diamond/fish(),
						new /obj/item/weapon/ore/diamond/fish(),
						new /obj/item/weapon/ore/diamond/fish())
	harvest_times = 3

/obj/item/weapon/fish/uranium
	name = "radioactive waver"
	icon_state = "fish_uranium"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/uranium/fish(),
						new /obj/item/weapon/ore/uranium/fish(),
						new /obj/item/weapon/ore/uranium/fish(),
						new /obj/item/weapon/ore/uranium/fish(),
						new /obj/item/weapon/ore/uranium/fish())
	harvest_times = 3

/obj/item/weapon/fish/bananium
	name = "clownfish"
	icon_state = "fish_bananium"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/bananium/fish(),
						new /obj/item/weapon/ore/bananium/fish(),
						new /obj/item/weapon/ore/bananium/fish(),
						new /obj/item/weapon/ore/bananium/fish(),
						new /obj/item/weapon/ore/bananium/fish())
	harvest_times = 3

/obj/item/weapon/fish/plasma
	name = "firefish"
	icon_state = "fish_plasma"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/ore/plasma/fish(),
						new /obj/item/weapon/ore/plasma/fish(),
						new /obj/item/weapon/ore/plasma/fish(),
						new /obj/item/weapon/ore/plasma/fish(),
						new /obj/item/weapon/ore/plasma/fish())
	harvest_times = 3

// DEPARTMENTAL FISH (the incentive to support other departments)
/obj/item/weapon/fish/plant
	name = "leafer"
	icon_state = "fish_silver"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus(), // Support the botanists by letting them skip the mutation phase to get some good plants
						new /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus(),
						new /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus(),
						new /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space(),
						new /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space())
	harvest_times = 3

/obj/item/weapon/fish/bread
	name = "loafer"
	icon_state = "fish_silver"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain(), // Support the chef by saving him flour, along with your loads of meat.
						new /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain(),
						new /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain(),
						new /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain(),
						new /obj/item/weapon/reagent_containers/food/snacks/breadslice/plain())
	harvest_times = 3

/obj/item/weapon/fish/robotic
	name = "robotic fish"
	icon_state = "fish_silver"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/stock_parts/capacitor/super(), // Support R&D by giving them a tech boost
						new /obj/item/weapon/stock_parts/scanning_module/phasic(),
						new /obj/item/weapon/stock_parts/scanning_module/phasic(),
						new /obj/item/weapon/stock_parts/manipulator/pico(),
						new /obj/item/weapon/stock_parts/manipulator/pico())
	harvest_times = 3

/obj/item/weapon/fish/monkey
	name = "monkeyfish"
	icon_state = "fish_silver"
	desc = "A fish."
	harvest_drops = list(new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(), // Support chef again by giving him even more meat
						new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(),
						new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(),
						new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(),
						new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey())
	harvest_times = 3