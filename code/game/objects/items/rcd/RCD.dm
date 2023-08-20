#define RCD_DESTRUCTIVE_SCAN_RANGE 10
#define RCD_HOLOGRAM_FADE_TIME (15 SECONDS)
#define RCD_DESTRUCTIVE_SCAN_COOLDOWN (RCD_HOLOGRAM_FADE_TIME + 1 SECONDS)

///each define maps to a variable used for construction in the RCD
#define CONSTRUCTION_MODE "construction_mode"
#define WINDOW_TYPE "window_type"
#define COMPUTER_DIR "computer_dir"
#define WALLFRAME_TYPE "wallframe_type"
#define FURNISH_TYPE "furnish_type"
#define AIRLOCK_TYPE "airlock_type"

///flags to be sent to UI
#define TITLE "title"
#define ICON "icon"

///flags for creating icons shared by an entire category
#define CATEGORY_ICON_STATE  "category_icon_state"
#define CATEGORY_ICON_SUFFIX "category_icon_suffix"
#define TITLE_ICON "ICON=TITLE"

//RAPID CONSTRUCTION DEVICE

/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	worn_icon_state = "RCD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_premium_price = PAYCHECK_COMMAND * 2
	max_matter = 160
	slot_flags = ITEM_SLOT_BELT
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	actions_types = list(/datum/action/item_action/rcd_scan)

	///all stuff used by RCD for construction
	var/static/list/root_categories = list(
		//1ST ROOT CATEGORY
		"Construction" = list( //Stuff you use to make & decorate areas
			//Walls & Windows
			"Structures" = list(
				list(CONSTRUCTION_MODE = RCD_FLOORWALL, ICON = "wallfloor", TITLE = "Wall/Floor"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window, ICON = "windowsize", TITLE = "Directional Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/reinforced, ICON = "windowtype", TITLE = "Directional Reinforced Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/fulltile, ICON = "window0", TITLE = "Full Tile Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/reinforced/fulltile, ICON = "rwindow0", TITLE = "Full Tile Reinforced Window"),
				list(CONSTRUCTION_MODE = RCD_CATWALK, ICON = "catwalk-0", TITLE = "Catwalk"),
				list(CONSTRUCTION_MODE = RCD_REFLECTOR, ICON = "reflector_base", TITLE = "Reflector"),
				list(CONSTRUCTION_MODE = RCD_GIRDER, ICON = "girder", TITLE = "Girder"),
			),

			//Computers & Machine Frames
			"Machines" = list(
				list(CONSTRUCTION_MODE = RCD_MACHINE, ICON = "box_1", TITLE = "Machine Frame"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = NORTH, ICON = "cnorth", TITLE = "Computer North"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = SOUTH, ICON = "csouth", TITLE = "Computer South"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = EAST, ICON = "ceast", TITLE = "Computer East"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = WEST, ICON = "cwest", TITLE = "Computer West"),
				list(CONSTRUCTION_MODE = RCD_FLOODLIGHT, ICON = "floodlight_c1", TITLE = "FloodLight Frame"),
				list(CONSTRUCTION_MODE = RCD_WALLFRAME, WALLFRAME_TYPE = /obj/item/wallframe/apc, ICON = "apc", TITLE = "APC WallFrame"),
				list(CONSTRUCTION_MODE = RCD_WALLFRAME, WALLFRAME_TYPE = /obj/item/wallframe/airalarm, ICON = "alarm_bitem", TITLE = "AirAlarm WallFrame"),
				list(CONSTRUCTION_MODE = RCD_WALLFRAME, WALLFRAME_TYPE = /obj/item/wallframe/firealarm, ICON = "fire_bitem", TITLE = "FireAlarm WallFrame"),
			),

			//Interior Design[construction_mode = RCD_FURNISHING is implied]
			"Furniture" = list(
				list(FURNISH_TYPE = /obj/structure/chair, ICON = "chair", TITLE = "Chair"),
				list(FURNISH_TYPE = /obj/structure/chair/stool, ICON = "stool", TITLE = "Stool"),
				list(FURNISH_TYPE = /obj/structure/chair/stool/bar, ICON = "bar", TITLE = "Bar Stool"),
				list(FURNISH_TYPE = /obj/structure/table, ICON = "table",TITLE = "Table"),
				list(FURNISH_TYPE = /obj/structure/table/glass, ICON = "glass_table", TITLE = "Glass Table"),
				list(FURNISH_TYPE = /obj/structure/rack, ICON = "rack", TITLE = "Rack"),
				list(FURNISH_TYPE = /obj/structure/bed, ICON = "bed", TITLE = "Bed"),
			),
		),

		//2ND ROOT CATEGORY[construction_mode = RCD_AIRLOCK is implied,"icon=closed"]
		"Airlocks" = list( //used to seal/close areas
			//Window Doors[airlock_glass = TRUE is implied]
			"Windoors" = list(
				list(AIRLOCK_TYPE = /obj/machinery/door/window, ICON = "windoor", TITLE = "Windoor"),
				list(AIRLOCK_TYPE = /obj/machinery/door/window/brigdoor, ICON = "secure_windoor", TITLE = "Secure Windoor"),
			),

			//Glass Airlocks[airlock_glass = TRUE is implied,do fill_closed overlay]
			"Glass Airlocks" = list(
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/glass, TITLE = "Standard", CATEGORY_ICON_STATE = TITLE_ICON, CATEGORY_ICON_SUFFIX = "Glass"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/public/glass, TITLE = "Public"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/engineering/glass, TITLE = "Engineering"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/atmos/glass, TITLE = "Atmospherics"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/security/glass, TITLE = "Security"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/command/glass, TITLE = "Command"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/medical/glass, TITLE = "Medical"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/research/glass, TITLE = "Research"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/virology/glass, TITLE = "Virology"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/mining/glass, TITLE = "Mining"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance/glass, TITLE = "Maintenance"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/external/glass, TITLE = "External"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance/external/glass, TITLE = "External Maintenance"),
			),

			//Solid Airlocks[airlock_glass = FALSE is implied,no fill_closed overlay]
			"Solid Airlocks" = list(
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock, TITLE = "Standard", CATEGORY_ICON_STATE = TITLE_ICON),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/public, TITLE = "Public"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/engineering, TITLE = "Engineering"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/atmos, TITLE = "Atmospherics"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/security, TITLE = "Security"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/command, TITLE = "Command"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/medical, TITLE = "Medical"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/research, TITLE = "Research"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/freezer, TITLE = "Freezer"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/virology, TITLE = "Virology"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/mining, TITLE = "Mining"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance, TITLE = "Maintenance"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/external, TITLE = "External"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance/external, TITLE = "External Maintenance"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/hatch, TITLE = "Airtight Hatch"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance_hatch, TITLE = "Maintenance Hatch"),
			),
		),

		//3RD CATEGORY Airlock access,empty list cause airlock_electronics UI will be displayed  when this tab is selected
		"Airlock Access" = list()
	)

	/// name of currently selected design
	var/design_title = "Wall/Floor"
	/// category of currently selected design
	var/design_category = "Structures"
	/// main category of currently selected design[Structures, Airlocks, Airlock Access]
	var/root_category = "Construction"
	/// owner of this rcd. It can either be an construction console or an player
	var/owner
	/// type of structure being built, used to decide what variables are used to build what structure
	var/mode = RCD_FLOORWALL
	/// temporary holder of mode, used to restore mode original value after rcd deconstruction act
	var/construction_mode = RCD_FLOORWALL
	/// used by arcd, can this rcd work from a range
	var/ranged = FALSE
	/// direction which computer frames are constructed in
	var/computer_dir = NORTH
	/// type of airlock/windoor being built[mode = RCD_AIRLOCK]
	var/airlock_type = /obj/machinery/door/airlock
	/// are we building glass/solid airlocks
	var/airlock_glass = FALSE
	/// are we building normal/reinforced directional/fulltile windows
	var/obj/structure/window/window_type = /obj/structure/window/fulltile
	/// type of wallmount airalarm,firealarm,apc we are trying to build
	var/obj/item/wallframe/wallframe_type = /obj/item/wallframe/apc
	/// type of furniture tables,chairs etc we are trying to build
	var/furnish_type = /obj/structure/chair
	/// delay multiplier for all construction types
	var/delay_mod = 1
	/// variable for R walls to deconstruct them
	var/canRturf = FALSE
	/// integrated airlock electronics for setting access to a newly built airlocks
	var/obj/item/electronics/airlock/airlock_electronics

	COOLDOWN_DECLARE(destructive_scan_cooldown)

	var/current_active_effects = 0
	var/frequent_use_debuff_multiplier = 3

