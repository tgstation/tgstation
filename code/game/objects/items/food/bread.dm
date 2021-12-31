
/obj/item/food/bread
	icon = 'icons/obj/food/burgerbread.dmi'
	max_volume = 80
	tastes = list("bread" = 10)
	foodtypes = GRAIN
	eat_time = 3 SECONDS

/obj/item/food/bread/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)
	AddComponent(/datum/component/food_storage)

/obj/item/food/breadslice
	icon = 'icons/obj/food/burgerbread.dmi'
	slot_flags = ITEM_SLOT_HEAD
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	eat_time = 0.5 SECONDS
	atom_size = ITEM_SIZE_SMALL

/obj/item/food/breadslice/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/bread/plain
	name = "bread"
	desc = "Some plain old earthen bread."
	icon_state = "bread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("bread" = 10)
	foodtypes = GRAIN
	atom_size = ITEM_SIZE_SMALL
	venue_value = FOOD_PRICE_CHEAP
	burns_in_oven = TRUE

/obj/item/food/bread/plain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/bread/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/bread/plain/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/plain, 5, 30)

/obj/item/food/breadslice/plain
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	foodtypes = GRAIN
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	venue_value = FOOD_PRICE_TRASH
	decomp_type = /obj/item/food/breadslice/moldy

/obj/item/food/breadslice/plain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_STACK)

/obj/item/food/breadslice/plain/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/food/griddle_toast, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/breadslice/moldy
	name = "moldy 'bread' slice"
	desc = "Entire stations have been ripped apart over arguing whether this is still good to eat."
	icon_state = "moldybreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/mold = 10)
	tastes = list("decaying fungus" = 1)
	foodtypes = GROSS
	preserved_food = TRUE

/obj/item/food/breadslice/moldy/bacteria
	name = "bacteria rich moldy 'bread' slice"
	desc = "Something (possibly necroyeast) has caused this bread to rise in a macabre state of unlife. It lurchs about when unattended. You might want to locate a priest if you see this. Or maybe a flamethrower."

/obj/item/food/breadslice/moldy/bacteria/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2, 4), 25)


/obj/item/food/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 12)
	tastes = list("bread" = 10, "meat" = 10)
	foodtypes = GRAIN | MEAT
	venue_value = FOOD_PRICE_CHEAP


/obj/item/food/bread/meat/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/meat, 5, 30)

/obj/item/food/breadslice/meat
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	foodtypes = GRAIN | MEAT
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/nutriment/protein = 2.4)

/obj/item/food/bread/sausage
	name = "sausagebread loaf"
	desc = "Dont think too much about it."
	icon_state = "sausagebread"
	foodtypes = GRAIN | MEAT
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 12)
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/food/bread/sausage/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/sausage, 5, 30)

/obj/item/food/breadslice/sausage
	name = "sausagebread slice"
	desc = "A slice of delicious sausagebread."
	icon_state = "sausagebreadslice"
	foodtypes = GRAIN | MEAT
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/nutriment/protein = 2.4)
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/food/bread/xenomeat
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 15)
	tastes = list("bread" = 10, "acid" = 10)
	foodtypes = GRAIN | MEAT

/obj/item/food/bread/xenomeat/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/xenomeat, 5, 30)

/obj/item/food/breadslice/xenomeat
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/nutriment/protein = 3)
	foodtypes = GRAIN | MEAT

/obj/item/food/bread/spidermeat
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/toxin = 15, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 12)
	tastes = list("bread" = 10, "cobwebs" = 5)
	foodtypes = GRAIN | MEAT | TOXIC

/obj/item/food/bread/spidermeat/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/spidermeat, 5, 30)

/obj/item/food/breadslice/spidermeat
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "spidermeatslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtypes = GRAIN | MEAT | TOXIC

/obj/item/food/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/banana = 20)
	tastes = list("bread" = 10) // bananjuice will also flavour
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/banana/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/banana, 5, 30)

/obj/item/food/breadslice/banana
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 4)
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/tofu
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10, /datum/reagent/consumable/nutriment/protein = 10)
	tastes = list("bread" = 10, "tofu" = 10)
	foodtypes = GRAIN | VEGETABLES
	venue_value = FOOD_PRICE_TRASH

/obj/item/food/bread/tofu/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/tofu, 5, 30)

/obj/item/food/breadslice/tofu
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/bread/creamcheese
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtypes = GRAIN | DAIRY

/obj/item/food/bread/creamcheese/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/creamcheese, 5, 30)

/obj/item/food/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/food/bread/empty
	name = "bread"
	icon_state = "tofubread"
	desc = "It's bread, customized to your wildest dreams."

/obj/item/food/bread/empty/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/empty, 5, 30)

