/obj/item/food/grown/cherries/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/cherry, 3, 1 SECONDS, table_required = FALSE, screentip_verb = "Slice")

/obj/item/food/grown/citrus/lime/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/orange, 3, 1 SECONDS, table_required = FALSE, screentip_verb = "Slice")


/obj/item/food/grown/citrus/orange/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/orange, 3, 1 SECONDS, table_required = FALSE, screentip_verb = "Slice")

/obj/item/food/grown/citrus/lemon/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/garnish/lemon, 3, 1 SECONDS, table_required = FALSE, screentip_verb = "Slice")
