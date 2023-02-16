#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/*
CONTAINS:
RCD
ARCD
RLD
*/

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with iron, plasteel, glass or compressed matter cartridges."
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=100000)
	req_access = list(ACCESS_ENGINE_EQUIP)
	armor_type = /datum/armor/item_construction
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on the device blinks yellow.</span>"
	var/has_ammobar = FALSE //controls whether or not does update_icon apply ammo indicator overlays
	var/ammo_sections = 10 //amount of divisions in the ammo indicator overlay/number of ammo indicator states
	/// Bitflags for upgrades
	var/upgrade = NONE
	/// Bitflags for banned upgrades
	var/banned_upgrades = NONE
	var/datum/component/remote_materials/silo_mats //remote connection to the silo
	var/silo_link = FALSE //switch to use internal or remote storage

/datum/armor/item_construction
	fire = 100
	acid = 50

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", mapload, FALSE)

///used for examining the RCD and for its UI
/obj/item/construction/proc/get_silo_iron()
	if(silo_link && silo_mats.mat_container && !silo_mats.on_hold())
		return silo_mats.mat_container.get_material_amount(/datum/material/iron)/500
	return FALSE

/obj/item/construction/examine(mob/user)
	. = ..()
	. += "It currently holds [matter]/[max_matter] matter-units."
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		. += "Remote storage link state: [silo_link ? "[silo_mats.on_hold() ? "ON HOLD" : "ON"]" : "OFF"]."
		var/iron = get_silo_iron()
		if(iron)
			. += "Remote connection has iron in equivalent to [iron] RCD unit\s." //1 matter for 1 floor tile, as 4 tiles are produced from 1 iron

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	silo_mats = null
	return ..()

/obj/item/construction/pre_attack(atom/target, mob/user, params)
	if(istype(target, /obj/item/rcd_upgrade))
		install_upgrade(target, user)
		return TRUE
	if(insert_matter(target, user))
		return TRUE
	return ..()

/obj/item/construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_upgrade))
		install_upgrade(W, user)
		return TRUE
	if(insert_matter(W, user))
		return TRUE
	return ..()

/// Installs an upgrade into the RCD checking if it is already installed, or if it is a banned upgrade
/obj/item/construction/proc/install_upgrade(obj/item/rcd_upgrade/rcd_up, mob/user)
	if(rcd_up.upgrade & upgrade)
		to_chat(user, span_warning("[src] has already installed this upgrade!"))
		return
	if(rcd_up.upgrade & banned_upgrades)
		to_chat(user, span_warning("[src] can't install this upgrade!"))
		return
	upgrade |= rcd_up.upgrade
	if((rcd_up.upgrade & RCD_UPGRADE_SILO_LINK) && !silo_mats)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE, FALSE)
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(rcd_up)

/// Inserts matter into the RCD allowing it to build
/obj/item/construction/proc/insert_matter(obj/O, mob/user)
	if(iscyborg(user))
		return FALSE

	var/loaded = FALSE
	if(istype(O, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = O
		var/load = min(R.ammoamt, max_matter - matter)
		if(load <= 0)
			to_chat(user, span_warning("[src] can't hold any more matter-units!"))
			return FALSE
		R.ammoamt -= load
		if(R.ammoamt <= 0)
			qdel(R)
		matter += load
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		loaded = TRUE
	else if(isstack(O))
		loaded = loadwithsheets(O, user)
	if(loaded)
		to_chat(user, span_notice("[src] now holds [matter]/[max_matter] matter-units."))
		update_appearance() //ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/proc/loadwithsheets(obj/item/stack/S, mob/user)
	var/value = S.matter_amount
	if(value <= 0)
		to_chat(user, span_notice("You can't insert [S.name] into [src]!"))
		return FALSE
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		to_chat(user, span_notice("You insert [amount_to_use] [S.name] sheets into [src]. "))
		return TRUE
	to_chat(user, span_warning("You can't insert any more [S.name] sheets into [src]!"))
	return FALSE

/obj/item/construction/proc/activate()
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/item/construction/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, FALSE)
	if(prob(20))
		spark_system.start()

/obj/item/construction/update_overlays()
	. = ..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		if(ratio > 0)
			. += "[icon_state]_charge[ratio]"

/obj/item/construction/proc/useResource(amount, mob/user)
	if(!silo_mats || !silo_link)
		if(matter < amount)
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE
		matter -= amount
		update_appearance()
		return TRUE
	else
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, span_alert("Mineral access is on hold, please contact the quartermaster."))
			return FALSE
		if(!silo_mats.mat_container)
			to_chat(user, span_alert("No silo link detected. Connect to silo via multitool."))
			return FALSE
		if(!silo_mats.mat_container.has_materials(list(/datum/material/iron = 500), amount))
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE

		var/list/materials = list()
		materials[GET_MATERIAL_REF(/datum/material/iron)] = 500
		silo_mats.mat_container.use_materials(materials, amount)
		silo_mats.silo_log(src, "consume", -amount, "build", materials)
		return TRUE

