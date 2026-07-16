//RAPID DECORATION DEVICE

/// Multiplier applied to cost when using RDD — each decoration costs this many matter units
#define RDD_COST_MULTIPLIER 1

/// All decoration designs available in the RDD
GLOBAL_LIST_INIT(rdd_designs, list(
	"Grasses" = list(
		list("name" = "Plastic Grass Patch", "path" = /obj/structure/decoration/grass/first),
		list("name" = "Plastic Grass Patch (Alt)", "path" = /obj/structure/decoration/grass/second),
		list("name" = "Plastic Grass Patch (Alt 2)", "path" = /obj/structure/decoration/grass/third),
		list("name" = "Plastic Grass Patch (Random)", "path" = /obj/structure/decoration/grass/style_random),
		list("name" = "Plastic Brown Grass", "path" = /obj/structure/decoration/grass/brown/first),
		list("name" = "Plastic Brown Grass (Alt)", "path" = /obj/structure/decoration/grass/brown/second),
		list("name" = "Plastic Brown Grass (Alt 2)", "path" = /obj/structure/decoration/grass/brown/third),
		list("name" = "Plastic Brown Grass (Random)", "path" = /obj/structure/decoration/grass/brown/style_random),
		list("name" = "Plastic Jungle Grass", "path" = /obj/structure/decoration/jungle_grass/first),
		list("name" = "Plastic Jungle Grass (Alt)", "path" = /obj/structure/decoration/jungle_grass/second),
		list("name" = "Plastic Jungle Grass (Alt 2)", "path" = /obj/structure/decoration/jungle_grass/third),
		list("name" = "Plastic Jungle Grass (Alt 3)", "path" = /obj/structure/decoration/jungle_grass/fourth),
		list("name" = "Plastic Jungle Grass (Alt 4)", "path" = /obj/structure/decoration/jungle_grass/fifth),
		list("name" = "Plastic Jungle Grass (Random)", "path" = /obj/structure/decoration/jungle_grass/style_random),
		list("name" = "Plastic Jungle Grass B", "path" = /obj/structure/decoration/jungle_grass/b/first),
		list("name" = "Plastic Jungle Grass B (Alt)", "path" = /obj/structure/decoration/jungle_grass/b/second),
		list("name" = "Plastic Jungle Grass B (Alt 2)", "path" = /obj/structure/decoration/jungle_grass/b/third),
		list("name" = "Plastic Jungle Grass B (Alt 3)", "path" = /obj/structure/decoration/jungle_grass/b/fourth),
		list("name" = "Plastic Jungle Grass B (Alt 4)", "path" = /obj/structure/decoration/jungle_grass/b/fifth),
		list("name" = "Plastic Jungle Grass B (Random)", "path" = /obj/structure/decoration/jungle_grass/b/style_random),
	),
	"Bushes" = list(
		list("name" = "Plastic Bush", "path" = /obj/structure/decoration/bush/first),
		list("name" = "Plastic Bush (Alt)", "path" = /obj/structure/decoration/bush/second),
		list("name" = "Plastic Bush (Alt 2)", "path" = /obj/structure/decoration/bush/third),
		list("name" = "Plastic Bush (Alt 3)", "path" = /obj/structure/decoration/bush/fourth),
		list("name" = "Plastic Bush (Random)", "path" = /obj/structure/decoration/bush/style_random),
		list("name" = "Plastic Reeds", "path" = /obj/structure/decoration/bush/reed/first),
		list("name" = "Plastic Reeds (Alt)", "path" = /obj/structure/decoration/bush/reed/second),
		list("name" = "Plastic Reeds (Alt 2)", "path" = /obj/structure/decoration/bush/reed/third),
		list("name" = "Plastic Reeds (Alt 3)", "path" = /obj/structure/decoration/bush/reed/fourth),
		list("name" = "Plastic Reeds (Random)", "path" = /obj/structure/decoration/bush/reed/style_random),
		list("name" = "Plastic Leafy Bush", "path" = /obj/structure/decoration/bush/leafy/first),
		list("name" = "Plastic Leafy Bush (Alt)", "path" = /obj/structure/decoration/bush/leafy/second),
		list("name" = "Plastic Leafy Bush (Alt 2)", "path" = /obj/structure/decoration/bush/leafy/third),
		list("name" = "Plastic Leafy Bush (Random)", "path" = /obj/structure/decoration/bush/leafy/style_random),
		list("name" = "Plastic Pale Bush", "path" = /obj/structure/decoration/bush/pale/first),
		list("name" = "Plastic Pale Bush (Alt)", "path" = /obj/structure/decoration/bush/pale/second),
		list("name" = "Plastic Pale Bush (Alt 2)", "path" = /obj/structure/decoration/bush/pale/third),
		list("name" = "Plastic Pale Bush (Alt 3)", "path" = /obj/structure/decoration/bush/pale/fourth),
		list("name" = "Plastic Pale Bush (Random)", "path" = /obj/structure/decoration/bush/pale/style_random),
		list("name" = "Plastic Stalky Bush", "path" = /obj/structure/decoration/bush/stalky/first),
		list("name" = "Plastic Stalky Bush (Alt)", "path" = /obj/structure/decoration/bush/stalky/second),
		list("name" = "Plastic Stalky Bush (Alt 2)", "path" = /obj/structure/decoration/bush/stalky/third),
		list("name" = "Plastic Stalky Bush (Random)", "path" = /obj/structure/decoration/bush/stalky/style_random),
		list("name" = "Plastic Grassy Bush", "path" = /obj/structure/decoration/bush/grassy/first),
		list("name" = "Plastic Grassy Bush (Alt)", "path" = /obj/structure/decoration/bush/grassy/second),
		list("name" = "Plastic Grassy Bush (Alt 2)", "path" = /obj/structure/decoration/bush/grassy/third),
		list("name" = "Plastic Grassy Bush (Alt 3)", "path" = /obj/structure/decoration/bush/grassy/fourth),
		list("name" = "Plastic Grassy Bush (Random)", "path" = /obj/structure/decoration/bush/grassy/style_random),
		list("name" = "Plastic Sparse Grass", "path" = /obj/structure/decoration/bush/sparsegrass/first),
		list("name" = "Plastic Sparse Grass (Alt)", "path" = /obj/structure/decoration/bush/sparsegrass/second),
		list("name" = "Plastic Sparse Grass (Alt 2)", "path" = /obj/structure/decoration/bush/sparsegrass/third),
		list("name" = "Plastic Sparse Grass (Random)", "path" = /obj/structure/decoration/bush/sparsegrass/style_random),
		list("name" = "Plastic Full Grass", "path" = /obj/structure/decoration/bush/fullgrass/first),
		list("name" = "Plastic Full Grass (Alt)", "path" = /obj/structure/decoration/bush/fullgrass/second),
		list("name" = "Plastic Full Grass (Alt 2)", "path" = /obj/structure/decoration/bush/fullgrass/third),
		list("name" = "Plastic Full Grass (Random)", "path" = /obj/structure/decoration/bush/fullgrass/style_random),
		list("name" = "Plastic Ferny Bush", "path" = /obj/structure/decoration/bush/ferny/first),
		list("name" = "Plastic Ferny Bush (Alt)", "path" = /obj/structure/decoration/bush/ferny/second),
		list("name" = "Plastic Ferny Bush (Alt 2)", "path" = /obj/structure/decoration/bush/ferny/third),
		list("name" = "Plastic Ferny Bush (Random)", "path" = /obj/structure/decoration/bush/ferny/style_random),
		list("name" = "Plastic Sunny Bush", "path" = /obj/structure/decoration/bush/sunny/first),
		list("name" = "Plastic Sunny Bush (Alt)", "path" = /obj/structure/decoration/bush/sunny/second),
		list("name" = "Plastic Sunny Bush (Alt 2)", "path" = /obj/structure/decoration/bush/sunny/third),
		list("name" = "Plastic Sunny Bush (Random)", "path" = /obj/structure/decoration/bush/sunny/style_random),
		list("name" = "Plastic Generic Bush", "path" = /obj/structure/decoration/bush/generic/first),
		list("name" = "Plastic Generic Bush (Alt)", "path" = /obj/structure/decoration/bush/generic/second),
		list("name" = "Plastic Generic Bush (Alt 2)", "path" = /obj/structure/decoration/bush/generic/third),
		list("name" = "Plastic Generic Bush (Alt 3)", "path" = /obj/structure/decoration/bush/generic/fourth),
		list("name" = "Plastic Generic Bush (Random)", "path" = /obj/structure/decoration/bush/generic/style_random),
		list("name" = "Plastic Pointy Bush", "path" = /obj/structure/decoration/bush/pointy/first),
		list("name" = "Plastic Pointy Bush (Alt)", "path" = /obj/structure/decoration/bush/pointy/second),
		list("name" = "Plastic Pointy Bush (Alt 2)", "path" = /obj/structure/decoration/bush/pointy/third),
		list("name" = "Plastic Pointy Bush (Alt 3)", "path" = /obj/structure/decoration/bush/pointy/fourth),
		list("name" = "Plastic Pointy Bush (Random)", "path" = /obj/structure/decoration/bush/pointy/style_random),
		list("name" = "Plastic Lavender Grass", "path" = /obj/structure/decoration/bush/lavendergrass/first),
		list("name" = "Plastic Lavender Grass (Alt)", "path" = /obj/structure/decoration/bush/lavendergrass/second),
		list("name" = "Plastic Lavender Grass (Alt 2)", "path" = /obj/structure/decoration/bush/lavendergrass/third),
		list("name" = "Plastic Lavender Grass (Alt 3)", "path" = /obj/structure/decoration/bush/lavendergrass/fourth),
		list("name" = "Plastic Lavender Grass (Random)", "path" = /obj/structure/decoration/bush/lavendergrass/style_random),
	),
	"Flowers" = list(
		list("name" = "Plastic Yellow-White Flowers", "path" = /obj/structure/decoration/bush/flowers_yw/first),
		list("name" = "Plastic Yellow-White Flowers (Alt)", "path" = /obj/structure/decoration/bush/flowers_yw/second),
		list("name" = "Plastic Yellow-White Flowers (Alt 2)", "path" = /obj/structure/decoration/bush/flowers_yw/third),
		list("name" = "Plastic Yellow-White Flowers (Random)", "path" = /obj/structure/decoration/bush/flowers_yw/style_random),
		list("name" = "Plastic Blue-Red Flowers", "path" = /obj/structure/decoration/bush/flowers_br/first),
		list("name" = "Plastic Blue-Red Flowers (Alt)", "path" = /obj/structure/decoration/bush/flowers_br/second),
		list("name" = "Plastic Blue-Red Flowers (Alt 2)", "path" = /obj/structure/decoration/bush/flowers_br/third),
		list("name" = "Plastic Blue-Red Flowers (Random)", "path" = /obj/structure/decoration/bush/flowers_br/style_random),
		list("name" = "Plastic Purple Flowers", "path" = /obj/structure/decoration/bush/flowers_pp/first),
		list("name" = "Plastic Purple Flowers (Alt)", "path" = /obj/structure/decoration/bush/flowers_pp/second),
		list("name" = "Plastic Purple Flowers (Alt 2)", "path" = /obj/structure/decoration/bush/flowers_pp/third),
		list("name" = "Plastic Purple Flowers (Random)", "path" = /obj/structure/decoration/bush/flowers_pp/style_random),
	),
	"Snow" = list(
		list("name" = "Plastic Snowy Bush", "path" = /obj/structure/decoration/bush/snow/first),
		list("name" = "Plastic Snowy Bush (Alt)", "path" = /obj/structure/decoration/bush/snow/second),
		list("name" = "Plastic Snowy Bush (Alt 2)", "path" = /obj/structure/decoration/bush/snow/third),
		list("name" = "Plastic Snowy Bush (Alt 3)", "path" = /obj/structure/decoration/bush/snow/fourth),
		list("name" = "Plastic Snowy Bush (Alt 4)", "path" = /obj/structure/decoration/bush/snow/fifth),
		list("name" = "Plastic Snowy Bush (Alt 5)", "path" = /obj/structure/decoration/bush/snow/sixth),
		list("name" = "Plastic Snowy Bush (Random)", "path" = /obj/structure/decoration/bush/snow/style_random),
	),
	"Jungle" = list(
		list("name" = "Plastic Jungle Bush", "path" = /obj/structure/decoration/bush/jungle/first),
		list("name" = "Plastic Jungle Bush (Alt)", "path" = /obj/structure/decoration/bush/jungle/second),
		list("name" = "Plastic Jungle Bush (Alt 2)", "path" = /obj/structure/decoration/bush/jungle/third),
		list("name" = "Plastic Jungle Bush (Random)", "path" = /obj/structure/decoration/bush/jungle/style_random),
		list("name" = "Plastic Jungle Bush B", "path" = /obj/structure/decoration/bush/jungle/b/first),
		list("name" = "Plastic Jungle Bush B (Alt)", "path" = /obj/structure/decoration/bush/jungle/b/second),
		list("name" = "Plastic Jungle Bush B (Alt 2)", "path" = /obj/structure/decoration/bush/jungle/b/third),
		list("name" = "Plastic Jungle Bush B (Random)", "path" = /obj/structure/decoration/bush/jungle/b/style_random),
		list("name" = "Plastic Jungle Bush C", "path" = /obj/structure/decoration/bush/jungle/c/first),
		list("name" = "Plastic Jungle Bush C (Alt)", "path" = /obj/structure/decoration/bush/jungle/c/second),
		list("name" = "Plastic Jungle Bush C (Alt 2)", "path" = /obj/structure/decoration/bush/jungle/c/third),
		list("name" = "Plastic Jungle Bush C (Random)", "path" = /obj/structure/decoration/bush/jungle/c/style_random),
		list("name" = "Large Plastic Bush", "path" = /obj/structure/decoration/bush/large/first),
		list("name" = "Large Plastic Bush (Alt)", "path" = /obj/structure/decoration/bush/large/second),
		list("name" = "Large Plastic Bush (Alt 2)", "path" = /obj/structure/decoration/bush/large/third),
		list("name" = "Large Plastic Bush (Random)", "path" = /obj/structure/decoration/bush/large/style_random),
	),
	"Rocks" = list(
		list("name" = "Plastic Rock", "path" = /obj/structure/decoration/rock/first),
		list("name" = "Plastic Rock (Alt)", "path" = /obj/structure/decoration/rock/second),
		list("name" = "Plastic Rock (Alt 2)", "path" = /obj/structure/decoration/rock/third),
		list("name" = "Plastic Rock (Alt 3)", "path" = /obj/structure/decoration/rock/fourth),
		list("name" = "Plastic Rock (Random)", "path" = /obj/structure/decoration/rock/style_random),
		list("name" = "Plastic Rock Pile", "path" = /obj/structure/decoration/rock/pile/first),
		list("name" = "Plastic Rock Pile (Alt)", "path" = /obj/structure/decoration/rock/pile/second),
		list("name" = "Plastic Rock Pile (Alt 2)", "path" = /obj/structure/decoration/rock/pile/third),
		list("name" = "Plastic Rock Pile (Random)", "path" = /obj/structure/decoration/rock/pile/style_random),
		list("name" = "Plastic Jungle Rocks", "path" = /obj/structure/decoration/rock/pile/jungle/first),
		list("name" = "Plastic Jungle Rocks (Alt)", "path" = /obj/structure/decoration/rock/pile/jungle/second),
		list("name" = "Plastic Jungle Rocks (Alt 2)", "path" = /obj/structure/decoration/rock/pile/jungle/third),
		list("name" = "Plastic Jungle Rocks (Alt 3)", "path" = /obj/structure/decoration/rock/pile/jungle/fourth),
		list("name" = "Plastic Jungle Rocks (Alt 4)", "path" = /obj/structure/decoration/rock/pile/jungle/fifth),
		list("name" = "Plastic Jungle Rocks (Random)", "path" = /obj/structure/decoration/rock/pile/jungle/style_random),
		list("name" = "Large Plastic Rocks", "path" = /obj/structure/decoration/rock/pile/jungle/large/first),
		list("name" = "Large Plastic Rocks (Alt)", "path" = /obj/structure/decoration/rock/pile/jungle/large/second),
		list("name" = "Large Plastic Rocks (Alt 2)", "path" = /obj/structure/decoration/rock/pile/jungle/large/third),
		list("name" = "Large Plastic Rocks (Random)", "path" = /obj/structure/decoration/rock/pile/jungle/large/style_random),
	),
))

/obj/item/construction/rdd
	name = "rapid-decoration-device (RDD)"
	desc = "A device used to rapidly deploy plastic decorative flora. \
		Internally synthesizes cheap plastic replicas of natural scenery."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rdd"
	worn_icon_state = "RCD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_premium_price = PAYCHECK_COMMAND * 1
	max_matter = 60
	slot_flags = ITEM_SLOT_BELT
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	banned_upgrades = RCD_ALL_UPGRADES & ~RCD_UPGRADE_SILO_LINK
	charge_icon_state = "rtd"
	drop_sound = 'sound/items/handling/tools/rcd_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/rcd_pickup.ogg'
	sound_vary = TRUE
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4, /datum/material/iron = SHEET_MATERIAL_AMOUNT * 3, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.5)

	/// Currently selected decoration path
	var/obj/structure/decoration/selected_decoration
	/// Currently selected category name (for UI)
	var/selected_category
	/// Currently selected design name (for UI)
	var/selected_design_name

/obj/item/construction/rdd/Initialize(mapload)
	. = ..()
	selected_category = GLOB.rdd_designs[1]
	var/list/category_designs = GLOB.rdd_designs[selected_category]
	if(length(category_designs))
		var/list/first_design = category_designs[1]
		selected_decoration = first_design["path"]
		selected_design_name = first_design["name"]

/obj/item/construction/rdd/examine(mob/user)
	. = ..()
	. += span_info("Currently set to produce: [span_bold(initial(selected_decoration.name))].")

/obj/item/construction/rdd/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/construction/rdd/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidDecorationDevice", name)
		ui.open()

/obj/item/construction/rdd/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/rdd),
	)

/obj/item/construction/rdd/ui_static_data(mob/user)
	var/list/data = ..()

	data["categories"] = list()
	for(var/category in GLOB.rdd_designs)
		var/list/cat_entry = list("cat_name" = category, "designs" = list())
		for(var/list/design in GLOB.rdd_designs[category])
			cat_entry["designs"] += list(list(
				"name" = design["name"],
				"icon" = sanitize_css_class_name(design["name"]),
			))
		data["categories"] += list(cat_entry)

	return data

/obj/item/construction/rdd/ui_data(mob/user)
	var/list/data = ..()

	var/total_matter = get_matter(user)
	data["matter"] = isnum(total_matter) ? total_matter : 0
	data["max_matter"] = max_matter
	data["selected_category"] = selected_category
	data["selected_design"] = selected_design_name

	return data

/obj/item/construction/rdd/handle_ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("design")
			var/category = params["category"]
			var/design_name = params["name"]
			for(var/list/design as anything in GLOB.rdd_designs[category])
				if(design["name"] == design_name)
					selected_decoration = design["path"]
					selected_category = category
					selected_design_name = design_name
					playsound(src, SFX_TOOL_SWITCH, 20, TRUE)
					return TRUE

	return TRUE

