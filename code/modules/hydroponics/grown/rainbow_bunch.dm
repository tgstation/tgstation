/obj/item/seeds/rainbow_bunch
	name = "pack of rainbow bunch seeds"
	desc = "A pack of seeds that'll grow into a beautiful bush of various colored flowers."
	icon_state = "seed-rainbowbunch"
	species = "rainbowbunch"
	plantname = "Rainbow Flowers"
	icon_harvest = "rainbowbunch-harvest"
	product = /obj/item/reagent_containers/food/snacks/grown/rainbow_flower
	lifespan = 25
	endurance = 10
	maturation = 6
	production = 3
	yield = 5
	potency = 20
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "rainbowbunch-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/rainbow_flower
	seed = /obj/item/seeds/rainbow_bunch
	name = "rainbow flower"
	desc = "A beautiful flower capable of being used for most dyeing processes."
	icon_state = "rainbow_flower"
	slot_flags = ITEM_SLOT_HEAD
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 2
	throw_range = 3
	attack_verb = list("pompfed")

/obj/item/reagent_containers/food/snacks/grown/rainbow_flower/Initialize()
	. = ..()
	var/flower_color = rand(1,8)
	switch(flower_color)
		if(1)
			color = "#DA0000"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/red = 3)
			dye_color = DYE_RED
			desc += " This one is in a bright red color."
		if(2)
			color = "#FF9300"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/orange = 3)
			dye_color = DYE_ORANGE
			desc += " This one is in a citrus orange color."
		if(3)
			color = "#FFF200"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/yellow = 3)
			dye_color = DYE_YELLOW
			desc += " This one is in a bright yellow color."
		if(4)
			color = "#A8E61D"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/green = 3)
			dye_color = DYE_GREEN
			desc += " This one is in a grassy green color."
		if(5)
			color = "#00B7EF"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/blue = 3)
			dye_color = DYE_BLUE
			desc += " This one is in a soothing blue color."
		if(6)
			color = "#DA00FF"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/purple = 3)
			dye_color = DYE_PURPLE
			desc += " This one is in a vibrant purple color."
		if(7)
			color = "#1C1C1C"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/black = 3)
			dye_color = DYE_BLACK
			desc += " This one is in a midnight black color."
		if(8)
			color = "#FFFFFF"
			list_reagents = list(/datum/reagent/colorful_reagent/crayonpowder/white = 3)
			dye_color = DYE_WHITE
			desc += " This one is in a pure white color."