///shared data for rcd,rld & plumbing
/obj/item/construction/ui_data(mob/user)
	var/list/data = list()

	//matter in the rcd
	var/total_matter = ((upgrade & RCD_UPGRADE_SILO_LINK) && silo_link) ? get_silo_iron() : matter
	if(!total_matter)
		total_matter = 0
	data["matterLeft"] = total_matter

	//silo details
	data["silo_upgraded"] = !!(upgrade & RCD_UPGRADE_SILO_LINK)
	data["silo_enabled"] = silo_link

	return data

///shared action for toggling silo link rcd,rld & plumbing
/obj/item/construction/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "toggle_silo" && (upgrade & RCD_UPGRADE_SILO_LINK))
		if(silo_mats)
			if(!silo_mats.mat_container && !silo_link) // Allow them to turn off an invalid link.
				to_chat(usr, span_alert("No silo link detected. Connect to silo via multitool."))
				return FALSE
			silo_link = !silo_link
			to_chat(usr, span_notice("You change [src]'s storage link state: [silo_link ? "ON" : "OFF"]."))
		else
			to_chat(usr, span_warning("[src] doesn't have remote storage connection."))
		return TRUE

/obj/item/construction/proc/checkResource(amount, mob/user)
	if(!silo_mats || !silo_mats.mat_container || !silo_link)
		if(silo_link)
			to_chat(user, span_alert("Connected silo link is invalid. Reconnect to silo via multitool."))
			return FALSE
		else
			. = matter >= amount
	else
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, span_alert("Mineral access is on hold, please contact the quartermaster."))
			return FALSE
		. = silo_mats.mat_container.has_materials(list(/datum/material/iron = 500), amount)
	if(!. && user)
		to_chat(user, no_ammo_message)
		if(has_ammobar)
			flick("[icon_state]_empty", src) //somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .

/obj/item/construction/proc/range_check(atom/A, mob/user)
	if(A.z != user.z)
		return
	if(!(A in view(7, get_turf(user))))
		to_chat(user, span_warning("The \'Out of Range\' light on [src] blinks red."))
		return FALSE
	else
		return TRUE

/obj/item/construction/proc/prox_check(proximity)
	if(proximity)
		return TRUE
	else
		return FALSE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The living mob interacting with the menu
 * * remote_anchor The remote anchor for the menu
 */
/obj/item/construction/proc/check_menu(mob/living/user, remote_anchor)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(remote_anchor && user.remote_control != remote_anchor)
		return FALSE
	return TRUE

#define RCD_DESTRUCTIVE_SCAN_RANGE 10
#define RCD_HOLOGRAM_FADE_TIME (15 SECONDS)
#define RCD_DESTRUCTIVE_SCAN_COOLDOWN (RCD_HOLOGRAM_FADE_TIME + 1 SECONDS)

///each define maps to a variable used for construction in the RCD
#define CONSTRUCTION_MODE "construction_mode"
#define WINDOW_TYPE "window_type"
#define WINDOW_GLASS "window_glass"
#define WINDOW_SIZE "window_size"
#define COMPUTER_DIR "computer_dir"
#define WALLFRAME_TYPE "wallframe_type"
#define FURNISH_TYPE "furnish_type"
#define FURNISH_COST "furnish_cost"
#define FURNISH_DELAY "furnish_delay"
#define AIRLOCK_TYPE "airlock_type"

///flags to be sent to UI
#define TITLE "title"
#define ICON "icon"

///flags for creating icons shared by an entire category
#define CATEGORY_ICON_STATE  "category_icon_state"
#define CATEGORY_ICON_SUFFIX "category_icon_suffix"
#define TITLE_ICON "ICON=TITLE"