GLOBAL_VAR_INIT(icon_holographic_wall, init_holographic_wall())
GLOBAL_VAR_INIT(icon_holographic_window, init_holographic_window())

/proc/init_holographic_wall()
	return icon('icons/turf/walls/wall.dmi', "wall-0")

/proc/init_holographic_window()
	var/icon/grille_icon = icon('icons/obj/structures.dmi', "grille")
	var/icon/window_icon = icon('icons/obj/smooth_structures/window.dmi', "window-0")

	grille_icon.Blend(window_icon, ICON_OVERLAY)

	return grille_icon

/obj/item/construction/rcd/ui_action_click(mob/user, actiontype)
	if (!COOLDOWN_FINISHED(src, destructive_scan_cooldown))
		to_chat(user, span_warning("[src] lets out a low buzz."))
		return

	COOLDOWN_START(src, destructive_scan_cooldown, RCD_DESTRUCTIVE_SCAN_COOLDOWN)
	rcd_scan(src)

/**
 * Global proc that generates RCD hologram in a range.
 *
 * Arguments:
 * * source - The atom the scans originate from
 * * scan_range - The range of turfs we grab from the source
 * * fade_time - The time for RCD holograms to fade
 */
/proc/rcd_scan(atom/source, scan_range = RCD_DESTRUCTIVE_SCAN_RANGE, fade_time = RCD_HOLOGRAM_FADE_TIME)
	playsound(source, 'sound/items/rcdscan.ogg', 50, vary = TRUE, pressure_affected = FALSE)

	var/turf/source_turf = get_turf(source)
	for(var/turf/open/surrounding_turf in RANGE_TURFS(scan_range, source_turf))
		var/rcd_memory = surrounding_turf.rcd_memory
		if(!rcd_memory)
			continue

		var/skip_to_next_turf = FALSE

		for(var/atom/content_of_turf as anything in surrounding_turf.contents)
			if (content_of_turf.density)
				skip_to_next_turf = TRUE
				break

		if(skip_to_next_turf)
			continue

		var/hologram_icon
		switch(rcd_memory)
			if(RCD_MEMORY_WALL)
				hologram_icon = GLOB.icon_holographic_wall
			if(RCD_MEMORY_WINDOWGRILLE)
				hologram_icon = GLOB.icon_holographic_window

		var/obj/effect/rcd_hologram/hologram = new(surrounding_turf)
		hologram.icon = hologram_icon
		hologram.makeHologram()
		animate(hologram, alpha = 0, time = fade_time, easing = CIRCULAR_EASING | EASE_IN)

