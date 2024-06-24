// Wooden shelves that force items placed on them to be visually placed them

/obj/structure/rack/wooden
	name = "shelf"
	icon_state = "shelf_wood"
	icon = 'monkestation/code/modules/blueshift/icons/storage.dmi'
	resistance_flags = FLAMMABLE

/obj/structure/rack/wooden/MouseDrop_T(obj/object, mob/user, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return

	object.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size / 3), world.icon_size / 3)
	object.pixel_y = text2num(LAZYACCESS(modifiers, ICON_Y)) > 16 ? 10 : -4

/obj/structure/rack/wrench_act_secondary(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/rack/wooden/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/clay(drop_location(), 5)
	deconstruct(TRUE)
	return

/obj/structure/rack/wooden/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 2)
	return ..()

// Barrel but it works like a crate

/obj/structure/closet/crate/wooden/storage_barrel
	name = "storage barrel"
	desc = "This barrel can't hold liquids, it can just hold things inside of it however!"
	icon_state = "barrel"
	base_icon_state = "barrel"
	icon = 'monkestation/code/modules/blueshift/icons/storage.dmi'
	resistance_flags = FLAMMABLE
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	cutting_tool = /obj/item/crowbar

/obj/machinery/smartfridge/wooden
	name = "Debug Wooden Smartfridge"
	desc = "You shouldn't be seeing this!"
	icon = 'monkestation/code/modules/blueshift/icons/storage.dmi'
	icon_state = "producebin"
	resistance_flags = FLAMMABLE
	base_build_path = /obj/machinery/smartfridge/wooden
	base_icon_state = "produce"
	use_power = NO_POWER_USE
	light_power = 0
	idle_power_usage = 0
	circuit = null
	has_emissive = FALSE
	can_atmos_pass = ATMOS_PASS_YES
	visible_contents = TRUE

/obj/machinery/smartfridge/wooden/Initialize(mapload)
	. = ..()
	if(type == /obj/machinery/smartfridge/wooden) // don't even let these prototypes exist
		return INITIALIZE_HINT_QDEL

// previously NO_DECONSTRUCTION
/obj/machinery/smartfridge/wooden/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/smartfridge/wooden/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
	deconstruct(TRUE)
	return

/*
/obj/machinery/smartfridge/wooden/structure_examine()
	. = span_info("The whole rack can be [EXAMINE_HINT("pried")] apart.")
*/

/obj/machinery/smartfridge/wooden/produce_bin
	name = "produce bin"
	desc = "A wooden hamper, used to hold plant products and try to keep them safe from pests."
	base_build_path = /obj/machinery/smartfridge/wooden/produce_bin

/obj/machinery/smartfridge/wooden/produce_bin/accept_check(obj/item/item_to_check)
	var/static/list/accepted_items = list(
		/obj/item/food/grown,
		/obj/item/grown,
		/obj/item/graft,
	)

	return is_type_in_list(item_to_check, accepted_items)

/obj/machinery/smartfridge/wooden/seed_shelf
	name = "Seedshelf"
	desc = "A wooden shelf, used to hold seeds preventing them from germinating early."
	icon_state = "seedshelf"
	base_build_path = /obj/machinery/smartfridge/wooden/seed_shelf
	base_icon_state = "seed"

/obj/machinery/smartfridge/wooden/seedshelf/wooden/accept_check(obj/item/weapon)
	return istype(weapon, /obj/item/seeds)

/obj/machinery/smartfridge/wooden/ration_shelf
	name = "Ration shelf"
	desc = "A wooden shelf, used to store food... preferably preserved."
	icon_state = "rationshelf"
	base_build_path = /obj/machinery/smartfridge/wooden/ration_shelf
	base_icon_state = "ration"

/obj/machinery/smartfridge/wooden/rationshelf/wooden/accept_check(obj/item/weapon)
	return (IS_EDIBLE(weapon) || (istype(weapon,/obj/item/reagent_containers/cup/bowl) && length(weapon.reagents?.reagent_list)))

/obj/machinery/smartfridge/wooden/produce_display
	name = "Produce display"
	desc = "A wooden table with awning, used to display produce items."
	icon_state = "producedisplay"
	base_build_path = /obj/machinery/smartfridge/wooden/produce_display
	base_icon_state = "nonfood"

/obj/machinery/smartfridge/wooden/producedisplay/accept_check(obj/item/weapon)
	return (istype(weapon, /obj/item/grown) || istype(weapon, /obj/item/bouquet) || istype(weapon, /obj/item/clothing/head/costume/garland))


GLOBAL_LIST_INIT(monke_wood_recipes, list(
	new/datum/stack_recipe("sauna oven", /obj/structure/sauna_oven, 30, time = 1.5 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_ENTERTAINMENT),
	new/datum/stack_recipe("large wooden mortar", /obj/structure/large_mortar, 10, time = 3 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_TOOLS),
	new/datum/stack_recipe("wooden cutting board", /obj/item/cutting_board, 5, time = 2 SECONDS, category = CAT_TOOLS),
	new/datum/stack_recipe("wooden shelf", /obj/structure/rack/wooden, 2, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("seed shelf", /obj/machinery/smartfridge/wooden/seed_shelf, 10, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("produce bin", /obj/machinery/smartfridge/wooden/produce_bin, 10, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("produce display", /obj/machinery/smartfridge/wooden/produce_display, 10, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("ration shelf", /obj/machinery/smartfridge/wooden/ration_shelf, 10, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("storage barrel", /obj/structure/closet/crate/wooden/storage_barrel, 4, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("worm barrel", /obj/structure/wormfarm, 5, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_TOOLS),
	new/datum/stack_recipe("gutlunch trough", /obj/structure/ore_container/gutlunch_trough, 5, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("sturdy wooden fence", /obj/structure/railing/wooden_fencing, 5, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("sturdy wooden fence gate", /obj/structure/railing/wooden_fencing/gate, 5, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
	new/datum/stack_recipe("large wooden gate", /obj/structure/mineral_door/wood/large_gate, 10, time = 5 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE),
))


/obj/item/stack/sheet/mineral/wood/get_main_recipes()
	. = ..()
	. += GLOB.monke_wood_recipes

GLOBAL_LIST_INIT(monke_iron_recipes, list(
	new/datum/stack_recipe("stack of rails", /obj/item/stack/rail_track, res_amount = 5, max_res_amount = 5, time = 0, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("minecart", /obj/vehicle/ridden/rail_cart, 10, time = 3 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_MISC),
	new/datum/stack_recipe("forge", /obj/structure/reagent_forge, 10, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_TOOLS),
	new/datum/stack_recipe("throwing wheel", /obj/structure/throwing_wheel, 10, time = 2 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_TOOLS),
))

/obj/item/stack/sheet/iron/get_main_recipes()
	. = ..()
	. += GLOB.monke_iron_recipes
