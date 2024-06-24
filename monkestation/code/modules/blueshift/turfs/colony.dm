// Plastic panel walls, how colony of you

/turf/closed/wall/prefab_plastic
	name = "prefabricated wall"
	desc = "A conservatively built metal frame with plastic paneling covering a thin air-seal layer. \
		It's a little unnerving, but its better than nothing at all."
	icon = 'monkestation/code/modules/blueshift/icons/prefab_wall.dmi'
	icon_state = "prefab-0"
	base_icon_state = "prefab"
	can_engrave = FALSE
	girder_type = null
	hardness = 70
	slicing_duration = 5 SECONDS
	sheet_type = /obj/item/stack/sheet/plastic_wall_panel
	sheet_amount = 1

GLOBAL_LIST_INIT(plastic_wall_panel_recipes, list(
	new/datum/stack_recipe("prefabricated wall", /turf/closed/wall/prefab_plastic, time = 3 SECONDS,  one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("prefabricated window", /obj/structure/window/fulltile/colony_fabricator, time = 1 SECONDS,  one_per_turf = TRUE, on_solid_ground = TRUE, check_direction = TRUE, category = CAT_WINDOWS), \
	))

/obj/item/stack/sheet/plastic_wall_panel
	name = "plastic panels"
	singular_name = "plastic panel"
	desc = "What better material to make the walls of your soon to be home out of than sheets of flimsy plastic? \
		Metal? What are you talking about, metal walls, in this economy? May also be used to make structures other \
		than walls."
	icon = 'monkestation/code/modules/blueshift/icons/tiles_item.dmi'
	icon_state = "sheet-plastic"
	inhand_icon_state = "sheet-plastic"
	mats_per_unit = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	has_unique_girder = TRUE
	material_type = /datum/material/plastic
	merge_type = /obj/item/stack/sheet/plastic_wall_panel
	walltype = /turf/closed/wall/prefab_plastic

/obj/item/stack/sheet/plastic_wall_panel/examine(mob/user)
	. = ..()
	. += span_notice("You can build a prefabricated wall by right clicking on an empty floor.")

/obj/item/stack/sheet/plastic_wall_panel/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!isopenturf(target))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	var/turf/open/build_on = target
	if(!user.Adjacent(build_on))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(isgroundlessturf(build_on))
		user.balloon_alert(user, "can't place it here!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(build_on.is_blocked_turf())
		user.balloon_alert(user, "something is blocking the tile!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(get_amount() < 1)
		user.balloon_alert(user, "not enough material!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!do_after(user, 3 SECONDS, build_on))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(build_on.is_blocked_turf())
		user.balloon_alert(user, "something is blocking the tile!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!use(1))
		user.balloon_alert(user, "not enough material!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	build_on.PlaceOnTop(walltype, flags = CHANGETURF_INHERIT_AIR)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/stack/sheet/plastic_wall_panel/get_main_recipes()
	. = ..()
	. += GLOB.plastic_wall_panel_recipes

/obj/item/stack/sheet/plastic_wall_panel/ten
	amount = 10

/obj/item/stack/sheet/plastic_wall_panel/fifty
	amount = 50

// Stacks of floor tiles

/obj/item/stack/tile/catwalk_tile/colony_lathe
	icon = 'monkestation/code/modules/blueshift/icons/tiles_item.dmi'
	icon_state = "prefab_catwalk"
	mats_per_unit = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT)
	turf_type = /turf/open/floor/catwalk_floor/colony_fabricator
	merge_type = /obj/item/stack/tile/catwalk_tile/colony_lathe
	tile_reskin_types = null

/obj/item/stack/tile/iron/colony
	name = "prefab floor tiles"
	singular_name = "prefab floor tile"
	desc = "A stack of large floor tiles that are a common sight in frontier colonies and prefab buildings."
	icon = 'monkestation/code/modules/blueshift/icons/tiles_item.dmi'
	icon_state = "colony_grey"
	turf_type = /turf/open/floor/iron/colony
	merge_type = /obj/item/stack/tile/iron/colony
	tile_reskin_types = list(
		/obj/item/stack/tile/iron/colony,
		/obj/item/stack/tile/iron/colony/texture,
		/obj/item/stack/tile/iron/colony/bolts,
		/obj/item/stack/tile/iron/colony/white,
		/obj/item/stack/tile/iron/colony/white/texture,
		/obj/item/stack/tile/iron/colony/white/bolts,
	)

// Grated floor tile, for seeing wires under

/turf/open/floor/catwalk_floor/colony_fabricator
	icon = 'monkestation/code/modules/blueshift/icons/tiles.dmi'
	icon_state = "prefab_above"
	catwalk_type = "prefab"
	baseturfs = /turf/open/floor/plating
	floor_tile = /obj/item/stack/tile/catwalk_tile/colony_lathe

// "Normal" floor tiles

/obj/item/stack/tile/iron/colony/texture
	icon_state = "colony_grey_texture"
	turf_type = /turf/open/floor/iron/colony/texture

/obj/item/stack/tile/iron/colony/bolts
	icon_state = "colony_grey_bolts"
	turf_type = /turf/open/floor/iron/colony/bolts

/turf/open/floor/iron/colony
	icon = 'monkestation/code/modules/blueshift/icons/tiles.dmi'
	icon_state = "colony_grey"
	base_icon_state = "colony_grey"
	floor_tile = /obj/item/stack/tile/iron/colony
	tiled_dirt = FALSE

/turf/open/floor/iron/colony/texture
	icon_state = "colony_grey_texture"
	base_icon_state = "colony_grey_texture"
	floor_tile = /obj/item/stack/tile/iron/colony/texture

/turf/open/floor/iron/colony/bolts
	icon_state = "colony_grey_bolts"
	base_icon_state = "colony_grey_bolts"
	floor_tile = /obj/item/stack/tile/iron/colony/bolts

// White variants of the above tiles

/obj/item/stack/tile/iron/colony/white
	icon_state = "colony_white"
	turf_type = /turf/open/floor/iron/colony/white

/obj/item/stack/tile/iron/colony/white/texture
	icon_state = "colony_white_texture"
	turf_type = /turf/open/floor/iron/colony/white/texture

/obj/item/stack/tile/iron/colony/white/bolts
	icon_state = "colony_white_bolts"
	turf_type = /turf/open/floor/iron/colony/white/bolts

/turf/open/floor/iron/colony/white
	icon_state = "colony_white"
	base_icon_state = "colony_white"
	floor_tile = /obj/item/stack/tile/iron/colony/white

/turf/open/floor/iron/colony/white/texture
	icon_state = "colony_white_texture"
	base_icon_state = "colony_white_texture"
	floor_tile = /obj/item/stack/tile/iron/colony/white/texture

/turf/open/floor/iron/colony/white/bolts
	icon_state = "colony_white_bolts"
	base_icon_state = "colony_white_bolts"
	floor_tile = /obj/item/stack/tile/iron/colony/white/bolts