/obj/effect/rcd_hologram
	name = "hologram"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/rcd_hologram/Initialize(mapload)
	. = ..()
	QDEL_IN(src, RCD_HOLOGRAM_FADE_TIME)

#undef RCD_DESTRUCTIVE_SCAN_COOLDOWN
#undef RCD_DESTRUCTIVE_SCAN_RANGE
#undef RCD_HOLOGRAM_FADE_TIME

/obj/item/construction/rcd/suicide_act(mob/living/user)
	var/turf/T = get_turf(user)

	if(!isopenturf(T)) // Oh fuck
		user.visible_message(span_suicide("[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

	mode = RCD_FLOORWALL
	user.visible_message(span_suicide("[user] sets the RCD to 'Wall' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(checkResource(16, user)) // It takes 16 resources to construct a wall
		var/success = T.rcd_act(user, src, RCD_FLOORWALL)
		T = get_turf(user)
		// If the RCD placed a floor instead of a wall, having a wall without plating under it is cursed
		// There isn't an easy programmatical way to check if rcd_act will place a floor or a wall, so just repeat using it for free
		if(success && isopenturf(T))
			T.rcd_act(user, src, RCD_FLOORWALL)
		useResource(16, user)
		activate()
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		user.gib()
		return MANUAL_SUICIDE

	user.visible_message(span_suicide("[user] pulls the trigger... But there is not enough ammo!"))
	return SHAME

/// check can the structure be placed on the turf
/obj/item/construction/rcd/proc/can_place(atom/A, list/rcd_results, mob/user)
	/**
	 *For anything that does not go an a wall we have to make sure that turf is clear for us to put the structure on it
	 *If we are just trying to destory something then this check is not nessassary
	 *RCD_WALLFRAME is also returned as the mode when upgrading apc, airalarm, firealarm using simple circuits upgrade
	 */
	if(rcd_results["mode"] != RCD_WALLFRAME && rcd_results["mode"] != RCD_DECONSTRUCT)
		var/turf/target_turf = get_turf(A)
		//if we are trying to build a window on top of a grill we check for specific edge cases
		if(rcd_results["mode"] == RCD_WINDOWGRILLE && istype(A, /obj/structure/grille))
			var/list/structures_to_ignore

			//if we are trying to build full-tile windows we only ignore the grille but other directional windows on the grill can block its construction
			if(window_type == /obj/structure/window/fulltile || window_type == /obj/structure/window/reinforced/fulltile)
				structures_to_ignore = list(A)
			//for normal directional windows we ignore the grille & other directional windows as they can be in diffrent directions on the grill. There is a later check during construction to deal with those
			else
				structures_to_ignore = list(/obj/structure/grille, /obj/structure/window)

			//check if we can build our window on the grill
			if(target_turf.is_blocked_turf(exclude_mobs = FALSE, source_atom = null, ignore_atoms = structures_to_ignore, type_list = (length(structures_to_ignore) == 2)))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				balloon_alert(user, "something is on the grille!")
				return FALSE

		/**
		 * if we are trying to create plating on turf which is not a proper floor then dont check for objects on top of the turf just allow that turf to be converted into plating. e.g. create plating beneath a player or underneath a machine frame/any dense object
		 * if we are trying to finish a wall girder then let it finish then make sure no one/nothing is stuck in the girder
		 */
		else if(rcd_results["mode"] == RCD_FLOORWALL && (!istype(target_turf, /turf/open/floor) || istype(A, /obj/structure/girder)))
			//if a player builds a wallgirder on top of himself manually with iron sheets he can't finish the wall if he is still on the girder. Exclude the girder itself when checking for other dense objects on the turf
			if(istype(A, /obj/structure/girder) && target_turf.is_blocked_turf(exclude_mobs = FALSE, source_atom = null, ignore_atoms = list(A)))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				balloon_alert(user, "something is on the girder!")
				return FALSE

		//check if turf is blocked in for dense structures
		else
			//structures which are small enough to fit on turfs containing directional windows.
			var/static/list/small_structures = list(
				RCD_AIRLOCK,
				RCD_COMPUTER,
				RCD_FLOODLIGHT,
				RCD_FURNISHING,
				RCD_MACHINE,
				RCD_REFLECTOR,
				RCD_WINDOWGRILLE,
			)

			//edge cases for what we can/can't ignore
			var/ignore_mobs = FALSE
			var/list/ignored_types
			if(rcd_results["mode"] in small_structures)
				ignored_types = list(/obj/structure/window)
				//if we are trying to create grills/windoors we can go ahead and further ignore other windoors on the turf
				if(rcd_results["mode"] == RCD_WINDOWGRILLE || (rcd_results["mode"] == RCD_AIRLOCK && ispath(airlock_type, /obj/machinery/door/window)))
					//only ignore mobs if we are trying to create windoors and not grills. We dont want to drop a grill on top of somebody
					ignore_mobs = rcd_results["mode"] == RCD_AIRLOCK
					ignored_types += /obj/machinery/door/window
				//if we are trying to create full airlock doors then we do the regular checks and make sure we have the full space for them. i.e. dont ignore anything dense on the turf
				else if(rcd_results["mode"] == RCD_AIRLOCK)
					ignored_types = list()

			//check if the structure can fit on this turf
			if(target_turf.is_blocked_turf(exclude_mobs = ignore_mobs, source_atom = null, ignore_atoms = ignored_types, type_list = TRUE))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				balloon_alert(user, "something is on the tile!")
				return FALSE

	return TRUE

/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	//does this atom allow for rcd actions?
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE

	var/delay = rcd_results["delay"] * delay_mod

	if (
		!(upgrade & RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN) \
			&& !rcd_results[RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN] \
			&& current_active_effects > 0
	)
		delay *= frequent_use_debuff_multiplier

	current_active_effects += 1
	rcd_create_effect(A, user, delay, rcd_results)
	current_active_effects -= 1

/obj/item/construction/rcd/proc/rcd_create_effect(atom/target, mob/user, delay, list/rcd_results)
	var/obj/effect/constructing_effect/rcd_effect = new(get_turf(target), delay, src.mode, upgrade)

	//resource & structure placement sanity checks before & after delay along with beam effects
	if(!checkResource(rcd_results["cost"], user) || !can_place(target, rcd_results, user))
		qdel(rcd_effect)
		return FALSE
	var/beam
	if(ranged)
		beam = user.Beam(target,icon_state="rped_upgrade", time = delay)
	if(!do_after(user, delay, target = target))
		qdel(rcd_effect)
		if(!isnull(beam))
			qdel(beam)
		return FALSE
	if (QDELETED(rcd_effect))
		return FALSE
	if(!checkResource(rcd_results["cost"], user) || !can_place(target, rcd_results, user))
		qdel(rcd_effect)
		return FALSE

	if(!useResource(rcd_results["cost"], user))
		qdel(rcd_effect)
		return FALSE
	activate()
	if(!target.rcd_act(user, src, rcd_results["mode"]))
		qdel(rcd_effect)
		return FALSE
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	rcd_effect.end_animation()
	return TRUE

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	airlock_electronics = new(src)
	airlock_electronics.name = "Access Control"
	airlock_electronics.holder = src
	GLOB.rcd_list += src

/obj/item/construction/rcd/Destroy()
	QDEL_NULL(airlock_electronics)
	GLOB.rcd_list -= src
	. = ..()

/obj/item/construction/rcd/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/rcd),
	)

/obj/item/construction/rcd/ui_host(mob/user)
	return owner || ..()

/obj/item/construction/rcd/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidConstructionDevice", name)
		ui.open()

/obj/item/construction/rcd/ui_static_data(mob/user)
	return airlock_electronics.ui_static_data(user)

/obj/item/construction/rcd/ui_data(mob/user)
	var/list/data = ..()

	//main categories
	data["selected_root"] = root_category
	data["root_categories"] = list()
	for(var/category in root_categories)
		data["root_categories"] += category

	//create the category list
	data["selected_category"] = design_category
	data["selected_design"] = design_title
	data["categories"] = list()

	var/category_icon_state
	var/category_icon_suffix
	for(var/sub_category as anything in root_categories[root_category])
		var/list/target_category =  root_categories[root_category][sub_category]
		if(target_category.len == 0)
			continue

		//skip category if upgrades were not installed for these
		if(sub_category == "Machines" && !(upgrade & RCD_UPGRADE_FRAMES))
			continue
		if(sub_category == "Furniture" && !(upgrade & RCD_UPGRADE_FURNISHING))
			continue
		category_icon_state = ""
		category_icon_suffix = ""

		var/list/designs = list() //initialize all designs under this category
		for(var/i in 1 to target_category.len)
			var/list/design = target_category[i]

			//check for special icon flags
			if(design[CATEGORY_ICON_STATE] != null)
				category_icon_state = design[CATEGORY_ICON_STATE]
			if(design[CATEGORY_ICON_SUFFIX] != null)
				category_icon_suffix = design[CATEGORY_ICON_SUFFIX]

			//get icon or create it from pre defined flags
			var/icon_state
			if(design[ICON] != null)
				icon_state = design[ICON]
			else
				icon_state = category_icon_state
				if(icon_state == TITLE_ICON)
					icon_state = design[TITLE]
			icon_state = "[icon_state][category_icon_suffix]"

			//sanitize them so you dont go insane when icon names contain spaces in them
			icon_state = sanitize_css_class_name(icon_state)

			designs += list(list(TITLE = design[TITLE], ICON = icon_state))
		data["categories"] += list(list("cat_name" = sub_category, "designs" = designs))

	//merge airlock_electronics ui data with this
	var/list/airlock_data = airlock_electronics.ui_data(user)
	for(var/key in airlock_data)
		data[key] = airlock_data[key]

	return data

/obj/item/construction/rcd/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(root_categories[new_root] != null) //is a valid category
				root_category = new_root

		if("design")
			var/category_name = params["category"]
			var/index = params["index"]

			var/list/root = root_categories[root_category]
			if(root == null) //not a valid root
				return TRUE
			var/list/category = root[category_name]
			if(category == null) //not a valid category
				return TRUE

			/**
			 * The advantage of organizing designs into categories is that
			 * You can ignore an complete category if the design disk upgrade for that category isn't installed.
			 */
			//You can't select designs from the Machines category if you dont have the frames upgrade installed.
			if(category == "Machines" && !(upgrade & RCD_UPGRADE_FRAMES))
				return TRUE
			//You can't select designs from the Furniture category if you dont have the furnishing upgrade installed.
			if(category == "Furniture" && !(upgrade & RCD_UPGRADE_FURNISHING))
				return TRUE

			var/list/design = category[index]
			if(design == null) //not a valid design
				return TRUE

			design_category = category_name
			design_title = design["title"]

			if(category_name == "Structures")
				construction_mode = design[CONSTRUCTION_MODE]
				if(design[WINDOW_TYPE] != null)
					window_type = design[WINDOW_TYPE]
			else if(category_name == "Machines")
				construction_mode = design[CONSTRUCTION_MODE]
				if(design[COMPUTER_DIR] != null)
					computer_dir = design[COMPUTER_DIR]
				if(design[WALLFRAME_TYPE] != null)
					wallframe_type = design[WALLFRAME_TYPE]
			else if(category_name == "Furniture")
				construction_mode = RCD_FURNISHING
				furnish_type = design[FURNISH_TYPE]

			if(root_category == "Airlocks")
				construction_mode = RCD_AIRLOCK
				airlock_glass = (category_name != "Solid Airlocks")
				airlock_type = design[AIRLOCK_TYPE]

		else
			airlock_electronics.do_action(action, params)

	return TRUE

/obj/item/construction/rcd/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/construction/rcd/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	//proximity check for normal rcd & range check for arcd
	if((!proximity_flag && !ranged) || (ranged && !range_check(target, user)))
		return FALSE

	//do the work
	mode = construction_mode
	rcd_create(target, user)

	return . | AFTERATTACK_PROCESSED_ITEM

/obj/item/construction/rcd/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	//proximity check for normal rcd & range check for arcd
	if((!proximity_flag && !ranged) || (ranged && !range_check(target, user)))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	//do the work
	mode = RCD_DECONSTRUCT
	rcd_create(target, user)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, PROC_REF(detonate_pulse_explode)), 50)