/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	worn_icon_state = "RCD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_premium_price = PAYCHECK_COMMAND * 10
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
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window, WINDOW_GLASS = RCD_WINDOW_NORMAL, WINDOW_SIZE =  RCD_WINDOW_DIRECTIONAL, ICON = "windowsize", TITLE = "Directional Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/reinforced, WINDOW_GLASS = RCD_WINDOW_REINFORCED, WINDOW_SIZE =  RCD_WINDOW_DIRECTIONAL, ICON = "windowtype", TITLE = "Directional Reinforced Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/fulltile, WINDOW_GLASS = RCD_WINDOW_NORMAL, WINDOW_SIZE =  RCD_WINDOW_FULLTILE, ICON = "window0", TITLE = "Full Tile Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/reinforced/fulltile, WINDOW_GLASS = RCD_WINDOW_REINFORCED, WINDOW_SIZE =  RCD_WINDOW_FULLTILE, ICON = "rwindow0", TITLE = "Full Tile Reinforced Window"),
				list(CONSTRUCTION_MODE = RCD_CATWALK, ICON = "catwalk-0", TITLE = "Catwalk"),
				list(CONSTRUCTION_MODE = RCD_REFLECTOR, ICON = "reflector_base", TITLE = "Reflector"),
			),

			//Computers & Machine Frames
			"Machines" = list(
				list(CONSTRUCTION_MODE = RCD_MACHINE, ICON = "box_1", TITLE = "Machine Frame"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 1, ICON = "cnorth", TITLE = "Computer North"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 2, ICON = "csouth", TITLE = "Computer South"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 4, ICON = "ceast", TITLE = "Computer East"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 8, ICON = "cwest", TITLE = "Computer West"),
				list(CONSTRUCTION_MODE = RCD_FLOODLIGHT, ICON = "floodlight_c1", TITLE = "FloodLight Frame"),
				list(CONSTRUCTION_MODE = RCD_WALLFRAME, WALLFRAME_TYPE = /obj/item/wallframe/apc, ICON = "apc", TITLE = "APC WallFrame"),
				list(CONSTRUCTION_MODE = RCD_WALLFRAME, WALLFRAME_TYPE = /obj/item/wallframe/airalarm, ICON = "alarm_bitem", TITLE = "AirAlarm WallFrame"),
				list(CONSTRUCTION_MODE = RCD_WALLFRAME, WALLFRAME_TYPE = /obj/item/wallframe/firealarm, ICON = "fire_bitem", TITLE = "FireAlarm WallFrame"),
			),

			//Interior Design[construction_mode = RCD_FURNISHING is implied]
			"Furniture" = list(
				list(FURNISH_TYPE = /obj/structure/chair, FURNISH_COST = 8, FURNISH_DELAY = 10, ICON = "chair", TITLE = "Chair"),
				list(FURNISH_TYPE = /obj/structure/chair/stool, FURNISH_COST = 8, FURNISH_DELAY = 10, ICON = "stool", TITLE = "Stool"),
				list(FURNISH_TYPE = /obj/structure/chair/stool/bar, FURNISH_COST = 4, FURNISH_DELAY = 5, ICON = "bar", TITLE = "Bar Stool"),
				list(FURNISH_TYPE = /obj/structure/table, FURNISH_COST = 16, FURNISH_DELAY = 20, ICON = "table",TITLE = "Table"),
				list(FURNISH_TYPE = /obj/structure/table/glass, FURNISH_COST = 16, FURNISH_DELAY = 20, ICON = "glass_table", TITLE = "Glass Table"),
				list(FURNISH_TYPE = /obj/structure/rack, FURNISH_COST = 20, FURNISH_DELAY = 25, ICON = "rack", TITLE = "Rack"),
				list(FURNISH_TYPE = /obj/structure/bed, FURNISH_COST = 10, FURNISH_DELAY = 15, ICON = "bed", TITLE = "Bed"),
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

	///english name for the design to check if it was selected or not
	var/design_title = "Wall/Floor"
	var/design_category = "Structures"
	var/root_category = "Construction"
	var/closed = FALSE
	///owner of this rcd. It can either be an construction console or an player
	var/owner
	var/mode = RCD_FLOORWALL
	var/construction_mode = RCD_FLOORWALL
	var/ranged = FALSE
	var/computer_dir = 1
	var/airlock_type = /obj/machinery/door/airlock
	var/airlock_glass = FALSE // So the floor's rcd_act knows how much ammo to use
	var/window_type = /obj/structure/window/fulltile
	var/window_glass = RCD_WINDOW_NORMAL
	var/window_size = RCD_WINDOW_FULLTILE
	var/obj/item/wallframe/wallframe_type = /obj/item/wallframe/apc
	var/furnish_type = /obj/structure/chair
	var/furnish_cost = 8
	var/furnish_delay = 10
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/delay_mod = 1
	var/canRturf = FALSE //Variable for R walls to deconstruct them
	/// Integrated airlock electronics for setting access to a newly built airlocks
	var/obj/item/electronics/airlock/airlock_electronics

	COOLDOWN_DECLARE(destructive_scan_cooldown)

GLOBAL_VAR_INIT(icon_holographic_wall, init_holographic_wall())
GLOBAL_VAR_INIT(icon_holographic_window, init_holographic_window())

// `initial` does not work here. Neither does instantiating a wall/whatever
// and referencing that. I don't know why.
/proc/init_holographic_wall()
	return getHologramIcon(
		icon('icons/turf/walls/wall.dmi', "wall-0"),
		opacity = 1,
	)

/proc/init_holographic_window()
	var/icon/grille_icon = icon('icons/obj/structures.dmi', "grille")
	var/icon/window_icon = icon('icons/obj/smooth_structures/window.dmi', "window-0")

	grille_icon.Blend(window_icon, ICON_OVERLAY)

	return getHologramIcon(grille_icon)

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/construction/rcd/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		mode = construction_mode
		rcd_create(target, user)

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

/**
 * checks if the turf has dense objects that could block construction of big structures such as walls, airlocks etc
 * Arguments:
 * * turf/the_turf - The turf we are checking
 * * ignore_mobs - should we ignore mobs when checking for dense objects. this is TRUE only for windoors
 * * ignored_atoms - ignore these object types when checking for dense objects on the turf. e.g. ignore directional windows when building windoors cause they all can exist on the same turf
 */
/obj/item/construction/rcd/proc/is_turf_blocked(turf/the_turf, ignore_mobs, list/ignored_atoms)
	//find the structures to ignore
	var/list/ignored_content = list()
	if(length(ignored_atoms))
		for(var/atom/movable/movable_content in the_turf)
			if(is_type_in_list(movable_content, ignored_atoms))
				ignored_content += movable_content

	//return if the turf is blocked
	return the_turf.is_blocked_turf(exclude_mobs = ignore_mobs, source_atom = null, ignore_atoms = ignored_content)

/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	//does this atom allow for rcd actions?
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE
	var/turf/target_turf = get_turf(A)

	//start animation & check resource for the action
	var/delay = rcd_results["delay"] * delay_mod
	var/obj/effect/constructing_effect/rcd_effect = new(target_turf, delay, src.mode)
	if(!checkResource(rcd_results["cost"], user))
		qdel(rcd_effect)
		return FALSE
	/**
	 *For anything that does not go an a wall we have to make sure that turf is clear for us to put the structure on it
	 *If we are just trying to destory something then this check is not nessassary
	 *RCD_WALLFRAME is also returned as the mode when upgrading apc, airalarm, firealarm using simple circuits upgrade
	 */
	if(rcd_results["mode"] != RCD_WALLFRAME && rcd_results["mode"] != RCD_DECONSTRUCT)
		//if we are trying to build a window on top of a grill we check for specific edge cases
		if(rcd_results["mode"] == RCD_WINDOWGRILLE && istype(A, /obj/structure/grille))
			var/list/structures_to_ignore

			//if we are trying to build full-tile windows we only ignore the grille but other directional windows on the grill can block its construction
			if(window_type == /obj/structure/window/fulltile || window_type == /obj/structure/window/reinforced/fulltile)
				structures_to_ignore = list(/obj/structure/grille)
			//for normal directional windows we ignore the grille & other directional windows as they can be in diffrent directions on the grill. There is a later check during construction to deal with those
			else
				structures_to_ignore = list(/obj/structure/grille, /obj/structure/window)

			//check if we can build our window on the grill
			if(is_turf_blocked(the_turf = target_turf, ignore_mobs = FALSE, ignored_atoms = structures_to_ignore))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				balloon_alert(user, "something is on the grille!")
				qdel(rcd_effect)
				return FALSE

		/**
		 * if we are trying to create plating on turf which is not a proper floor then dont check for objects on top of the turf just allow that turf to be converted into plating. e.g. create plating beneath a player or underneath a machine frame/any dense object
		 * if we are trying to finish a wall girder then let it finish then make sure no one/nothing is stuck in the girder
		 */
		else if(rcd_results["mode"] == RCD_FLOORWALL && (!istype(target_turf, /turf/open/floor) || istype(A, /obj/structure/girder)))
			//if a player builds a wallgirder on top of himself manually with iron sheets he can't finish the wall if he is still on the girder. Exclude the girder itself when checking for other dense objects on the turf
			if(istype(A, /obj/structure/girder) && is_turf_blocked(the_turf = target_turf, ignore_mobs = FALSE, ignored_atoms = list(/obj/structure/girder)))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				balloon_alert(user, "something is on the girder!")
				qdel(rcd_effect)
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
			var/exclude_mobs = FALSE
			var/list/ignored_types
			if(rcd_results["mode"] in small_structures)
				ignored_types = list(/obj/structure/window)
				//if we are trying to create grills/windoors we can go ahead and further ignore other windoors on the turf
				if(rcd_results["mode"] == RCD_WINDOWGRILLE || (rcd_results["mode"] == RCD_AIRLOCK && ispath(airlock_type, /obj/machinery/door/window)))
					//only ignore mobs if we are trying to create windoors and not grills. We dont want to drop a grill on top of somebody
					exclude_mobs = rcd_results["mode"] == RCD_AIRLOCK
					ignored_types += /obj/machinery/door/window
				//if we are trying to create full airlock doors then we do the regular checks and make sure we have the full space for them. i.e. dont ignore anything dense on the turf
				else if(rcd_results["mode"] == RCD_AIRLOCK)
					ignored_types = list()

			//check if the structure can fit on this turf
			if(is_turf_blocked(the_turf = target_turf, ignore_mobs = exclude_mobs, ignored_atoms = ignored_types))
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				balloon_alert(user, "something is on the tile!")
				qdel(rcd_effect)
				return FALSE
	if(!do_after(user, delay, target = A))
		qdel(rcd_effect)
		return FALSE
	if(!checkResource(rcd_results["cost"], user))
		qdel(rcd_effect)
		return FALSE
	if(!A.rcd_act(user, src, rcd_results["mode"]))
		qdel(rcd_effect)
		return FALSE
	rcd_effect.end_animation()
	useResource(rcd_results["cost"], user)
	activate()
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
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

/obj/item/construction/rcd/ui_act(action, params)
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
				if(design[WINDOW_GLASS] != null)
					window_glass = design[WINDOW_GLASS]
				if(design[WINDOW_SIZE] != null)
					window_size = design[WINDOW_SIZE]
			else if(category_name == "Machines")
				construction_mode = design[CONSTRUCTION_MODE]
				if(design[COMPUTER_DIR] != null)
					computer_dir = design[COMPUTER_DIR]
				if(design[WALLFRAME_TYPE] != null)
					wallframe_type = design[WALLFRAME_TYPE]
			else if(category_name == "Furniture")
				construction_mode = RCD_FURNISHING
				furnish_type = design[FURNISH_TYPE]
				furnish_cost = design[FURNISH_COST]
				furnish_delay = design[FURNISH_DELAY]

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

/obj/item/construction/rcd/pre_attack(atom/A, mob/user, params)
	. = ..()
	mode = construction_mode
	rcd_create(A, user)
	return TRUE

/obj/item/construction/rcd/pre_attack_secondary(atom/target, mob/living/user, params)
	. = ..()
	mode = RCD_DECONSTRUCT
	if(!target.rcd_vals(user, src))
		return
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

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/construction/rcd/borg
	no_ammo_message = "<span class='warning'>Insufficient charge.</span>"
	desc = "A device used to rapidly build walls and floors."
	banned_upgrades = RCD_UPGRADE_SILO_LINK
	var/energyfactor = 72


/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		to_chat(user, no_ammo_message)
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
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING

/obj/item/construction/rcd/combat
	name = "industrial RCD"
	icon_state = "ircd"
	inhand_icon_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING

#undef CONSTRUCTION_MODE
#undef WINDOW_TYPE
#undef WINDOW_GLASS
#undef WINDOW_SIZE
#undef COMPUTER_DIR
#undef WALLFRAME_TYPE
#undef FURNISH_TYPE
#undef FURNISH_COST
#undef FURNISH_DELAY
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
	custom_materials = list(/datum/material/iron=12000, /datum/material/glass=8000)
	var/ammoamt = 40

/obj/item/rcd_ammo/large
	custom_materials = list(/datum/material/iron=48000, /datum/material/glass=32000)
	ammoamt = 160

/obj/item/construction/rcd/combat/admin
	name = "admin RCD"
	max_matter = INFINITY
	matter = INFINITY
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING


// Ranged RCD
/obj/item/construction/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity. Reload with iron, plasteel, glass or compressed matter cartridges."
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	inhand_icon_state = "oldrcd"
	has_ammobar = FALSE

/obj/item/construction/rcd/arcd/afterattack(atom/A, mob/user)
	. = ..()
	if(range_check(A,user))
		pre_attack(A, user)
		return . | AFTERATTACK_PROCESSED_ITEM

/obj/item/construction/rcd/arcd/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(range_check(target,user))
		pre_attack_secondary(target, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/rcd/arcd/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(ranged && range_check(target, user))
		mode = construction_mode
		rcd_create(target, user)

/obj/item/construction/rcd/arcd/rcd_create(atom/A, mob/user)
	. = ..()
	if(.)
		user.Beam(A,icon_state="rped_upgrade", time = 3 SECONDS)



// RAPID LIGHTING DEVICE
/obj/item/construction/rld
	name = "Rapid Lighting Device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with iron, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	worn_icon_state = "RPD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	slot_flags = ITEM_SLOT_BELT
	///it does not make sense why any of these should be installed
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING

	var/matter_divisor = 35
	var/mode = LIGHT_MODE
	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

	///reference to thr original icons
	var/list/original_options = list(
		"Color Pick" = icon(icon = 'icons/hud/radial.dmi', icon_state = "omni"),
		"Glow Stick" = icon(icon = 'icons/obj/lighting.dmi', icon_state = "glowstick"),
		"Deconstruct" = icon(icon = 'icons/obj/tools.dmi', icon_state = "wrench"),
		"Light Fixture" = icon(icon = 'icons/obj/lighting.dmi', icon_state = "ltube"),
	)
	///will contain the original icons modified with the color choice
	var/list/display_options = list()
	var/color_choice = null

/obj/item/construction/rld/Initialize(mapload)
	. = ..()
	for(var/option in original_options)
		display_options[option] = icon(original_options[option])

/obj/item/construction/rld/attack_self(mob/user)
	. = ..()

	if((upgrade & RCD_UPGRADE_SILO_LINK) && display_options["Silo Link"] == null) //silo upgrade instaled but option was not updated then update it just one
		display_options["Silo Link"] = icon(icon = 'icons/obj/mining.dmi', icon_state = "silo")
	var/choice = show_radial_menu(user, src, display_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	if(!choice)
		return

	switch(choice)
		if("Light Fixture")
			mode = LIGHT_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Permanent Light Construction'."))
		if("Glow Stick")
			mode = GLOW_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Light Launcher'."))
		if("Color Pick")
			var/new_choice = input(user,"","Choose Color",color_choice) as color
			if(new_choice == null)
				return

			var/list/new_rgb = ReadRGB(new_choice)
			for(var/option in original_options)
				if(option == "Color Pick" || option == "Deconstruct" || option == "Silo Link")
					continue
				var/icon/icon = icon(original_options[option])
				icon.SetIntensity(new_rgb[1]/255, new_rgb[2]/255, new_rgb[3]/255) //apply new scale
				display_options[option] = icon

			color_choice = new_choice
		if("Deconstruct")
			mode = REMOVE_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Deconstruct'."))
		else
			ui_act("toggle_silo", list())

/obj/item/construction/rld/proc/checkdupes(target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/construction/rld/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, span_notice("You start deconstructing [A]..."))
					user.Beam(A,icon_state="light_beam", time = 15)
					playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
					if(do_after(user, decondelay, target = A))
						if(!useResource(deconcost, user))
							return FALSE
						activate()
						qdel(A)
						return TRUE
				return FALSE
		if(LIGHT_MODE)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, span_notice("You start building a wall light..."))
					user.Beam(A,icon_state="light_beam", time = 15)
					playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
					playsound(loc, 'sound/effects/light_flicker.ogg', 50, FALSE)
					if(do_after(user, floordelay, target = A))
						if(!istype(W))
							return FALSE
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in GLOB.cardinals)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if((isspaceturf(C) || TURF_SHARES(C)) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, span_warning("Valid target not found..."))
							playsound(loc, 'sound/misc/compiler-failure.ogg', 30, TRUE)
							return FALSE
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = CHEAP_HYPOTENUSE(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return FALSE
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.setDir(align)
						L.color = color_choice
						L.set_light_color(L.color)
						return TRUE
				return FALSE

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, span_notice("You start building a floor light..."))
					user.Beam(A,icon_state="light_beam", time = 15)
					playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
					playsound(loc, 'sound/effects/light_flicker.ogg', 50, TRUE)
					if(do_after(user, floordelay, target = A))
						if(!istype(F))
							return FALSE
						if(!useResource(floorcost, user))
							return FALSE
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.set_light_color(FL.color)
						return TRUE
				return FALSE

		if(GLOW_MODE)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, span_notice("You fire a glowstick!"))
				var/obj/item/flashlight/glowstick/G = new /obj/item/flashlight/glowstick(start)
				G.color = color_choice
				G.set_light_color(G.color)
				G.throw_at(A, 9, 3, user)
				G.on = TRUE
				G.update_brightness()
				return TRUE
			return FALSE

