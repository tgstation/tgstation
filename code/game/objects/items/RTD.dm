#define CONSTRUCTION_TIME 0.4 SECONDS
#define DECONSTRUCTION_TIME 0.2 SECONDS

/obj/item/construction/rtd
	name = "rapid-tiling-device (RTD)"
	desc = "Used for fast placement & destruction of floor tiles."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rtd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_premium_price = PAYCHECK_COMMAND * 3
	max_matter = 350
	slot_flags = ITEM_SLOT_BELT
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING

	var/static/list/floor_designs = list(
		//what players will use most of the time
		"Conventional" = list(
			//The most common types
			"Standard" = list(
				new /datum/tile_info("Base", /obj/item/stack/tile/iron, tile_cost = 4),
				new /datum/tile_info("Small", /obj/item/stack/tile/iron/small, tile_cost = 3),
				new /datum/tile_info("Large", /obj/item/stack/tile/iron/large, tile_cost = 7),
				new /datum/tile_info("Diagonal", /obj/item/stack/tile/iron/diagonal, tile_cost = 5),
				new /datum/tile_info("Edge", /obj/item/stack/tile/iron/edge, tile_cost = 5),
				new /datum/tile_info("Half", /obj/item/stack/tile/iron/half, tile_cost = 5),
				new /datum/tile_info("Corner", /obj/item/stack/tile/iron/corner, tile_cost = 5),
				new /datum/tile_info("Textured", /obj/item/stack/tile/iron/textured, tile_cost = 5),
				new /datum/tile_info("Textured Edge", /obj/item/stack/tile/iron/textured_edge, tile_cost = 6),
				new /datum/tile_info("Textured Half", /obj/item/stack/tile/iron/textured_half, tile_cost = 6),
				new /datum/tile_info("Textured Corner", /obj/item/stack/tile/iron/textured_corner, tile_cost = 6),
				new /datum/tile_info("Textured Large", /obj/item/stack/tile/iron/textured_large, tile_cost = 6),
			),
			//Looks slightly transparent or faded
			"Translusent" = list(
				new /datum/tile_info("Smooth", /obj/item/stack/tile/iron/smooth, tile_cost = 4),
				new /datum/tile_info("Smooth Edge", /obj/item/stack/tile/iron/smooth_edge, tile_cost = 4),
				new /datum/tile_info("Smooth Half", /obj/item/stack/tile/iron/smooth_half, tile_cost = 4),
				new /datum/tile_info("Smooth Corner", /obj/item/stack/tile/iron/smooth_corner, tile_cost = 4),
				new /datum/tile_info("Smooth Large", /obj/item/stack/tile/iron/smooth_large, tile_cost = 7),
				new /datum/tile_info("Freezer", /obj/item/stack/tile/iron/freezer, tile_cost = 5),
				new /datum/tile_info("Showroom", /obj/item/stack/tile/iron/showroomfloor, tile_cost = 5),
				new /datum/tile_info("Glass", /obj/item/stack/tile/glass, tile_cost = 5),
				new /datum/tile_info("Reinforced Glass", /obj/item/stack/tile/rglass, tile_cost = 10)
			),
			//Uses eletricity or atleast thats i think these do
			"Circuit" = list(
				new /datum/tile_info("Recharge", /obj/item/stack/tile/iron/recharge_floor, tile_cost = 5),
				new /datum/tile_info("Solar Panel", /obj/item/stack/tile/iron/solarpanel, tile_cost = 5),
				new /datum/tile_info("Blue Circuit", /obj/item/stack/tile/circuit, tile_cost = 5),
				new /datum/tile_info("Green Circuit", /obj/item/stack/tile/circuit/green, tile_cost = 5),
				new /datum/tile_info("Green Circuit Anim", /obj/item/stack/tile/circuit/green/anim, tile_cost = 5),
				new /datum/tile_info("Red Circuit", /obj/item/stack/tile/circuit/red, tile_cost = 5),
				new /datum/tile_info("Red Circuit Anim", /obj/item/stack/tile/circuit/red/anim, tile_cost = 5),
			)
		),

		//Floors which are decorated
		"Decorated" = list(
			//Dark Colored tiles
			"Dark Colored" = list(
				new /datum/tile_info("Base", /obj/item/stack/tile/iron/dark, tile_cost = 4),
				new /datum/tile_info("Smooth Edge", /obj/item/stack/tile/iron/dark/smooth_edge, tile_cost = 4),
				new /datum/tile_info("Smooth Half", /obj/item/stack/tile/iron/dark/smooth_half, tile_cost = 4),
				new /datum/tile_info("Smooth Corner" ,/obj/item/stack/tile/iron/dark/smooth_corner, tile_cost = 4),
				new /datum/tile_info("Smooth Large", /obj/item/stack/tile/iron/dark/smooth_large, tile_cost = 7),
				new /datum/tile_info("Small", /obj/item/stack/tile/iron/dark/small, tile_cost = 4),
				new /datum/tile_info("Diagonal", /obj/item/stack/tile/iron/dark/diagonal, tile_cost = 4),
				new /datum/tile_info("Herringbone", /obj/item/stack/tile/iron/dark/herringbone, tile_cost = 4),
				new /datum/tile_info("Half Dark", /obj/item/stack/tile/iron/dark_side, tile_cost = 4),
				new /datum/tile_info("Dark Corner" ,/obj/item/stack/tile/iron/dark_corner, tile_cost = 4),
			),

			//White Colored tiles
			"White Colored" = list(
				new /datum/tile_info("Base", /obj/item/stack/tile/iron/white, tile_cost = 5),
				new /datum/tile_info("Smooth Edge", /obj/item/stack/tile/iron/white/smooth_edge, tile_cost = 5),
				new /datum/tile_info("Smooth Half", /obj/item/stack/tile/iron/white/smooth_half, tile_cost = 5),
				new /datum/tile_info("Smooth Corner", /obj/item/stack/tile/iron/white/smooth_corner, tile_cost = 5),
				new /datum/tile_info("Smooth Large", /obj/item/stack/tile/iron/white/smooth_large, tile_cost = 7),
				new /datum/tile_info("Small", /obj/item/stack/tile/iron/white/small, tile_cost = 5),
				new /datum/tile_info("Diagonal", /obj/item/stack/tile/iron/white/diagonal, tile_cost = 5),
				new /datum/tile_info("Herringbone", /obj/item/stack/tile/iron/white/herringbone, tile_cost = 5),
				new /datum/tile_info("Half White", /obj/item/stack/tile/iron/white_side, tile_cost = 5),
				new /datum/tile_info("White Corner", /obj/item/stack/tile/iron/white_corner, tile_cost = 5),
			),

			//Textured tiles
			"Textured" = list(
				new /datum/tile_info("Textured White", /obj/item/stack/tile/iron/white/textured, tile_cost = 5),
				new /datum/tile_info("Textured White Edge", /obj/item/stack/tile/iron/white/textured_edge, tile_cost = 5),
				new /datum/tile_info("Textured White Half", /obj/item/stack/tile/iron/white/textured_half, tile_cost = 5),
				new /datum/tile_info("Textured White Corner", /obj/item/stack/tile/iron/white/textured_corner, tile_cost = 5),
				new /datum/tile_info("Textured White Large", /obj/item/stack/tile/iron/white/textured_large, tile_cost = 7),
				new /datum/tile_info("Textured Dark", /obj/item/stack/tile/iron/dark/textured, tile_cost = 5),
				new /datum/tile_info("Textured Dark Edge", /obj/item/stack/tile/iron/dark/textured_edge, tile_cost = 5),
				new /datum/tile_info("Textured Dark Half", /obj/item/stack/tile/iron/dark/textured_half, tile_cost = 5),
				new /datum/tile_info("Textured Dark Corner", /obj/item/stack/tile/iron/dark/textured_corner, tile_cost = 5),
				new /datum/tile_info("Textured Dark Large", /obj/item/stack/tile/iron/dark/textured_large, tile_cost = 7),
			)
		),

		//Tiles which you decorate your home with
		"Interior" = list(
			//Common room tiles
			"Room" = list(
				new /datum/tile_info("Kitchen", /obj/item/stack/tile/iron/kitchen, tile_cost = 4),
				new /datum/tile_info("Kitchen Small", /obj/item/stack/tile/iron/kitchen/small, tile_cost = 4),
				new /datum/tile_info("Diagonal Kitchen", /obj/item/stack/tile/iron/kitchen/diagonal, tile_cost = 4),
				new /datum/tile_info("Chapel", /obj/item/stack/tile/iron/chapel, tile_cost = 4),
				new /datum/tile_info("Cafeteria", /obj/item/stack/tile/iron/cafeteria, tile_cost = 4),
				new /datum/tile_info("Grimy", /obj/item/stack/tile/iron/grimy, tile_cost = 5),
				new /datum/tile_info("Sepia", /obj/item/stack/tile/iron/sepia, tile_cost = 5),
				new /datum/tile_info("Herringbone", /obj/item/stack/tile/iron/kitchen/herringbone, tile_cost = 5),
			),

			//Culd have called it miscellaneous but nah too long
			"Pattern" = list(
				new /datum/tile_info("Terracotta", /obj/item/stack/tile/iron/terracotta, tile_cost = 5),
				new /datum/tile_info("Small", /obj/item/stack/tile/iron/terracotta/small, tile_cost = 5),
				new /datum/tile_info("Diagonal", /obj/item/stack/tile/iron/terracotta/diagonal, tile_cost = 5),
				new /datum/tile_info("Herrigone", /obj/item/stack/tile/iron/terracotta/herringbone, tile_cost = 5),
				new /datum/tile_info("Checkered", /obj/item/stack/tile/iron/checker, tile_cost = 5),
				new /datum/tile_info("Herringbone", /obj/item/stack/tile/iron/herringbone, tile_cost = 5),
			)
		)
	)

	var/root_category = "Conventional"
	var/design_category = "Standard"
	var/selected_dir = null
	var/datum/tile_info/selected_design
	var/list/design_overlays = list()

