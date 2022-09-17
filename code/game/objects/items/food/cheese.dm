/**
 * # Abstract cheese class
 *
 * Everything that is a subclass of this counts as cheese for regal rats.
 */
/obj/item/food/cheese
	name = "the concept of cheese"
	desc = "This probably shouldn't exist."
	tastes = list("cheese" = 1)
	foodtypes = DAIRY
	/// used to determine how much health rats/regal rats recover when they eat it.
	var/rat_heal = 0

/obj/item/food/cheese/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_RAT_INTERACT, .proc/on_rat_eat)

/obj/item/food/cheese/proc/on_rat_eat(datum/source, mob/living/simple_animal/hostile/regalrat/king)
	SIGNAL_HANDLER

	king.cheese_heal(src, rat_heal, span_green("You eat [src], restoring some health."))

/obj/item/food/cheese/wedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 10

/obj/item/food/cheese/wheel
	name = "cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 5) //Hard cheeses contain about 25% protein
	w_class = WEIGHT_CLASS_NORMAL
	rat_heal = 35

/obj/item/food/cheese/wheel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/food_storage)

/obj/item/food/cheese/wheel/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cheese/wedge, 5, 3 SECONDS, table_required = TRUE)

/obj/item/food/cheese/wheel/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/baked_cheese, rand(20 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/cheese/royal
	name = "royal cheese"
	desc = "Ascend the throne. Consume the wheel. Feel the POWER."
	icon_state = "royalcheese"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/gold = 20, /datum/reagent/toxin/mutagen = 5)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("cheese" = 4, "royalty" = 1)
	rat_heal = 70

//Curd cheese, a general term which I will now proceed to stretch as thin as the toppings on a supermarket sandwich:
//I'll use it as a substitute for ricotta, cottage cheese and quark, as well as any other non-aged, soft grainy cheese
/obj/item/food/cheese/curd_cheese
	name = "curd cheese"
	desc = "Known by many names throughout human cuisine, curd cheese is useful for a wide variety of dishes."
	icon_state = "curd_cheese"
	microwaved_type = /obj/item/food/cheese/cheese_curds
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/cream = 1)
	tastes = list("cream" = 1, "cheese" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 35

/obj/item/food/cheese/cheese_curds
	name = "cheese curds"
	desc = "Not to be mistaken for curd cheese. Tasty deep fried."
	icon_state = "cheese_curds"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	tastes = list("cheese" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 35

/obj/item/food/cheese/cheese_curds/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dryable,  /obj/item/food/cheese/firm_cheese)

/obj/item/food/cheese/firm_cheese
	name = "firm cheese"
	desc = "Firm aged cheese, similar in texture to firm tofu. Due to its lack of moisture it's particularly useful for cooking with, as it doesn't melt easily."
	icon_state = "firm_cheese"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	tastes = list("aged cheese" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 35

/obj/item/food/cheese/firm_cheese/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cheese/firm_cheese_slice, 3, 3 SECONDS)

/obj/item/food/cheese/firm_cheese_slice
	name = "firm cheese slice"
	desc = "A slice of firm cheese. Perfect for grilling or making into delicious pesto."
	icon_state = "firm_cheese_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	tastes = list("aged cheese" = 1)
	foodtypes = DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	rat_heal = 10

/obj/item/food/cheese/firm_cheese_slice/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/food/grilled_cheese, rand(25 SECONDS, 35 SECONDS), TRUE, TRUE)

/obj/item/food/cheese/mozzarella
	name = "mozzarella cheese"
	desc = "Delicious, creamy, and cheesy, all in one simple package."
	icon_state = "mozzarella"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	tastes = list("mozzarella" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL
	rat_heal = 10