/obj/item/construction/rld/mini
	name = "mini-rapid-light-device (MRLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with iron, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 100
	max_matter = 100
	matter_divisor = 20

///The plumbing RCD. All the blueprints are located in _globalvars > lists > construction.dm
/obj/item/construction/plumbing
	name = "Plumbing Constructor"
	desc = "An expertly modified RCD outfitted to construct plumbing machinery."
	icon_state = "plumberer2"
	inhand_icon_state = "plumberer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	worn_icon_state = "plumbing"
	icon = 'icons/obj/tools.dmi'
	slot_flags = ITEM_SLOT_BELT
	///it does not make sense why any of these should be installed.
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS  | RCD_UPGRADE_FURNISHING
	matter = 200
	max_matter = 200

	///type of the plumbing machine
	var/obj/machinery/blueprint = null
	///index, used in the attack self to get the type. stored here since it doesnt change
	var/list/choices = list()
	///All info for construction
	var/list/machinery_data = list("cost" = list())
	///This list that holds all the plumbing design types the plumberer can construct. Its purpose is to make it easy to make new plumberer subtypes with a different selection of machines.
	var/list/plumbing_design_types
	///Current selected layer
	var/current_layer = "Default Layer"
	///Current selected color, for ducts
	var/current_color = "omni"
	///maps layer name to layer number value. didnt make this global cause only this class needs it
	var/static/list/name_to_number = list(
		"First Layer" = 1,
		"Second Layer" = 2,
		"Default Layer" = 3,
		"Fourth Layer" = 4,
		"Fifth Layer" = 5,
	)

