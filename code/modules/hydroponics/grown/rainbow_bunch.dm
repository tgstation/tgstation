/obj/item/seeds/rainbow_bunch
	name = "pack of rainbow bunch seeds"
	desc = "A pack of seeds that'll grow into a beautiful bush of various colored flowers."
	icon_state = "seed-rainbowbunch"
	species = "rainbowbunch"
	plantname = "Rainbow Flowers"
	icon_harvest = "rainbowbunch-harvest"
	product = /obj/item/grown/rainbow_flower
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

/obj/item/grown/rainbow_flower
	seed = /obj/item/seeds/rainbow_bunch
	name = "rainbow flower"
	desc = "A beautiful flower capable of being used for most dyeing processes."
	icon_state = "rainbow_flower"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 2
	throw_range = 3
	attack_verb = list("pompfed")

/obj/item/grown/rainbow_flower/Initialize()
	var/flower_color = rand(1,8)
	switch(flower_color)
		if(1)
			item_color = "red"
			color = "#DA0000"
			desc += " This one is in a bright red color."
		if(2)
			item_color = "orange"
			color = "#FF9300"
			desc += " This one is in a citrus orange color."
		if(3)
			item_color = "yellow"
			color = "#FFF200"
			desc += " This one is in a bright yellow color."
		if(4)
			item_color = "green"
			color = "#A8E61D"
			desc += " This one is in a grassy green color."
		if(5)
			item_color = "blue"
			color = "#00B7EF"
			desc += " This one is in a soothing blue color."
		if(6)
			item_color = "purple"
			color = "#DA00FF"
			desc += " This one is in a vibrant purple color."
		if(7)
			item_color = "black"
			color = "#1C1C1C"
			desc += " This one is in a midnight black color."
		if(8)
			item_color = "white"
			color = "#FFFFFF"
			desc += " This one is in a pure white color."