/obj/item/food/bread/mimana
	name = "mimana bread"
	desc = "Best eaten in silence."
	icon_state = "mimanabread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/consumable/nothing = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("bread" = 10, "silence" = 10)
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/mimana/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/breadslice/mimana, 5, 30)

/obj/item/food/breadslice/mimana
	name = "mimana bread slice"
	desc = "A slice of silence!"
	icon_state = "mimanabreadslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GRAIN | FRUIT

// What you get from cutting a custom bread. Different from custom sliced bread.
/obj/item/food/breadslice/empty
	name = "bread slice"
	icon_state = "tofubreadslice"
	foodtypes = GRAIN
	desc = "It's a slice of bread, customized to your wildest dreams."

/obj/item/food/breadslice/empty/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	inhand_icon_state = "baguette"
	worn_icon_state = "baguette"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 3)
	bite_consumption = 3
	atom_size = ITEM_SIZE_NORMAL
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	attack_verb_continuous = list("touche's")
	attack_verb_simple = list("touche")
	tastes = list("bread" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/garlicbread
	name = "garlic bread"
	desc = "Alas, it is limited."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "garlicbread"
	inhand_icon_state = "garlicbread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/garlic = 2)
	bite_consumption = 3
	tastes = list("bread" = 1, "garlic" = 1, "butter" = 1)
	foodtypes = GRAIN
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bite_consumption = 2

/obj/item/food/deepfryholder/MakeEdible()
	AddComponent(/datum/component/edible,\
			initial_reagents = food_reagents,\
			food_flags = food_flags,\
			foodtypes = foodtypes,\
			volume = max_volume,\
			eat_time = eat_time,\
			tastes = tastes,\
			eatverbs = eatverbs,\
			bite_consumption = bite_consumption,\
			on_consume = CALLBACK(src, .proc/On_Consume))


/obj/item/food/deepfryholder/Initialize(mapload, obj/item/fried)
	if(!fried)
		stack_trace("A deepfried object was created with no fried target")
		return INITIALIZE_HINT_QDEL
	. = ..()
	name = fried.name //We'll determine the other stuff when it's actually removed
	appearance = fried.appearance
	layer = initial(layer)
	plane = initial(plane)
	lefthand_file = fried.lefthand_file
	righthand_file = fried.righthand_file
	inhand_icon_state = fried.inhand_icon_state
	desc = fried.desc
	set_size(fried.atom_size, force = TRUE)
	slowdown = fried.slowdown
	equip_delay_self = fried.equip_delay_self
	equip_delay_other = fried.equip_delay_other
	strip_delay = fried.strip_delay
	species_exception = fried.species_exception
	item_flags = fried.item_flags
	obj_flags = fried.obj_flags
	inhand_x_dimension = fried.inhand_x_dimension
	inhand_y_dimension = fried.inhand_y_dimension

	if(!(SEND_SIGNAL(fried, COMSIG_ITEM_FRIED, src) & COMSIG_FRYING_HANDLED)) //If frying is handled by signal don't do the defaault behavior.
		fried.forceMove(src)


/obj/item/food/deepfryholder/Destroy()
	if(contents)
		QDEL_LIST(contents)
	return ..()

/obj/item/food/deepfryholder/proc/On_Consume(eater, feeder)
	if(contents)
		QDEL_LIST(contents)


/obj/item/food/deepfryholder/proc/fry(cook_time = 30)
	switch(cook_time)
		if(0 to 15)
			add_atom_colour(rgb(166, 103, 54), FIXED_COLOUR_PRIORITY)
			name = "lightly-fried [name]"
			desc = "[desc] It's been lightly fried in a deep fryer."
		if(16 to 49)
			add_atom_colour(rgb(103, 63, 24), FIXED_COLOUR_PRIORITY)
			name = "fried [name]"
			desc = "[desc] It's been fried, increasing its tastiness value by [rand(1, 75)]%."
		if(50 to 59)
			add_atom_colour(rgb(63, 23, 4), FIXED_COLOUR_PRIORITY)
			name = "deep-fried [name]"
			desc = "[desc] Deep-fried to perfection."
		if(60 to INFINITY)
			add_atom_colour(rgb(33, 19, 9), FIXED_COLOUR_PRIORITY)
			name = "\proper the physical manifestation of the very concept of fried foods"
			desc = "A heavily-fried... something. Who can tell anymore?"
	foodtypes |= FRIED

/obj/item/food/butterbiscuit
	name = "butter biscuit"
	desc = "Well butter my biscuit!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterbiscuit"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter" = 1, "biscuit" = 1)
	foodtypes = GRAIN | BREAKFAST
	atom_size = ITEM_SIZE_SMALL
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/butterdog
	name = "butterdog"
	desc = "Made from exotic butters."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter" = 1, "exotic butter" = 1)
	foodtypes = GRAIN | DAIRY
	atom_size = ITEM_SIZE_SMALL

/obj/item/food/butterdog/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)
