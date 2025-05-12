
/*
 * Express-only groceries console for the cantina.
 */
/obj/machinery/computer/order_console/cook/cantina
	name = "Express Produce Console"
	desc = "An interface for ordering fresh produce and other. Costs a bit to get things out here, \
	but it keeps the regulars from complaining and the bartenders from complaining more."
	forced_express = TRUE
	express_cost_multiplier = 1 // We can only order express.
	blackbox_key = "cantina_chef"


/*
 * Artificial Sweeteners.
 * (Poisons for the bartender.)
 */

/obj/item/reagent_containers/cup/bottle/cantina_tetrodotoxin
	name = "tetrodotoxin bottle"
	desc = "A small bottle. Contains tetrodotoxin."
	list_reagents = list(/datum/reagent/toxin/tetrodotoxin = 30)

/obj/item/reagent_containers/cup/bottle/cantina_zombiepowder
	name = "zombie powder bottle"
	desc = "A small bottle. Contains zombie powder."
	list_reagents = list(/datum/reagent/toxin/zombiepowder = 30)

/obj/item/reagent_containers/cup/bottle/cantina_mutetoxin
	name = "mute toxin bottle"
	desc = "A small bottle. Contains mute toxin."
	list_reagents = list(/datum/reagent/toxin/mutetoxin = 30)

/obj/item/reagent_containers/cup/bottle/cantina_itching_powder
	name = "itching powder bottle"
	desc = "A small bottle. Contains itching powder."
	list_reagents = list(/datum/reagent/toxin/itching_powder = 30)

/obj/item/storage/box/cantina_sweeteners
	name = "box of artificial sweeteners"
	desc = "A bartender's secret to keeping the rowdiest customers at bay."
	icon_state = "syndiebox"
	illustration = "beaker"

/obj/item/storage/box/cantina_sweeteners/PopulateContents()
	new /obj/item/reagent_containers/cup/bottle/cantina_mutetoxin(src)
	new /obj/item/reagent_containers/cup/bottle/cantina_itching_powder(src)
	new /obj/item/reagent_containers/cup/bottle/leadacetate(src)
	new /obj/item/reagent_containers/cup/bottle/cyanide(src)
	new /obj/item/reagent_containers/cup/bottle/cantina_tetrodotoxin(src)
	new /obj/item/reagent_containers/cup/bottle/cantina_zombiepowder(src)
	new /obj/item/storage/pill_bottle/painkiller(src)


/*
 * Fridges for the cantina freezer, and objects to spawn in them.
 */

/// Egg box containing chocolate eggs instead.
/obj/item/storage/fancy/egg_box/cantina_chocolate
	spawn_type = /obj/item/food/chocolateegg

/// Pre-dead cantina chicken (for revival by the bartender).
/mob/living/basic/chicken/cantina
	name = "The Unregistered Dragon"

/mob/living/basic/chicken/cantina/Initialize(mapload)
	. = ..()
	death(FALSE)

/// 'Fresh Eggs' fridge. Joke, get the resources from express console.
/obj/structure/closet/secure_closet/freezer/cantina_eggs
	name = "egg fridge"
	desc = "There's a note on the fridge... It mentions something about having difficulty finding \
	'fresh eggs' and 'chocolate', and a lazarus pen in the bartender's closet. Wonder what that's all about."
	req_access = null

/obj/structure/closet/secure_closet/freezer/cantina_eggs/PopulateContents()
	..()
	new /obj/item/storage/fancy/egg_box/cantina_chocolate(src)
	new /obj/item/storage/fancy/egg_box/cantina_chocolate(src)
	new /mob/living/basic/chicken/cantina(src)

/// Meat fridge that additionally contains monkey cubes.
/obj/structure/closet/secure_closet/freezer/cantina_meat
	name = "meat fridge"
	desc = "There's a note on the fridge... It mentions something about using 'denser' storage \
	to make up for the egg fridge, and needing to 'apply water'. Wonder what that's all about."
	req_access = null

/obj/structure/closet/secure_closet/freezer/cantina_meat/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/food/meat/slab/monkey(src)
	new /obj/item/storage/box/monkeycubes(src)


/*
 * Cantina Fax Machine.
 * Can be made visible to the network, but isn't by default.
 */

/obj/machinery/fax/cantina
	name = "Unregistered Fax Machine"
	desc = "Bluespace technologies on the application of evil bureaucracy. \
	This one has been customized to block its network-visibility as needed."
	obj_flags = parent_type::obj_flags | EMAGGED
	visible_to_network = FALSE

/obj/machinery/fax/cantina/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "[visible_to_network ? "H" : "Unh"]ide from network"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/fax/cantina/click_alt(mob/living/user)
	visible_to_network = !visible_to_network
	balloon_alert(user, (visible_to_network ? "fax unhidden" : "fax hidden"))
	return CLICK_ACTION_SUCCESS
