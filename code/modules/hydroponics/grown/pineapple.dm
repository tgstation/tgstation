// Pineapple!
/obj/item/seeds/pineapple
	name = "pack of pineapple seeds"
	desc = "Oooooooooooooh!"
	icon_state = "seed-pineapple"
	species = "pineapple"
	plantname = "Pineapple Plant"
	product = /obj/item/food/grown/pineapple
	lifespan = 40
	endurance = 30
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/juicing)
	mutatelist = list(/obj/item/seeds/apple)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.02, /datum/reagent/consumable/nutriment = 0.2, /datum/reagent/water = 0.04)
	graft_gene = /datum/plant_gene/trait/juicing

/obj/item/food/grown/pineapple
	seed = /obj/item/seeds/pineapple
	name = "pineapples"
	desc = "Blorble."
	icon_state = "pineapple"
	bite_consumption_mod = 2
	force = 4
	throwforce = 8
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("stings", "pines")
	attack_verb_simple = list("sting", "pine")
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT | PINEAPPLE
	juice_results = list(/datum/reagent/consumable/pineapplejuice = 0)
	tastes = list("pineapple" = 1)
	wine_power = 40
	filling_color = "#F6CB0B"

/obj/item/food/grown/pineapple/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pineappleslice, 3, 15)
