/obj/item/stack/sheet/spaceship
	name = "spaceship plating"
	desc = "A metal sheet made out of a titanium alloy, rivited for use in spaceship walls."
	icon = 'modular_skyrat/modules/mapping/icons/unique/spaceships/shipstacks.dmi'
	icon_state = "sheet-spaceship"
	inhand_icon_state = "sheet-plastitaniumglass"
	singular_name = "spaceship plate"
	sheettype = "spaceship"
	merge_type = /obj/item/stack/sheet/spaceship
	walltype = /turf/closed/wall/mineral/titanium/spaceship

/obj/item/stack/sheet/spaceshipglass
	name = "spaceship window plates"
	desc = "A glass sheet made out of a titanium-silicate alloy, rivited for use in spaceship window frames."
	icon = 'modular_skyrat/modules/mapping/icons/unique/spaceships/shipstacks.dmi'
	icon_state = "sheet-spaceshipglass"
	inhand_icon_state = "sheet-plastitaniumglass"
	singular_name = "spaceship window plate"
	merge_type = /obj/item/stack/sheet/spaceshipglass

GLOBAL_LIST_INIT(spaceshipglass_recipes, list(
	new/datum/stack_recipe("spaceship window", /obj/structure/window/reinforced/shuttle/spaceship/unanchored, 2, time = 4 SECONDS, on_floor = TRUE, window_checks = TRUE), \
	))

/obj/item/stack/sheet/spaceshipglass/get_main_recipes()
	. = ..()
	. += GLOB.spaceshipglass_recipes