/obj/item/construction/plumbing/Initialize(mapload)
	. = ..()

	//design types supported for this plumbing rcd
	set_plumbing_designs()

	//set cost of each machine & initial blueprint
	for(var/obj/machinery/plumbing/plumbing_type as anything in plumbing_design_types)
		machinery_data["cost"][plumbing_type] = plumbing_design_types[plumbing_type]
	blueprint =  plumbing_design_types[1]

/obj/item/construction/plumbing/proc/set_plumbing_designs()
	plumbing_design_types = list(
		//category 1 Synthesizers i.e devices which creates , reacts & destroys chemicals
		/obj/machinery/plumbing/synthesizer = 15,
		/obj/machinery/plumbing/reaction_chamber/chem = 15,
		/obj/machinery/plumbing/grinder_chemical = 30,
		/obj/machinery/plumbing/growing_vat = 20,
		/obj/machinery/plumbing/fermenter = 30,
		/obj/machinery/plumbing/liquid_pump = 35, //extracting chemicals from ground is one way of creation
		/obj/machinery/plumbing/disposer = 10,
		/obj/machinery/plumbing/buffer = 10, //creates chemicals as it waits for other buffers containing other chemicals and when mixed creates new chemicals

		//category 2 distributors i.e devices which inject , move around , remove chemicals from the network
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/layer_manifold = 5,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/sender = 20,
		/obj/machinery/plumbing/output = 5,

		//category 3 Storage i.e devices which stores & makes the processed chemicals ready for consumption
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
		/obj/machinery/plumbing/bottler = 50,
		/obj/machinery/plumbing/pill_press = 20,
		/obj/machinery/iv_drip/plumbing = 20
	)

