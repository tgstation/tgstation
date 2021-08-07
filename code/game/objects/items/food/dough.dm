

/////////////////// Dough Ingredients ////////////////////////

/obj/item/food/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	microwaved_type = /obj/item/food/bread/plain
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("dough" = 1)
	foodtypes = GRAIN


// Dough + rolling pin = flat dough
/obj/item/food/dough/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/food/flatdough, 1, 30)

/obj/item/food/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	microwaved_type = /obj/item/food/pizzabread
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("dough" = 1)
	foodtypes = GRAIN

// sliceable into 3xdoughslices
/obj/item/food/flatdough/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/doughslice, 3, 30)

/obj/item/food/pizzabread
	name = "pizza bread"
	desc = "Add ingredients to make a pizza."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "pizzabread"
	food_reagents = list(/datum/reagent/consumable/nutriment = 7)
	tastes = list("bread" = 1)
	foodtypes = GRAIN

/obj/item/food/pizzabread/Initialize()
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/pizza/margherita, CUSTOM_INGREDIENT_ICON_SCATTER, max_ingredients = 12)

/obj/item/food/doughslice
	name = "dough slice"
	desc = "A slice of dough. Can be cooked into a bun."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	microwaved_type = /obj/item/food/bun
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("dough" = 1)
	foodtypes = GRAIN


/obj/item/food/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bun"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("bun" = 1) // the bun tastes of bun.
	foodtypes = GRAIN

/obj/item/food/bun/Initialize()
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/burger/empty, CUSTOM_INGREDIENT_ICON_STACKPLUSTOP)

/obj/item/food/cakebatter
	name = "cake batter"
	desc = "Cook it to get a cake."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "cakebatter"
	microwaved_type = /obj/item/food/cake/plain
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	tastes = list("batter" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/cakebatter/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, /obj/item/food/piedough, 1, 30)

/obj/item/food/piedough
	name = "pie dough"
	desc = "Cook it to get a pie."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "piedough"
	microwaved_type = /obj/item/food/pie/plain
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	tastes = list("dough" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/piedough/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/rawpastrybase, 3, 30)

/obj/item/food/rawpastrybase
	name = "raw pastry base"
	desc = "Must be cooked before use."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawpastrybase"
	microwaved_type = /obj/item/food/pastrybase
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("raw pastry" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/pastrybase
	name = "pastry base"
	desc = "A base for any self-respecting pastry."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "pastrybase"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("pastry" = 1)
	foodtypes = GRAIN | DAIRY