/datum/tile_info
	var/name
	var/obj/item/stack/tile/tile_type
	var/icon_state
	var/cost

/datum/tile_info/New(title, obj/item/stack/tile/type, tile_cost)
	name = title
	tile_type = type
	icon_state = initial(type.icon_state)
	cost = tile_cost

/datum/tile_info/proc/fill_ui_data(list/data, dir)
	data["selected_recipe"] = name
	data["selected_icon"] = get_icon_state(dir)

	var/tile_directions = GLOB.tile_rotations[initial(tile_type.singular_name)]
	if(tile_directions == null)
		data["selected_dir"] = null
		return

	data["tile_dirs"] = list()
	for(var/direction in tile_directions)
		var/text_dir = dir2text(direction)
		data["tile_dirs"] += text_dir
		if(data["selected_dir"] == null)
			data["selected_dir"] = dir ? dir2text(dir) : text_dir

/datum/tile_info/proc/is_valid_dir(dir)
	var/tile_directions = GLOB.tile_rotations[initial(tile_type.singular_name)]
	if(tile_directions == null)
		return FALSE
	return dir in tile_directions

/datum/tile_info/proc/default_dir()
	var/tile_directions = GLOB.tile_rotations[initial(tile_type.singular_name)]
	if(tile_directions == null)
		return null
	return tile_directions[1]

