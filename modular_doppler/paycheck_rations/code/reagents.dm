/obj/item/reagent_containers/condiment/flour/small_ration
	name = "small flour sack"
	desc = "A maritime ration-sized portion of flour, containing just enough to make a single good loaf of bread to fuel the day."
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	list_reagents = list(/datum/reagent/consumable/flour = 15)

/obj/item/reagent_containers/condiment/rice/small_ration
	name = "small rice sack"
	desc = "A maritime ration-sized portion of rice, containing just enough to make the universe's saddest rice dish."
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	list_reagents = list(/datum/reagent/consumable/rice = 10)

/obj/item/reagent_containers/condiment/sugar/small_ration
	name = "small sugar sack"
	desc = "A maritime ration-sized portion of sugar, containing just enough to make the day just a tiny bit sweeter."
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	list_reagents = list(/datum/reagent/consumable/sugar = 10)

/obj/item/reagent_containers/condiment/small_ration_korta_flour
	name = "small korta flour sack"
	desc = "A maritime ration-sized portion of korta flour, containing just enough to make a single good loaf of bread to fuel the day."
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	icon_state = "flour_korta"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/korta_flour = 10)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/soymilk/small_ration
	name = "small soy milk"
	desc = "It's soy milk. White and nutritious goodness! This one is significantly smaller than normal cartons; just enough to make some rootdough with."
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	list_reagents = list(/datum/reagent/consumable/soymilk = 15)

/obj/item/reagent_containers/condiment/milk/small_ration
	name = "small milk"
	desc = "It's milk. White and nutritious goodness! This one is significantly smaller than normal cartons; just enough to make some cheese with."
	icon = 'modular_doppler/paycheck_rations/icons/food_containers.dmi'
	list_reagents = list(/datum/reagent/consumable/milk = 15)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny
	name = "tiny glass bottle"
	volume = 10

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/Initialize(mapload, vol)
	. = ..()
	transform = transform.Scale(0.75, 0.75)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/lime_juice
	name = "tiny lime juice bottle"
	desc = "A maritime ration-sized bottle of lime juice, containing enough to keep the scurvy away while on long voyages."
	list_reagents = list(/datum/reagent/consumable/limejuice = 10)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/vinegar
	name = "tiny vinegar bottle"
	desc = "A maritime ration-sized bottle of vinegar, containing enough to... Well, we're not entirely sure, but law mandates you're given this, so..."
	list_reagents = list(/datum/reagent/consumable/vinegar = 10)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/coffee
	name = "tiny coffee powder bottle"
	desc = "A maritime ration-sized bottle of coffee powder, containing enough to make a morning's brew."
	list_reagents = list(/datum/reagent/toxin/coffeepowder = 10)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/tea
	name = "tiny tea powder bottle"
	desc = "A maritime ration-sized bottle of tea powder, containing enough to make a morning's tea."
	list_reagents = list(/datum/reagent/toxin/teapowder = 10)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/honey
	name = "tiny honey bottle"
	desc = "A maritime ration-sized bottle of honey, a minuscule amount for a minuscule sweetening to your day."
	list_reagents = list(/datum/reagent/consumable/honey = 5)

/obj/item/reagent_containers/cup/glass/bottle/small/tiny/caramel
	name = "tiny caramel bottle"
	desc = "A maritime ration-sized bottle of caramel, in the past these used to be something called 'treacle', which was \
		the tar left over from refining sugar. Nowadays, governments are rich enough to just send caramel instead."
	list_reagents = list(/datum/reagent/consumable/caramel = 10)