/obj/item/construction/rcd/proc/detonate_pulse_explode()
	explosion(src, light_impact_range = 3, flame_range = 1, flash_range = 1)
	qdel(src)

/obj/item/construction/rcd/borg
	desc = "A device used to rapidly build walls and floors."
	banned_upgrades = RCD_UPGRADE_SILO_LINK
	var/energyfactor = 72

/obj/item/construction/rcd/borg/get_matter(mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		return 0
	max_matter = borgy.cell.maxcharge
	return borgy.cell.charge

/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			balloon_alert(user, "no cell found!")
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		balloon_alert(user, "insufficient charge!")
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			balloon_alert(user, "no cell found!")
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		balloon_alert(user, "insufficient charge!")
	return .

/obj/item/construction/rcd/borg/syndicate
	name = "syndicate RCD"
	desc = "A reverse-engineered RCD with black market upgrades that allow this device to deconstruct reinforced walls. Property of Donk Co."
	icon_state = "ircd"
	inhand_icon_state = "ircd"
	energyfactor = 66
	canRturf = TRUE

/obj/item/construction/rcd/loaded
	matter = 160

/obj/item/construction/rcd/loaded/upgraded
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN

/obj/item/construction/rcd/combat
	name = "industrial RCD"
	icon_state = "ircd"
	inhand_icon_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN

/obj/item/construction/rcd/ce
	name = "professional RCD"
	desc = "A higher-end model of the rapid construction device, prefitted with improved cooling and disruption prevention. Provided to the chief engineer."
	upgrade = RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN
	matter = 160
	color = list(
		0.3, 0.3, 0.7, 0.0,
		1.0, 1.0, 0.2, 0.0,
		-0.2, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0,
		0.0, 0.0, 0.0, 0.0,
	)

#undef CONSTRUCTION_MODE
#undef WINDOW_TYPE
#undef COMPUTER_DIR
#undef WALLFRAME_TYPE
#undef FURNISH_TYPE
#undef AIRLOCK_TYPE

#undef TITLE
#undef ICON

#undef CATEGORY_ICON_STATE
#undef CATEGORY_ICON_SUFFIX
#undef TITLE_ICON

/obj/item/rcd_ammo
	name = "RCD matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcdammo"
	w_class = WEIGHT_CLASS_TINY
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT *6, /datum/material/glass=SHEET_MATERIAL_AMOUNT*4)
	var/ammoamt = 40

/obj/item/rcd_ammo/large
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*24, /datum/material/glass=SHEET_MATERIAL_AMOUNT*16)
	ammoamt = 160

/obj/item/construction/rcd/combat/admin
	name = "admin RCD"
	max_matter = INFINITY
	matter = INFINITY
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN


// Ranged RCD
/obj/item/construction/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and infinite capacity."
	max_matter = INFINITY
	matter = INFINITY
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	inhand_icon_state = "oldrcd"
	has_ammobar = FALSE
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN
