////////////////////////////////////////////DONK POCKETS////////////////////////////////////////////

/obj/item/food/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2)
	microwaved_type = /obj/item/food/donkpocket/warm
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

//donk pockets cook quick... try not to burn them for using an unoptimal tool
/obj/item/food/donkpocket/MakeBakeable()
	AddComponent(/datum/component/bakeable, microwaved_type, rand(25 SECONDS, 30 SECONDS), TRUE, TRUE)

/obj/item/food/donkpocket/warm
	name = "warm Donk-pocket"
	desc = "The heated food of choice for the seasoned traitor."
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/omnizine = 6)
	microwaved_type = null
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN

///Override for fast-burning food
/obj/item/food/donkpocket/warm/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/badrecipe, rand(10 SECONDS, 15 SECONDS), FALSE)

/obj/item/food/dankpocket
	name = "\improper Dank-pocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	food_reagents = list(/datum/reagent/toxin/lipolicide = 3, /datum/reagent/drug/space_drugs = 3, /datum/reagent/consumable/nutriment = 4)
	tastes = list("meat" = 2, "dough" = 2)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/donkpocket/spicy
	name = "\improper Spicy-pocket"
	desc = "The classic snack food, now with a heat-activated spicy flair."
	icon_state = "donkpocketspicy"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/capsaicin = 2)
	microwaved_type = /obj/item/food/donkpocket/warm/spicy
	tastes = list("meat" = 2, "dough" = 2, "spice" = 1)
	foodtypes = GRAIN

/obj/item/food/donkpocket/warm/spicy
	name = "warm Spicy-pocket"
	desc = "The classic snack food, now maybe a bit too spicy."
	icon_state = "donkpocketspicy"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/omnizine = 2, /datum/reagent/consumable/capsaicin = 5)
	tastes = list("meat" = 2, "dough" = 2, "weird spices" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/teriyaki
	name = "\improper Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/soysauce = 2)
	microwaved_type = /obj/item/food/donkpocket/warm/teriyaki
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/warm/teriyaki
	name = "warm Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack, now steamy and warm."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/medicine/omnizine = 2, /datum/reagent/consumable/soysauce = 2)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/pizza
	name = "\improper Pizza-pocket"
	desc = "Delicious, cheesy and surprisingly filling."
	icon_state = "donkpocketpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/tomatojuice = 2)
	microwaved_type = /obj/item/food/donkpocket/warm/pizza
	tastes = list("meat" = 2, "dough" = 2, "cheese"= 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/warm/pizza
	name = "warm Pizza-pocket"
	desc = "Delicious, cheesy, and even better when hot."
	icon_state = "donkpocketpizza"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/omnizine = 2, /datum/reagent/consumable/tomatojuice = 2)
	tastes = list("meat" = 2, "dough" = 2, "melty cheese"= 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/honk
	name = "\improper Honk-pocket"
	desc = "The award-winning donk-pocket that won the hearts of clowns and humans alike."
	icon_state = "donkpocketbanana"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 4)
	microwaved_type = /obj/item/food/donkpocket/warm/honk
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtypes = GRAIN

/obj/item/food/donkpocket/warm/honk
	name = "warm Honk-pocket"
	desc = "The award-winning donk-pocket, now warm and toasty."
	icon_state = "donkpocketbanana"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 2, /datum/reagent/consumable/banana = 4, /datum/reagent/consumable/laughter = 6)
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtypes = GRAIN

/obj/item/food/donkpocket/berry
	name = "\improper Berry-pocket"
	desc = "A relentlessly sweet donk-pocket first created for use in Operation Dessert Storm."
	icon_state = "donkpocketberry"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/berryjuice = 3)
	microwaved_type = /obj/item/food/donkpocket/warm/berry
	tastes = list("dough" = 2, "jam" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/warm/berry
	name = "warm Berry-pocket"
	desc = "A relentlessly sweet donk-pocket, now warm and delicious."
	icon_state = "donkpocketberry"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/omnizine = 2, /datum/reagent/consumable/berryjuice = 3)
	tastes = list("dough" = 2, "warm jam" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/gondola
	name = "\improper Gondola-pocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least." //Only a monster would craft this.
	icon_state = "donkpocketgondola"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/gondola_mutation_toxin = 5)
	microwaved_type = /obj/item/food/donkpocket/warm/gondola
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtypes = GRAIN

/obj/item/food/donkpocket/warm/gondola
	name = "warm Gondola-pocket"
	desc = "The choice to use real gondola meat in the recipe is controversial, to say the least."
	icon_state = "donkpocketgondola"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/medicine/omnizine = 2, /datum/reagent/gondola_mutation_toxin = 10)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtypes = GRAIN