/obj/item/construction/plumbing/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_MOUSE_SCROLL_ON, PROC_REF(mouse_wheeled))
	else
		UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)

/obj/item/construction/plumbing/dropped(mob/user, silent)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/construction/plumbing/cyborg_unequip(mob/user)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/construction/plumbing/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/construction/plumbing/examine(mob/user)
	. = ..()
	. += "You can scroll your mouse wheel to change the piping layer."
	. += "You can right click a fluid duct to set the Plumbing RPD to its color and layer."

/obj/item/construction/plumbing/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlumbingService", name)
		ui.open()

/obj/item/construction/plumbing/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/plumbing),
	)

/obj/item/construction/plumbing/ui_static_data(mob/user)
	return list("paint_colors" = GLOB.pipe_paint_colors)

///find which category this design belongs to
/obj/item/construction/plumbing/proc/get_category(obj/machinery/recipe)
	if(ispath(recipe, /obj/machinery/plumbing))
		var/obj/machinery/plumbing/plumbing_design = recipe
		return initial(plumbing_design.category)
	else if(ispath(recipe , /obj/machinery/duct))
		return "Distribution"
	else
		return "Storage"

/obj/item/construction/plumbing/ui_data(mob/user)
	var/list/data = ..()

	data["piping_layer"] = name_to_number[current_layer] //maps layer name to layer number's 1,2,3,4,5
	data["selected_color"] = current_color
	data["layer_icon"] = "plumbing_layer[GLOB.plumbing_layers[current_layer]]"
	data["selected_category"] = get_category(blueprint)
	data["selected_recipe"] = initial(blueprint.name)

	var/list/category_list = list()
	var/category_name = ""
	var/obj/machinery/recipe = null

	for(var/i in 1 to plumbing_design_types.len)
		recipe = plumbing_design_types[i]

		category_name = get_category(recipe) //get category of design
		if(!category_list[category_name])
			var/list/item_list = list()
			item_list["cat_name"] = category_name //used by RapidPipeDispenser.js
			item_list["recipes"] = list() //used by RapidPipeDispenser.js
			category_list[category_name] = item_list

		//add item to category
		category_list[category_name]["recipes"] += list(list(
			"index" = i,
			"icon" = initial(recipe.icon_state),
			"name" = initial(recipe.name),
		))

	data["categories"] = list()
	for(category_name in category_list)
		data["categories"] += list(category_list[category_name])

	return data

/obj/item/construction/plumbing/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("color")
			var/color = params["paint_color"]
			if(GLOB.pipe_paint_colors[color] != null) //validate if the color is in the allowed list of values
				current_color = color
		if("piping_layer")
			var/bitflag = text2num(params["piping_layer"])  //convert from layer number back to layer string
			bitflag = 1 << (bitflag - 1)
			var/layer = GLOB.plumbing_layer_names["[bitflag]"]
			if(layer != null) //validate if this value exists in the list
				current_layer = layer
		if("recipe")
			var/design = plumbing_design_types[text2num(params["id"])]
			if(design != null) //validate if design is valid
				blueprint = design
			playsound(src, 'sound/effects/pop.ogg', 50, vary = FALSE)

	return TRUE


///pretty much rcd_create, but named differently to make myself feel less bad for copypasting from a sibling-type
/obj/item/construction/plumbing/proc/create_machine(atom/destination, mob/user)
	if(!machinery_data || !isopenturf(destination))
		return FALSE

	if(!canPlace(destination))
		to_chat(user, span_notice("There is something blocking you from placing a [initial(blueprint.name)] there."))
		return
	if(checkResource(machinery_data["cost"][blueprint], user) && blueprint)
		//"cost" is relative to delay at a rate of 10 matter/second  (1matter/decisecond) rather than playing with 2 different variables since everyone set it to this rate anyways.
		if(do_after(user, machinery_data["cost"][blueprint], target = destination))
			if(checkResource(machinery_data["cost"][blueprint], user) && canPlace(destination))
				useResource(machinery_data["cost"][blueprint], user)
				activate()
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				if(ispath(blueprint, /obj/machinery/duct))
					var/is_omni = current_color == DUCT_COLOR_OMNI
					new blueprint(destination, FALSE, GLOB.pipe_paint_colors[current_color], GLOB.plumbing_layers[current_layer], null, is_omni)
				else
					new blueprint(destination, FALSE, GLOB.plumbing_layers[current_layer])
				return TRUE

