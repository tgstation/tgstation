/obj/item/seeds/rainbow_bunch
	name = "pack of rainbow bunch seeds"
	desc = "A pack of seeds that'll grow into a beautiful bush of various colored flowers."
	icon_state = "seed-lily"
	species = "poppy"
	plantname = "Rainbow Flower"
	icon_harvest = "poppy-harvest"
	product = /obj/item/grown/rainbow_flower
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 2
	potency = 50
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "cotton-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)

/obj/item/grown/rainbow_flower
	seed = /obj/item/seeds/rainbow_bunch
	name = "rainbow flower"
	desc = "A beautiful flower capable of being used for most dyeing processes."
	icon_state = "cotton"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 2
	throw_range = 3
	attack_verb = list("pomfed")
	var/flower_range = list("Red" = "#DA0000", //every crayon color currently
	"Orange" = "#FF9300",
	"Yellow" = "#FFF200",
	"Green" = "#A8E61D",
	"Blue" = "#00B7EF",
	"Purple" = "#DA00FF",
	"Black" = "#1C1C1C",
	"White" = "#FFFFFF"
	)

/obj/item/grown/rainbow_flower/Initialize(mapload)
	color = pick(flower_range)
