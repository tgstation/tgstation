/datum/chemical_reaction/drink/icetea
	results = list(/datum/reagent/consumable/icetea = 4)
	required_reagents = list(/datum/reagent/consumable/ice = 1, /datum/reagent/consumable/tea = 3)

/datum/chemical_reaction/drink/icecoffee
	results = list(/datum/reagent/consumable/icecoffee = 4)
	required_reagents = list(/datum/reagent/consumable/ice = 1, /datum/reagent/consumable/coffee = 3)

/datum/chemical_reaction/drink/hoticecoffee
	results = list(/datum/reagent/consumable/hot_ice_coffee = 3)
	required_reagents = list(/datum/reagent/toxin/hot_ice = 1, /datum/reagent/consumable/coffee = 2)

/datum/chemical_reaction/drink/nuka_cola
	results = list(/datum/reagent/consumable/nuka_cola = 6)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/consumable/space_cola = 6)

/datum/chemical_reaction/drink/doctor_delight
	results = list(/datum/reagent/consumable/doctor_delight = 5)
	required_reagents = list(/datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/consumable/orangejuice = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/medicine/cryoxadone = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/drink/soy_latte
	results = list(/datum/reagent/consumable/soy_latte = 2)
	required_reagents = list(/datum/reagent/consumable/coffee = 1, /datum/reagent/consumable/soymilk = 1)

/datum/chemical_reaction/drink/cafe_latte
	results = list(/datum/reagent/consumable/cafe_latte = 2)
	required_reagents = list(/datum/reagent/consumable/coffee = 1, /datum/reagent/consumable/milk = 1)

/datum/chemical_reaction/drink/cherryshake
	results = list(/datum/reagent/consumable/cherryshake = 3)
	required_reagents = list(/datum/reagent/consumable/cherryjelly = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/bluecherryshake
	results = list(/datum/reagent/consumable/bluecherryshake = 3)
	required_reagents = list(/datum/reagent/consumable/bluecherryjelly = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/vanillashake
	results = list(/datum/reagent/consumable/vanillashake = 3)
	required_reagents = list(/datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/caramelshake
	results = list(/datum/reagent/consumable/caramelshake = 3)
	required_reagents = list(/datum/reagent/consumable/caramel = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/choccyshake
	results = list(/datum/reagent/consumable/choccyshake = 3)
	required_reagents = list(/datum/reagent/consumable/coco = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/strawberryshake
	results = list(/datum/reagent/consumable/strawberryshake = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/bananashake
	results = list(/datum/reagent/consumable/bananashake = 3)
	required_reagents = list(/datum/reagent/consumable/banana = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/pumpkin_latte
	results = list(/datum/reagent/consumable/pumpkin_latte = 15)
	required_reagents = list(/datum/reagent/consumable/pumpkinjuice = 5, /datum/reagent/consumable/coffee = 5, /datum/reagent/consumable/cream = 5)

/datum/chemical_reaction/drink/gibbfloats
	results = list(/datum/reagent/consumable/gibbfloats = 15)
	required_reagents = list(/datum/reagent/consumable/dr_gibb = 5, /datum/reagent/consumable/ice = 5, /datum/reagent/consumable/cream = 5)

/datum/chemical_reaction/drink/triple_citrus
	results = list(/datum/reagent/consumable/triple_citrus = 3)
	required_reagents = list(/datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/orangejuice = 1)
	optimal_ph_min = 0//Our reaction is very acidic, so lets shift our range

/datum/chemical_reaction/drink/grape_soda
	results = list(/datum/reagent/consumable/grape_soda = 2)
	required_reagents = list(/datum/reagent/consumable/grapejuice = 1, /datum/reagent/consumable/sodawater = 1)

/datum/chemical_reaction/drink/lemonade
	results = list(/datum/reagent/consumable/lemonade = 5)
	required_reagents = list(/datum/reagent/consumable/lemonjuice = 2, /datum/reagent/water = 2, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ice = 1)
	mix_message = "You're suddenly reminded of home."

/datum/chemical_reaction/drink/arnold_palmer
	results = list(/datum/reagent/consumable/tea/arnold_palmer = 2)
	required_reagents = list(/datum/reagent/consumable/icetea = 1, /datum/reagent/consumable/lemonade = 1)
	mix_message = "The smells of fresh green grass and sand traps waft through the air as the mixture turns a friendly yellow-orange."

/datum/chemical_reaction/drink/chocolate_milk
	results = list(/datum/reagent/consumable/milk/chocolate_milk = 5)
	required_reagents = list(/datum/reagent/consumable/hot_coco = 3, /datum/reagent/consumable/coco = 2)
	mix_message = "The color changes as the mixture blends smoothly."
	required_temp = 300
	is_cold_recipe = TRUE
	optimal_temp = 280
	overheat_temp = 5
	thermic_constant= -1

/datum/chemical_reaction/drink/hot_coco
	results = list(/datum/reagent/consumable/hot_coco = 6)
	required_reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/coco = 1)
	required_temp = 320

/datum/chemical_reaction/drink/hot_coco_from_chocolate_milk
	results = list(/datum/reagent/consumable/hot_coco = 3)
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 1, /datum/reagent/consumable/milk = 2)
	required_temp = 320

/datum/chemical_reaction/drink/coffee
	results = list(/datum/reagent/consumable/coffee = 5)
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/drink/tea
	results = list(/datum/reagent/consumable/tea = 5)
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/drink/cream_soda
	results = list(/datum/reagent/consumable/cream_soda = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/sodawater = 2, /datum/reagent/consumable/vanilla = 1)

/datum/chemical_reaction/drink/red_queen
	results = list(/datum/reagent/consumable/red_queen = 10)
	required_reagents = list(/datum/reagent/consumable/tea = 6, /datum/reagent/mercury = 2, /datum/reagent/consumable/blackpepper = 1, /datum/reagent/growthserum = 1)

/datum/chemical_reaction/drink/toechtauese_syrup
	results = list(/datum/reagent/consumable/toechtauese_syrup = 10)
	required_reagents = list(/datum/reagent/consumable/toechtauese_juice = 6, /datum/reagent/consumable/sugar = 4)

/datum/chemical_reaction/drink/roy_rogers
	results = list(/datum/reagent/consumable/roy_rogers = 3)
	required_reagents = list(/datum/reagent/consumable/space_cola = 2, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/drink/shirley_temple
	results = list(/datum/reagent/consumable/shirley_temple = 3)
	required_reagents = list(/datum/reagent/consumable/sol_dry = 2, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/drink/agua_fresca
	results = list(/datum/reagent/consumable/agua_fresca = 10)
	required_reagents = list(/datum/reagent/consumable/watermelonjuice = 4, /datum/reagent/consumable/ice = 1, /datum/reagent/water = 2, /datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/menthol = 1)

/datum/chemical_reaction/drink/cinderella
	results = list(/datum/reagent/consumable/cinderella = 50)
	required_reagents = list(/datum/reagent/consumable/pineapplejuice = 10, /datum/reagent/consumable/orangejuice = 10, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/ice = 5, /datum/reagent/consumable/sol_dry = 20, /datum/reagent/consumable/ethanol/bitters = 2)

/datum/chemical_reaction/drink/italian_coco
	results = list(/datum/reagent/consumable/italian_coco = 10)
	required_reagents = list(/datum/reagent/consumable/hot_coco  = 5, /datum/reagent/consumable/corn_starch = 1, /datum/reagent/consumable/whipped_cream = 4)

/datum/chemical_reaction/drink/strawberry_banana
	results = list(/datum/reagent/consumable/strawberry_banana = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/banana = 1)

/datum/chemical_reaction/drink/berry_blast
	results = list(/datum/reagent/consumable/berry_blast = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/funky_monkey
	results = list(/datum/reagent/consumable/funky_monkey = 3)
	required_reagents = list(/datum/reagent/consumable/coco = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/banana = 1)

/datum/chemical_reaction/drink/green_giant
	results = list(/datum/reagent/consumable/green_giant = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/drink/melon_baller
	results = list(/datum/reagent/consumable/melon_baller = 3)
	required_reagents = list(/datum/reagent/consumable/watermelonjuice = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/milk = 1)

/datum/chemical_reaction/drink/vanilla_dream
	results = list(/datum/reagent/consumable/vanilla_dream = 3)
	required_reagents = list(/datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/cucumberlemonade
	results = list(/datum/reagent/consumable/cucumberlemonade = 5)
	required_reagents = list(/datum/reagent/consumable/lemon_lime = 3, /datum/reagent/consumable/cucumberjuice = 2, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/drink/mississippi_queen
	results = list(/datum/reagent/consumable/mississippi_queen = 50)
	required_reagents = list(/datum/reagent/consumable/tomatojuice = 15, /datum/reagent/consumable/mayonnaise = 10, /datum/reagent/consumable/soysauce = 5, /datum/reagent/consumable/vinegar = 2, /datum/reagent/consumable/capsaicin = 10, /datum/reagent/consumable/coco = 2)

/datum/chemical_reaction/drink/t_letter
	results = list(/datum/reagent/consumable/t_letter = 2)
	required_reagents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/tea = 1)

/datum/chemical_reaction/drink/bitters_soda
	results = list(/datum/reagent/consumable/ethanol/bitters_soda = 15)
	required_reagents = list(/datum/reagent/consumable/sodawater = 10, /datum/reagent/consumable/ice = 5, /datum/reagent/consumable/ethanol/bitters = 1)
