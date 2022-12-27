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

	var/root_category = "Conventional"
	var/design_category = "Standard"
	var/datum/tile_info/selected_design
	var/datum/tile_info/tile_design
	var/list/design_overlays = list()

/datum/tile_info
	var/name
	var/obj/item/stack/tile/tile_type
	var/icon_state
	var/cost

	var/ui_directional_data
	var/tile_directions
	var/selected_direction

/datum/tile_info/proc/set_info(list/design)
	name = design["name"]
	tile_type = design["type"]
	icon_state = initial(tile_type.icon_state)
	cost = design["tile_cost"]

	tile_directions = design["tile_rotate_dirs"]
	if(!tile_directions)
		selected_direction = null
		ui_directional_data = null
		return

	ui_directional_data = list()
	for(var/tile_direction in tile_directions)
		ui_directional_data += dir2text(tile_direction)
	selected_direction = tile_directions[1]

/datum/tile_info/proc/fill_ui_data(list/data)
	data["selected_recipe"] = name
	data["selected_icon"] = get_icon_state()

	if(tile_directions == null)
		data["selected_direction"] = null
		return

	data["tile_dirs"] = ui_directional_data
	data["selected_direction"] = selected_direction? "[dir2text(selected_direction)]" : null

/datum/tile_info/proc/set_direction(direction)
	if(tile_directions == null || !(direction in tile_directions))
		return
	selected_direction = direction

/datum/tile_info/proc/get_icon_state()
	return icon_state + (isnull(selected_direction) ? "" : "-[dir2text(selected_direction)]")

/datum/tile_info/proc/new_tile(loc)
	var/obj/item/stack/tile/final_tile = new tile_type(loc, 1)
	final_tile.turf_dir = selected_direction
	return final_tile

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
	selected_design = new
	tile_design = new

	selected_design.set_info(GLOB.floor_designs[root_category][design_category][1])
	update_appearance()

/obj/item/construction/rtd/Destroy()
	. = ..()
	qdel(selected_design)
	qdel(tile_design)
	clear_design_list()

//just to make sure nothing is left behind
/obj/item/construction/rtd/proc/clear_design_list()
	for(var/datum/overlay_info in design_overlays)
		qdel(overlay_info)
	design_overlays.Cut()

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
	var/floor_designs = GLOB.floor_designs

	data["selected_root"] = root_category
	data["root_categories"] = list()
	for(var/category in floor_designs)
		data["root_categories"] += category
	data["selected_category"] = design_category

	selected_design.fill_ui_data(data)

	data["categories"] = list()
	for(var/sub_category as anything in floor_designs[root_category])
		var/list/target_category =  floor_designs[root_category][sub_category]

		var/list/designs = list() //initialize all designs under this category
		for(var/i in 1 to target_category.len)
			tile_design.set_info(target_category[i])
			designs += list(list("name" = tile_design.name, "icon" = tile_design.get_icon_state()))

		data["categories"] += list(list("category_name" = sub_category, "recipes" = designs))

	return data

/obj/item/construction/rtd/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/floor_designs = GLOB.floor_designs
	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(floor_designs[new_root] != null) //is a valid category
				root_category = new_root

		if("set_dir")
			var/direction = text2dir(params["dir"])
			if(!direction)
				return TRUE
			selected_design.set_direction(direction)

		if("recipe")
			var/list/main_root = floor_designs[root_category]
			if(main_root == null)
				return TRUE
			var/list/sub_category = main_root[params["category_name"]]
			if(sub_category == null)
				return TRUE
			var/list/target_design = sub_category[text2num(params["id"])]
			if(target_design == null)
				return

			clear_design_list()
			design_category = params["category_name"]
			selected_design.set_info(target_design)

	return TRUE

/obj/item/construction/rtd/proc/is_valid_plating(turf/open/floor)
	return floor.type == /turf/open/floor/plating ||  floor.type == /turf/open/floor/plating/reinforced

/obj/item/construction/rtd/afterattack(turf/open/floor/floor, mob/user)
	. = ..()
	if(!istype(floor) || !range_check(floor,user))
		return TRUE

	var/floor_designs = GLOB.floor_designs
	if(!is_valid_plating(floor)) //we infer what floor type it is if its not the usual plating
		user.Beam(floor, icon_state="light_beam", time = 5)
		for(var/main_root in floor_designs)
			for(var/sub_category in floor_designs[main_root])
				for(var/list/design_info in floor_designs[main_root][sub_category])
					var/obj/item/stack/tile/tile_type = design_info["type"]
					if(initial(tile_type.turf_type) != floor.type)
						continue

					//infer available overlays on the floor to recreate them to the best extent
					clear_design_list()
					if(!isnull(floor.managed_overlays))
						if(islist(floor.managed_overlays))
							for(var/mutable_appearance/appearance as anything in floor.managed_overlays)
								design_overlays += new /datum/overlay_info(appearance)
						else
							design_overlays += new /datum/overlay_info(floor.managed_overlays)

					//store all information about this tile
					root_category = main_root
					design_category = sub_category
					selected_design.set_info(design_info)
					selected_design.set_direction(floor.dir)
					balloon_alert(user, "tile changed to [selected_design.name]")

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
	var/obj/item/stack/tile/final_tile = selected_design.new_tile(user.drop_location())
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

	var/floor_designs = GLOB.floor_designs

	//we only deconstruct floors which are supported by the RTD
	var/can_deconstruct = FALSE
	var/cost
	for(var/main_root in floor_designs)
		if(can_deconstruct)
			break
		for(var/sub_category in floor_designs[main_root])
			if(can_deconstruct)
				break
			for(var/list/design_info in floor_designs[main_root][sub_category])
				var/obj/item/stack/tile/tile_type = design_info["type"]
				if(initial(tile_type.turf_type) == floor.type)
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
	if(floor.baseturf_at_depth(1) == /turf/baseturf_bottom) //for turfs whose base is open space we put regular plating in its place else everyone dies
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