/obj/item/construction/plumbing/proc/canPlace(turf/destination)
	if(!isopenturf(destination))
		return FALSE
	. = TRUE

	var/layer_id = GLOB.plumbing_layers[current_layer]

	for(var/obj/content_obj in destination.contents)
		// Let's not built ontop of dense stuff, if this is also dense.
		if(initial(blueprint.density) && content_obj.density)
			return FALSE

		// Ducts can overlap other plumbing objects IF the layers are different

		// make sure plumbling isn't overlapping.
		for(var/datum/component/plumbing/plumber as anything in content_obj.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & layer_id)
				return FALSE

		if(istype(content_obj, /obj/machinery/duct))
			// Make sure ducts aren't overlapping.
			var/obj/machinery/duct/duct_machine = content_obj
			if(duct_machine.duct_layer & layer_id)
				return FALSE

/obj/item/construction/plumbing/pre_attack_secondary(obj/machinery/target, mob/user, params)
	if(!istype(target, /obj/machinery/duct))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/obj/machinery/duct/duct = target
	if(duct.duct_layer && duct.duct_color)
		current_color = GLOB.pipe_color_name[duct.duct_color]
		current_layer = GLOB.plumbing_layer_names["[duct.duct_layer]"]
		balloon_alert(user, "using [current_color], layer [current_layer]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/plumbing/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity))
		return
	if(istype(target, /obj/machinery/plumbing))
		var/obj/machinery/machine_target = target
		if(machine_target.anchored)
			to_chat(user, span_warning("The [target.name] needs to be unanchored!"))
			return
		if(do_after(user, 20, target = target))
			machine_target.deconstruct() //Let's not substract matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE) //this is just such a great sound effect
	else
		create_machine(target, user)

/obj/item/construction/plumbing/AltClick(mob/user)
	ui_interact(user)

/obj/item/construction/plumbing/proc/mouse_wheeled(mob/source, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	if(source.incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
		return
	if(delta_y == 0)
		return

	if(delta_y < 0)
		var/current_loc = GLOB.plumbing_layers.Find(current_layer) + 1
		if(current_loc > GLOB.plumbing_layers.len)
			current_loc = 1
		current_layer = GLOB.plumbing_layers[current_loc]
	else
		var/current_loc = GLOB.plumbing_layers.Find(current_layer) - 1
		if(current_loc < 1)
			current_loc = GLOB.plumbing_layers.len
		current_layer = GLOB.plumbing_layers[current_loc]
	to_chat(source, span_notice("You set the layer to [current_layer]."))

/obj/item/construction/plumbing/research
	name = "research plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed to conduct cytological research."
	icon_state = "plumberer_sci"
	inhand_icon_state = "plumberer_sci"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	has_ammobar = TRUE

/obj/item/construction/plumbing/research/set_plumbing_designs()
	plumbing_design_types = list(
		//category 1 synthesizers
		/obj/machinery/plumbing/reaction_chamber = 15,
		/obj/machinery/plumbing/grinder_chemical = 30,
		/obj/machinery/plumbing/disposer = 10,
		/obj/machinery/plumbing/growing_vat = 20,

		//category 2 Distributors
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/output = 5,

		//category 3 storage
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
	)

/obj/item/construction/plumbing/service
	name = "service plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed to make a brewery."
	icon_state = "plumberer_service"
	has_ammobar = TRUE

/obj/item/construction/plumbing/service/set_plumbing_designs()
	plumbing_design_types = list(
		//category 1 synthesizers
		/obj/machinery/plumbing/synthesizer/soda = 15,
		/obj/machinery/plumbing/synthesizer/beer = 15,
		/obj/machinery/plumbing/reaction_chamber = 15,
		/obj/machinery/plumbing/buffer = 10,
		/obj/machinery/plumbing/fermenter = 30,
		/obj/machinery/plumbing/grinder_chemical = 30,
		/obj/machinery/plumbing/disposer = 10,


		//category 2 distributors
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/layer_manifold = 5,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/output/tap = 5,
		/obj/machinery/plumbing/sender = 20,

		//category 3 storage
		/obj/machinery/plumbing/bottler = 50,
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
	)


/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "It contains the design for machine frames and computer frames."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/silo_link
	desc = "It contains direct silo connection RCD upgrade."
	upgrade = RCD_UPGRADE_SILO_LINK

/obj/item/rcd_upgrade/furnishing
	desc = "It contains the design for chairs, stools, tables, and glass tables."
	upgrade = RCD_UPGRADE_FURNISHING

/datum/action/item_action/rcd_scan
	name = "Destruction Scan"
	desc = "Scans the surrounding area for destruction. Scanned structures will rebuild significantly faster."

#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE
