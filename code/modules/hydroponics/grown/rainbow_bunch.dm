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
	reagents_add = list("nutriment" = 0.05)

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
			item_color = "red"
			color = "#DA0000"
			list_reagents = list("redcrayonpowder" = 3)
			desc += " This one is in a bright red color."
		if(2)
			item_color = "orange"
			color = "#FF9300"
			list_reagents = list("orangecrayonpowder" = 3)
			desc += " This one is in a citrus orange color."
		if(3)
			item_color = "yellow"
			color = "#FFF200"
			list_reagents = list("yellowcrayonpowder" = 3)
			desc += " This one is in a bright yellow color."
		if(4)
			item_color = "green"
			color = "#A8E61D"
			list_reagents = list("greencrayonpowder" = 3)
			desc += " This one is in a grassy green color."
		if(5)
			item_color = "blue"
			color = "#00B7EF"
			list_reagents = list("bluecrayonpowder" = 3)
			desc += " This one is in a soothing blue color."
		if(6)
			item_color = "purple"
			color = "#DA00FF"
			list_reagents = list("purplecrayonpowder" = 3)
			desc += " This one is in a vibrant purple color."
		if(7)
			item_color = "black"
			color = "#1C1C1C"
			list_reagents = list("blackcrayonpowder" = 3)
			desc += " This one is in a midnight black color."
		if(8)
			item_color = "white"
			color = "#FFFFFF"
			list_reagents = list("whitecrayonpowder" = 3)
			desc += " This one is in a pure white color."