/datum/tile_info/proc/get_icon_state(selected_dir)
	return icon_state + (isnull(selected_dir) ? "" : "-[dir2text(selected_dir)]")

/datum/overlay_info
	var/icon/icon
	var/icon_state
	var/direction
	var/alpha
	var/color

//decompressing nessasary information required to re-create an mutable appearance
/datum/overlay_info/New(mutable_appearance/appearance)
	icon = appearance.icon
	icon_state = appearance.icon_state
	alpha = appearance.alpha
	direction = appearance.dir
	color = appearance.color

//re-create the appearance
/datum/overlay_info/proc/add_decal(turf/the_turf)
	the_turf.AddElement(/datum/element/decal, icon, icon_state, direction, null, null, alpha, color, null, FALSE, null)

/obj/item/construction/rtd/Initialize(mapload)
	. = ..()
	selected_design = floor_designs[root_category][design_category][1]
	update_appearance()

/obj/item/construction/rtd/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidTilingDevice", name)
		ui.open()


/obj/item/construction/rtd/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/rtd),
	)

/obj/item/construction/rtd/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/construction/rtd/ui_data(mob/user)
	var/list/data = ..()

	data["selected_root"] = root_category
	data["root_categories"] = list()
	for(var/category in floor_designs)
		data["root_categories"] += category
	data["selected_category"] = design_category

	selected_design.fill_ui_data(data, selected_dir)

	data["categories"] = list()
	for(var/sub_category as anything in floor_designs[root_category])
		var/list/target_category =  floor_designs[root_category][sub_category]

		var/list/designs = list() //initialize all designs under this category
		for(var/i in 1 to target_category.len)
			var/datum/tile_info/tile_design = target_category[i]
			designs += list(list("name" = tile_design.name, "icon" = tile_design.get_icon_state()))

		data["categories"] += list(list("category_name" = sub_category, "recipes" = designs))

	return data

/obj/item/construction/rtd/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(floor_designs[new_root] != null) //is a valid category
				root_category = new_root

		if("set_dir")
			var/direction = text2dir(params["dir"])
			if(!direction)
				return TRUE
			if(selected_design.is_valid_dir(direction))
				selected_dir = direction

		if("recipe")
			var/list/main_root = floor_designs[root_category]
			if(main_root == null)
				return TRUE
			var/list/sub_category = main_root[params["category_name"]]
			if(sub_category == null)
				return TRUE
			var/datum/tile_info/tile_design = sub_category[text2num(params["id"])]
			if(tile_design == null)
				return

			design_overlays.Cut()
			design_category = params["category_name"]
			selected_design = tile_design
			selected_dir = tile_design.default_dir()

	return TRUE

/obj/item/construction/rtd/proc/is_valid_plating(turf/open/floor)
	return floor.type == /turf/open/floor/plating ||  floor.type == /turf/open/floor/plating/reinforced