/obj/item/construction/rdd/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .

	var/turf/target_turf = get_turf(interacting_with)
	if(!target_turf)
		return ITEM_INTERACT_BLOCKING

	if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
		balloon_alert(user, "tile is blocked!")
		return ITEM_INTERACT_BLOCKING

	var/decoration_count = 0
	for(var/obj/structure/decoration/existing in target_turf.contents)
		decoration_count++
		if(decoration_count >= 3)
			balloon_alert(user, "too many decorations here!")
			return ITEM_INTERACT_BLOCKING

	var/cost = RDD_COST_MULTIPLIER
	if(!useResource(cost, user, TRUE))
		return ITEM_INTERACT_BLOCKING

	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	if(!do_after(user, 0.5 SECONDS, target_turf))
		return ITEM_INTERACT_BLOCKING
	if(!useResource(cost, user, TRUE))
		return ITEM_INTERACT_BLOCKING

	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	new selected_decoration(target_turf)
	useResource(cost, user)

	log_tool("[key_name(user)] used [src] to create [initial(selected_decoration.name)] at [AREACOORD(target_turf)]")
	return ITEM_INTERACT_SUCCESS

/obj/item/construction/rdd/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/target_turf = get_turf(interacting_with)
	if(!target_turf)
		return NONE

	var/obj/structure/decoration/found = locate() in target_turf

	if(!found)
		return NONE

	playsound(target_turf, 'sound/machines/click.ogg', 50, TRUE)
	if(!do_after(user, 0.5 SECONDS, target_turf))
		return ITEM_INTERACT_BLOCKING

	playsound(target_turf, 'sound/items/deconstruct.ogg', 50, TRUE)
	qdel(found)

	log_tool("[key_name(user)] used [src] to deconstruct [found] at [AREACOORD(target_turf)]")
	return ITEM_INTERACT_SUCCESS

/obj/item/construction/rdd/borg
	desc = "A device used to rapidly deploy plastic decorative flora. Uses the cyborg's internal cell."
	custom_materials = null
	/// energy usage per decoration
	var/energyfactor = 0.1 * STANDARD_CELL_CHARGE

/obj/item/construction/rdd/borg/get_matter(mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		return 0
	max_matter = borgy.cell.maxcharge
	return borgy.cell.charge

/obj/item/construction/rdd/borg/useResource(amount, mob/user, dry_run)
	var/mob/living/silicon/robot/borgy = user
	if(!iscyborg(borgy))
		return FALSE
	if(!borgy.cell)
		balloon_alert(user, "no cell found!")
		return FALSE
	if(borgy.cell.charge < amount * energyfactor)
		balloon_alert(user, "insufficient charge!")
		return FALSE
	if(!dry_run)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		return borgy.cell.use(amount * energyfactor)
	return TRUE

/obj/item/construction/rdd/loaded
	matter = /obj/item/construction/rdd::max_matter

#undef RDD_COST_MULTIPLIER