/obj/item/construction/rtd/afterattack(turf/open/floor/floor, mob/user)
	. = ..()
	if(!istype(floor) || !range_check(floor,user))
		return TRUE

	if(!is_valid_plating(floor)) //we infer what floor type it is if its not the usual plating
		user.Beam(floor, icon_state="light_beam", time = 5)
		for(var/main_root in floor_designs)
			for(var/sub_category in floor_designs[main_root])
				for(var/datum/tile_info/tile_design in floor_designs[main_root][sub_category])
					if(initial(tile_design.tile_type.turf_type) != floor.type)
						continue

					//store all information about this tile
					root_category = main_root
					design_category = sub_category
					selected_design = tile_design
					selected_dir = floor.dir
					if(!tile_design.is_valid_dir(selected_dir)) //selected_dir will mostly be SOUTH but if the tile design doesnt support it then make it null
						selected_dir = null
					balloon_alert(user, "tile changed to [selected_design.name]")

					//infer available overlays on the floor to recreate them to the best extent
					design_overlays.Cut()
					if(islist(floor.managed_overlays))
						for(var/mutable_appearance/appearance as anything in floor.managed_overlays)
							design_overlays += new /datum/overlay_info(appearance)
					else
						design_overlays += new /datum/overlay_info(floor.managed_overlays)
					return TRUE

		//can't infer floor type!
		balloon_alert(user, "design not supported!")
		return TRUE

	if(!checkResource(selected_design.cost, user))
		return TRUE

	//All special effect stuff
	user.Beam(floor, icon_state="light_beam", time = CONSTRUCTION_TIME)
	var/obj/effect/constructing_effect/rcd_effect = new(floor, CONSTRUCTION_TIME, RCD_FLOORWALL)
	if(!do_after(user, CONSTRUCTION_TIME, target = floor))
		rcd_effect.end_animation()
		return TRUE

	//consume resource only if tile was placed successfully
	var/obj/item/stack/tile/final_tile = new selected_design.tile_type(user.drop_location(), 1)
	final_tile.turf_dir = selected_dir
	var/turf/open/new_turf = final_tile.place_tile(floor, user)
	if(new_turf)
		//apply infered overlays
		for(var/datum/overlay_info/info in design_overlays)
			info.add_decal(new_turf)
		//use material
		useResource(selected_design.cost, user)
	rcd_effect.end_animation()

	return TRUE

/obj/item/construction/rtd/afterattack_secondary(turf/open/floor/floor, mob/user, proximity_flag, click_parameters)
	..()
	if(!istype(floor) || !range_check(floor,user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(is_valid_plating(floor)) //cant deconstruct normal plating thats the RCD's job
		balloon_alert(user, "nothing to deconstruct!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	//we only deconstruct floors which are supported by the RTD
	var/can_deconstruct = FALSE
	var/cost
	for(var/main_root in floor_designs)
		if(can_deconstruct)
			break
		for(var/sub_category in floor_designs[main_root])
			if(can_deconstruct)
				break
			for(var/datum/tile_info/tile_design in floor_designs[main_root][sub_category])
				if(initial(tile_design.tile_type.turf_type) == floor.type)
					cost = tile_design.cost
					can_deconstruct = TRUE
					break
	if(!can_deconstruct || !checkResource(cost * 0.7, user)) //no ballon alert for checkResource as it already spans an alert to chat
		if(!can_deconstruct)
			balloon_alert(user, "can't deconstruct this type!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	//find & collect all decals
	var/list/all_decals = list()
	for(var/obj/effect/decal in floor.contents)
		all_decals += decal
	//delete all decals
	for(var/obj/effect/decal in all_decals)
		floor.contents -= decal
		qdel(decal)

	//All special effect stuff
	user.Beam(floor, icon_state="light_beam", time = DECONSTRUCTION_TIME)
	var/obj/effect/constructing_effect/rcd_effect = new(floor, DECONSTRUCTION_TIME, RCD_FLOORWALL)
	if(!do_after(user, DECONSTRUCTION_TIME, target = floor))
		rcd_effect.end_animation()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/turf/new_turf = null
	if(floor.baseturfs == /turf/baseturf_bottom) //for turfs whose base is open space we put regular plating in its place else everyone dies
		new_turf = floor.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	else // for every other turf we scarp away exposing base turf underneath
		new_turf = floor.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(new_turf)
		useResource(cost * 0.7, user)
	rcd_effect.end_animation()

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/rtd/loaded
	matter = 350

/obj/item/construction/rtd/admin
	name = "admin RTD"
	max_matter = INFINITY
	matter = INFINITY

#undef CONSTRUCTION_TIME
#undef DECONSTRUCTION_TIME
