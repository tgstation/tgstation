#define MINING_MESSAGE_COOLDOWN 20

/**********************Mineral deposits**************************/

/turf/closed/mineral //wall piece
	name = "rock"
	icon = MAP_SWITCH('icons/turf/smoothrocks.dmi', 'icons/turf/mining.dmi')
	icon_state = "rock"
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MINERAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/misc/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	opacity = TRUE
	density = TRUE
	// We're a BIG wall, larger then 32x32, so we need to be on the game plane
	// Otherwise we'll draw under shit in weird ways
	plane = GAME_PLANE
	layer = EDGED_TURF_LAYER
	base_icon_state = "smoothrocks"

	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-4, -4), matrix())

	temperature = TCMB
	var/turf/turf_type = /turf/open/misc/asteroid/airless
	/// The path of the ore stack we spawn when we're mined.
	var/obj/item/stack/ore/mineralType = null
	/// If we spawn a boulder like on the gulag, we use this in lou of mineralType
	var/obj/item/boulder/spawned_boulder = null
	/// How much ore we spawn when we're mining a mineralType.
	var/mineralAmt = 3
	/// The icon of the image we display when we're pinged by a mining scanner, to be overridden if you want to use an alternate file for a subtype.
	var/scan_icon = 'icons/effects/ore_visuals.dmi'
	/// Placeholder for the icon_state of the image we display when we're pinged by a mining scanner
	var/scan_state = ""
	/// If true, this turf will not call AfterChange during change_turf calls.
	var/defer_change = FALSE
	/// If true you can mine the mineral turf without tools.
	var/weak_turf = FALSE
	/// How long it takes to mine this turf with tools, before the tool's speed and the user's skill modifier are factored in.
	var/tool_mine_speed = 4 SECONDS
	/// How long it takes to mine this turf without tools, if it's weak.
	var/hand_mine_speed = 15 SECONDS


/turf/closed/mineral/Initialize(mapload)
	. = ..()
	// Mineral turfs are big, so they need to be on the game plane at a high layer
	// But they're also turfs, so we need to cut them out from the light mask plane
	// So we draw them as if they were on the game plane, and then overlay a copy onto
	// The wall plane (so emissives/light masks behave)
	// I am so sorry
	var/static/mutable_appearance/wall_overlay = mutable_appearance('icons/turf/mining.dmi', "rock", appearance_flags = RESET_TRANSFORM)
	wall_overlay.plane = MUTATE_PLANE(WALL_PLANE, src)
	overlays += wall_overlay

// Inlined version of the bump click element. way faster this way, the element's nice but it's too much overhead
/turf/closed/mineral/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return

	var/mob/living/bumping = bumped_atom
	if(!ISADVANCEDTOOLUSER(bumping)) // Unadvanced tool users can't mine anyway (this is a lie). This just prevents message spam from attackby()
		return

	var/obj/item/held_item = bumping.get_active_held_item()
	// !held_item exists to be nice to snow. the other bit is for pickaxes obviously
	if(!held_item)
		INVOKE_ASYNC(bumping, TYPE_PROC_REF(/mob, ClickOn), src)
	else if(held_item.tool_behaviour == TOOL_MINING)
		attackby(held_item, bumping)

/turf/closed/mineral/proc/Spread_Vein()
	var/spreadChance = initial(mineralType.spreadChance)
	if(spreadChance)
		for(var/dir in GLOB.cardinals)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				var/turf/closed/mineral/random/M = T
				if(istype(M) && !M.mineralType)
					M.Change_Ore(mineralType)

/turf/closed/mineral/proc/Change_Ore(ore_type, random = 0)
	if(random)
		mineralAmt = rand(1, 5)
	if(ispath(ore_type, /obj/item/stack/ore)) // If it has a scan_state, switch to it
		var/obj/item/stack/ore/the_ore = ore_type
		scan_state = initial(the_ore.scan_state) // I SAID. SWITCH. TO. IT.
		mineralType = ore_type // Everything else assumes that this is typed correctly so don't set it to non-ores thanks.
	if(ispath(ore_type, /obj/item/boulder))
		scan_state = "rock_boulder" // Yes even the lowly boulder has a scan state
		spawned_boulder = /obj/item/boulder/gulag_expanded

/**
 * Returns the distance to the nearest ore vent, where ore vents are tracked in SSore_generation's possible vents list.
 * Returns 0 if we're not on lavaland, and as we're using get_dist, our range is limited to 127 tiles.
 */
/turf/closed/mineral/proc/prox_to_vent()
	if(!is_mining_level(z))
		return 0

	var/distance = 128 // Max distance for a get_dist is 127
	for(var/obj/structure/ore_vent/vent as anything in SSore_generation.possible_vents)
		if(vent.z != src.z)
			continue //Silly
		var/temp_distance = get_dist(src, vent)
		if(temp_distance < distance)
			distance = temp_distance
	return distance

/**
 * Returns the chance of ore spawning in this turf, based on proximity to a vent.
 * See mining defines for the chances and distance defines.
 */
/turf/closed/mineral/proc/proximity_ore_chance()
	var/distance = prox_to_vent()
	if(distance == 0) //We asked for a random chance but we could not successfully find a vent, so 0.
		return 0

	if(distance < VENT_PROX_VERY_HIGH)
		return VENT_CHANCE_VERY_HIGH
	if(distance < VENT_PROX_HIGH)
		return VENT_CHANCE_HIGH
	if(distance < VENT_PROX_MEDIUM)
		return VENT_CHANCE_MEDIUM
	if(distance < VENT_PROX_LOW)
		return VENT_CHANCE_LOW
	if(distance < VENT_PROX_FAR)
		return VENT_CHANCE_FAR
	return 0

/**
 * Returns the amount of ore to spawn in this turf, based on proximity to a vent.
 * If for some reason we have a distance of zero (like being off mining Z levels), we return a random amount between 1 and 5 instead.
 */
/turf/closed/mineral/proc/scale_ore_to_vent()
	var/distance = prox_to_vent()
	if(distance == 0) // We're not on lavaland or similar failure condition
		return rand(1,5)

	if(distance < VENT_PROX_VERY_HIGH)
		return ORE_WALL_VERY_HIGH
	if(distance < VENT_PROX_HIGH)
		return ORE_WALL_HIGH
	if(distance < VENT_PROX_MEDIUM)
		return ORE_WALL_MEDIUM
	if(distance < VENT_PROX_LOW)
		return ORE_WALL_LOW
	if(distance < VENT_PROX_FAR)
		return ORE_WALL_FAR
	return 0

/turf/closed/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()


/turf/closed/mineral/attackby(obj/item/I, mob/user, list/modifiers)
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(usr, span_warning("You don't have the dexterity to do this!"))
		return

	if(I.tool_behaviour != TOOL_MINING)
		return
	var/turf/T = user.loc
	if (!isturf(T))
		return

	if(TIMER_COOLDOWN_RUNNING(src, REF(user))) //prevents mining turfs in progress
		return

	TIMER_COOLDOWN_START(src, REF(user), tool_mine_speed)

	balloon_alert(user, "picking...")

	if(!I.use_tool(src, user, tool_mine_speed, volume=50))
		TIMER_COOLDOWN_END(src, REF(user)) //if we fail we can start again immediately
		return
	if(ismineralturf(src))
		gets_drilled(user, 1)
		SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)

/turf/closed/mineral/attack_hand(mob/user)
	var/mining_arms = HAS_TRAIT(user, TRAIT_FIST_MINING)
	if(!weak_turf && !mining_arms)
		return ..()
	var/turf/user_turf = user.loc
	if (!isturf(user_turf))
		return
	if(TIMER_COOLDOWN_RUNNING(src, REF(user))) //prevents mining turfs in progress
		return
	var/mining_speed = mining_arms ? tool_mine_speed : hand_mine_speed
	TIMER_COOLDOWN_START(src, REF(user), mining_speed)
	var/skill_modifier = user.mind?.get_skill_modifier(/datum/skill/mining, SKILL_SPEED_MODIFIER) || 1
	balloon_alert(user, "pulling out pieces...")
	if(!do_after(user, mining_speed * skill_modifier, target = src))
		TIMER_COOLDOWN_END(src, REF(user)) //if we fail we can start again immediately
		return
	if(ismineralturf(src))
		gets_drilled(user)

/turf/closed/mineral/attack_robot(mob/living/silicon/robot/user)
	if(user.Adjacent(src))
		attack_hand(user)

/turf/closed/mineral/proc/gets_drilled(mob/user, exp_multiplier = 0)
	if(istype(user))
		SEND_SIGNAL(user, COMSIG_MOB_MINED, src, exp_multiplier)
	if(mineralType && (mineralAmt > 0))
		new mineralType(src, mineralAmt)
		SSblackbox.record_feedback("tally", "ore_mined", mineralAmt, mineralType)
	if(spawned_boulder)
		var/obj/item/boulder/wall_boulder = new spawned_boulder(src)
		wall_boulder.platform_lifespan = PLATFORM_LIFE_GULAG
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(exp_multiplier)
			if (mineralType && (mineralAmt > 0))
				H.mind.adjust_experience(/datum/skill/mining, initial(mineralType.mine_experience) * mineralAmt * exp_multiplier)
			else
				H.mind.adjust_experience(/datum/skill/mining, 4 * exp_multiplier)

	for(var/obj/effect/temp_visual/mining_overlay/M in src)
		qdel(M)
	var/flags = NONE
	var/old_type = type
	if(defer_change) // TODO: make the defer change var a var for any changeturf flag
		flags = CHANGETURF_DEFER_CHANGE
	var/turf/open/mined = ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange), flags, old_type), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE) //beautiful destruction
	mined.update_visuals()

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	balloon_alert(user, "digging...")
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
	if(do_after(user, 4 SECONDS, target = src))
		gets_drilled(user)

/turf/closed/mineral/attack_hulk(mob/living/carbon/human/H)
	..()
	if(do_after(H, 5 SECONDS, target = src))
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		H.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		gets_drilled(H)
	return TRUE

/turf/closed/mineral/acid_melt()
	ScrapeAway()

/turf/closed/mineral/ex_act(severity, target)
	. = ..()
	if(target == src)
		gets_drilled()
		return TRUE
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gets_drilled()
		if(EXPLODE_HEAVY)
			if(prob(90))
				gets_drilled()
		if(EXPLODE_LIGHT)
			if(prob(75))
				gets_drilled()

	return TRUE

/turf/closed/mineral/blob_act(obj/structure/blob/B)
	if(prob(50))
		gets_drilled()

/turf/closed/mineral/random
	/// What are the base odds that this turf spawns a mineral in the wall on initialize?
	var/mineralChance = 13
	/// Does this mineral determine its random chance and mineral contents based on proximity to a vent? Overrides mineralChance and mineralAmt.
	var/proximity_based = FALSE

/// Returns a list of the chances for minerals to spawn.
/// Will only run once, and will then be cached.
/turf/closed/mineral/random/proc/mineral_chances()
	return list(
		/obj/item/stack/ore/bananium = check_holidays(APRIL_FOOLS) ? 3 : 0,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite = 4,
	)

/turf/closed/mineral/random/Initialize(mapload)
	var/static/list/mineral_chances_by_type = list()

	. = ..()
	var/dynamic_prob = mineralChance
	if(proximity_based)
		dynamic_prob = proximity_ore_chance() // We assign the chance of ore spawning based on probability.
	if (prob(dynamic_prob))
		var/list/spawn_chance_list = mineral_chances_by_type[type]
		if (isnull(spawn_chance_list))
			mineral_chances_by_type[type] = expand_weights(mineral_chances())
			spawn_chance_list = mineral_chances_by_type[type]
		var/path = pick(spawn_chance_list)
		if(ispath(path, /turf))
			var/stored_flags = 0
			if(turf_flags & NO_RUINS)
				stored_flags |= NO_RUINS
			var/turf/T = ChangeTurf(path,null,CHANGETURF_IGNORE_AIR)
			T.flags_1 |= stored_flags

			if(ismineralturf(T))
				var/turf/closed/mineral/M = T
				M.turf_type = src.turf_type
				M.mineralAmt = scale_ore_to_vent()
				GLOB.post_ore_random["[M.mineralAmt]"] += 1
				src = M
				M.levelupdate()
			else
				src = T
				T.levelupdate()

		else
			Change_Ore(path, FALSE)
			Spread_Vein(path)
			mineralAmt = scale_ore_to_vent()
			GLOB.post_ore_manual["[mineralAmt]"] += 1

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	proximity_based = FALSE

/turf/closed/mineral/random/high_chance/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 20,
		/obj/item/stack/ore/diamond = 30,
		/obj/item/stack/ore/gold = 45,
		/obj/item/stack/ore/plasma = 50,
		/obj/item/stack/ore/silver = 50,
		/obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/uranium = 35,
	)

/turf/closed/mineral/random/high_chance/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	proximity_based = FALSE

/turf/closed/mineral/random/high_chance/volcanic/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 30,
		/obj/item/stack/ore/gold = 45,
		/obj/item/stack/ore/plasma = 50,
		/obj/item/stack/ore/silver = 50,
		/obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/uranium = 35,
	)

/turf/closed/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6

/turf/closed/mineral/random/low_chance/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 4,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 15,
		/obj/item/stack/ore/silver = 6,
		/obj/item/stack/ore/titanium = 4,
		/obj/item/stack/ore/uranium = 2,
		/turf/closed/mineral/gibtonite = 2,
	)

//extremely low chance of rare ores, meant mostly for populating stations with large amounts of asteroid
/turf/closed/mineral/random/stationside
	icon_state = "rock_nochance"
	mineralChance = 4

/turf/closed/mineral/random/stationside/mineral_chances()
	return list(
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/iron = 50,
		/obj/item/stack/ore/plasma = 3,
		/obj/item/stack/ore/silver = 4,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/uranium = 1,
	)

/turf/closed/mineral/random/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	proximity_based = TRUE
	mineralChance = 5

/turf/closed/mineral/random/volcanic/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite/volcanic = 4,
	)

/turf/closed/mineral/random/snow
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	defer_change = TRUE
	turf_type = /turf/open/misc/asteroid/snow/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	weak_turf = TRUE
	proximity_based = TRUE

/turf/closed/mineral/random/snow/Change_Ore(ore_type, random = 0)
	. = ..()
	if(mineralType)
		icon = 'icons/turf/walls/icerock_wall.dmi'
		icon_state = "icerock_wall-0"
		base_icon_state = "icerock_wall"
		smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/random/snow/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite/ice/icemoon = 4,
	)

/// Near exact same subtype as parent, just used in ruins to prevent other ruins/chasms from spawning on top of it.
/turf/closed/mineral/snowmountain/do_not_chasm
	turf_type = /turf/open/misc/asteroid/snow/icemoon/do_not_chasm
	baseturfs = /turf/open/misc/asteroid/snow/icemoon/do_not_chasm
	turf_flags = NO_RUINS

/turf/closed/mineral/random/snow/underground
	baseturfs = /turf/open/misc/asteroid/snow/icemoon
	// abundant ore
	mineralChance = 20

/turf/closed/mineral/random/snow/underground/mineral_chances()
	return list(
		/obj/item/stack/ore/bananium = 1,
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stack/ore/diamond = 4,
		/obj/item/stack/ore/gold = 20,
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 24,
		/obj/item/stack/ore/titanium = 22,
		/obj/item/stack/ore/uranium = 10,
		/turf/closed/mineral/gibtonite/ice/icemoon = 8,
	)

/turf/closed/mineral/random/snow/high_chance
	proximity_based = FALSE

/turf/closed/mineral/random/snow/high_chance/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 20,
		/obj/item/stack/ore/diamond = 30,
		/obj/item/stack/ore/gold = 45,
		/obj/item/stack/ore/plasma = 50,
		/obj/item/stack/ore/silver = 50,
		/obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/uranium = 35,
	)

/turf/closed/mineral/random/labormineral
	icon_state = "rock_labor"

/turf/closed/mineral/random/labormineral/mineral_chances()
	return list(
		/obj/item/boulder/gulag = 165,
		/turf/closed/mineral/gibtonite = 2,
	)

/turf/closed/mineral/random/labormineral/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/labormineral/volcanic/mineral_chances()
	return list(
		/obj/item/boulder/gulag_expanded = 166,
		/turf/closed/mineral/gibtonite/volcanic = 2,
	)

// Subtypes for mappers placing ores manually.
/turf/closed/mineral/random/labormineral/ice
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	defer_change = TRUE
	turf_type = /turf/open/misc/asteroid/snow/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/labormineral/ice/mineral_chances()
	return list(
		/obj/item/boulder/gulag = 168,
		/turf/closed/mineral/gibtonite/ice/icemoon = 2,
	)

/turf/closed/mineral/random/labormineral/ice/Change_Ore(ore_type, random = 0)
	. = ..()
	if(mineralType)
		icon = 'icons/turf/walls/icerock_wall.dmi'
		icon_state = "icerock_wall-0"
		base_icon_state = "icerock_wall"
		smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/iron
	mineralType = /obj/item/stack/ore/iron
	scan_state = "rock_iron"

/turf/closed/mineral/iron/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/iron/ice
	icon_state = "icerock_iron"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid/snow/ice
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/uranium
	mineralType = /obj/item/stack/ore/uranium
	scan_state = "rock_uranium"

/turf/closed/mineral/uranium/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/diamond
	mineralType = /obj/item/stack/ore/diamond
	scan_state = "rock_diamond"

/turf/closed/mineral/diamond/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/diamond/ice
	icon_state = "icerock_iron"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid/snow/ice
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gold
	mineralType = /obj/item/stack/ore/gold
	scan_state = "rock_gold"

/turf/closed/mineral/gold/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver
	mineralType = /obj/item/stack/ore/silver
	scan_state = "rock_silver"

/turf/closed/mineral/silver/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver/ice/icemoon
	turf_type = /turf/open/misc/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/titanium
	mineralType = /obj/item/stack/ore/titanium
	scan_state = "rock_titanium"

/turf/closed/mineral/titanium/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/plasma
	mineralType = /obj/item/stack/ore/plasma
	scan_state = "rock_plasma"

/turf/closed/mineral/plasma/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/plasma/ice
	icon_state = "icerock_plasma"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid/snow/ice
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bananium
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 3
	scan_state = "rock_bananium"

/turf/closed/mineral/bananium/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	scan_state = "rock_bscrystal"

/turf/closed/mineral/bscrystal/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/volcanic
	turf_type = /turf/open/misc/asteroid/basalt
	baseturfs = /turf/open/misc/asteroid/basalt
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/closed/mineral/volcanic/airless
	turf_type = /turf/open/misc/asteroid/basalt/airless
	baseturfs = /turf/open/misc/asteroid/basalt/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/closed/mineral/volcanic/lava_land_surface
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	defer_change = TRUE

/turf/closed/mineral/ash_rock //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon = MAP_SWITCH('icons/turf/walls/rock_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "rock2"
	base_icon_state = "rock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	baseturfs = /turf/open/misc/ashplanet/wateryrock
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	turf_type = /turf/open/misc/ashplanet/rocky
	defer_change = TRUE
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/closed/mineral/snowmountain
	name = "snowy mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	baseturfs = /turf/open/misc/asteroid/snow
	initial_gas_mix = FROZEN_ATMOS
	turf_type = /turf/open/misc/asteroid/snow
	defer_change = TRUE

/turf/closed/mineral/snowmountain/icemoon
	turf_type = /turf/open/misc/asteroid/snow/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/// This snowy mountain will never be scraped away for any reason what so ever.
/turf/closed/mineral/snowmountain/icemoon/unscrapeable
	turf_flags = IS_SOLID | NO_CLEARING
	turf_type = /turf/open/misc/asteroid/snow/icemoon/do_not_scrape
	baseturfs = /turf/open/misc/asteroid/snow/icemoon/do_not_scrape

/turf/closed/mineral/snowmountain/cavern
	name = "ice cavern rock"
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "icerock"
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/misc/asteroid/snow/ice
	turf_type = /turf/open/misc/asteroid/snow/ice

/turf/closed/mineral/snowmountain/cavern/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/ice/icemoon
	turf_type = /turf/open/misc/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

//For when you want genuine, real snowy mountainside in your kitchen's cold room.
/turf/closed/mineral/snowmountain/coldroom
	baseturfs = /turf/open/misc/asteroid/snow/coldroom
	turf_type = /turf/open/misc/asteroid/snow/coldroom
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS

//yoo RED ROCK RED ROCK

/turf/closed/mineral/asteroid
	name = "iron rock"
	icon_state = "redrock"
	icon = MAP_SWITCH('icons/turf/walls/red_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "red_wall"

/turf/closed/mineral/random/stationside/asteroid
	name = "iron rock"
	icon = MAP_SWITCH('icons/turf/walls/red_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "red_wall"

/turf/closed/mineral/random/stationside/asteroid/porus
	name = "porous iron rock"
	desc = "This rock is filled with pockets of breathable air."
	baseturfs = /turf/open/misc/asteroid

/turf/closed/mineral/asteroid/porous
	name = "porous rock"
	desc = "This rock is filled with pockets of breathable air."
	baseturfs = /turf/open/misc/asteroid

//GIBTONITE

/turf/closed/mineral/gibtonite
	mineralAmt = 1
	MAP_SWITCH(, icon_state = "rock_Gibtonite_inactive")
	scan_state = "rock_gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = GIBTONITE_UNSTRUCK //How far into the lifecycle of gibtonite we are
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/mutable_appearance/activated_overlay

/turf/closed/mineral/gibtonite/Initialize(mapload)
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	. = ..()

/turf/closed/mineral/gibtonite/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	var/previous_stage = stage
	if(istype(attacking_item, /obj/item/goliath_infuser_hammer) && stage == GIBTONITE_ACTIVE)
		user.visible_message(span_notice("[user] digs [attacking_item] to [src]..."), span_notice("Your tendril hammer instictively digs and wraps around [src] to stop it..."))
		defuse(user)
	else if(istype(attacking_item, /obj/item/mining_scanner) || istype(attacking_item, /obj/item/t_scanner/adv_mining_scanner) && stage == GIBTONITE_ACTIVE)
		user.visible_message(span_notice("[user] holds [attacking_item] to [src]..."), span_notice("You use [attacking_item] to locate where to cut off the chain reaction and attempt to stop it..."))
		defuse(user)
	..()
	if(istype(attacking_item, /obj/item/clothing/gloves/gauntlets) && previous_stage == GIBTONITE_UNSTRUCK && stage == GIBTONITE_ACTIVE && istype(user))
		user.Immobilize(0.5 SECONDS)
		user.throw_at(get_ranged_target_turf(src, get_dir(src, user), 5), range = 5, speed = 3, spin = FALSE)
		user.visible_message(span_danger("[user] hit gibtonite with [attacking_item.name], launching [user.p_them()] back!"), span_danger("You've struck gibtonite! Your [attacking_item.name] launched you back!"))

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null)
	if(stage == GIBTONITE_UNSTRUCK)
		activated_overlay = mutable_appearance('icons/turf/smoothrocks_overlays.dmi', "rock_Gibtonite_inactive", ON_EDGED_TURF_LAYER) //shows in gaps between pulses if there are any
		add_overlay(activated_overlay)
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = GIBTONITE_ACTIVE
		visible_message(span_danger("There's gibtonite inside! It's going to explode!"))

		var/notify_admins = !is_mining_level(z)

		if(user)
			log_bomber(user, "has triggered a gibtonite deposit reaction via", src, null, notify_admins)
		else
			log_bomber(null, "An explosion has triggered a gibtonite deposit reaction via", src, null, notify_admins)

		countdown(notify_admins)

/turf/closed/mineral/gibtonite/proc/countdown(notify_admins = FALSE)
	set waitfor = FALSE
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0 && mineralAmt >= 1)
		flick_overlay_view(mutable_appearance('icons/turf/smoothrocks_overlays.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER + 0.1), 0.5 SECONDS) //makes the animation pulse one time per tick
		det_time--
		sleep(0.5 SECONDS)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = GIBTONITE_DETONATE
			explosion(bombturf, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flame_range = 0, flash_range = 0, adminlog = notify_admins, explosion_cause = src)

/turf/closed/mineral/gibtonite/proc/defuse(mob/living/defuser)
	if(stage == GIBTONITE_ACTIVE)
		cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		add_overlay(activated_overlay)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE
		if(det_time < 0)
			det_time = 0
		visible_message(span_notice("The chain reaction stopped! The gibtonite had [det_time] reactions left till the explosion!"))
		if(defuser)
			SEND_SIGNAL(defuser, COMSIG_LIVING_DEFUSED_GIBTONITE, det_time)

/turf/closed/mineral/gibtonite/gets_drilled(mob/user, exp_multiplier = 0, triggered_by_explosion = FALSE)
	if(istype(user))
		SEND_SIGNAL(user, COMSIG_MOB_MINED, src, exp_multiplier)

	if(stage == GIBTONITE_UNSTRUCK && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,TRUE)
		explosive_reaction(user)
		return
	if(stage == GIBTONITE_ACTIVE && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = GIBTONITE_DETONATE
		explosion(bombturf, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 5, flame_range = 0, flash_range = 0, adminlog = FALSE, explosion_cause = src)
	if(stage == GIBTONITE_STABLE) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/gibtonite/ore = new (src)
		if(det_time <= 0)
			ore.quality = GIBTONITE_QUALITY_HIGH
			ore.icon_state = "gibtonite_3"
		if(det_time >= 1 && det_time <= 2)
			ore.quality = GIBTONITE_QUALITY_MEDIUM
			ore.icon_state = "gibtonite_2"

	var/flags = NONE
	var/old_type = type
	if(defer_change) // TODO: make the defer change var a var for any changeturf flag
		flags = CHANGETURF_DEFER_CHANGE
	var/turf/open/mined = ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange), flags, old_type), 1, TIMER_UNIQUE)
	mined.update_visuals()

/turf/closed/mineral/gibtonite/volcanic
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gibtonite/volcanic/airless
	turf_type = /turf/open/misc/asteroid/basalt
	baseturfs = /turf/open/misc/asteroid/basalt
	initial_gas_mix = AIRLESS_ATMOS

/turf/closed/mineral/gibtonite/ice
	MAP_SWITCH(, icon_state = "icerock_Gibtonite_inactive")
	icon = MAP_SWITCH('icons/turf/walls/icerock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	turf_type = /turf/open/misc/asteroid/snow/ice
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gibtonite/ice/icemoon
	turf_type = /turf/open/misc/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/strong
	name = "Very strong rock"
	desc = "Seems to be stronger than the other rocks in the area. Only a master of mining techniques could destroy this."
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1
	icon = MAP_SWITCH('icons/turf/walls/rock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "rock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/strong/attackby(obj/item/I, mob/user, list/modifiers)
	if(!ishuman(user))
		to_chat(usr, span_warning("Only a more advanced species could break a rock such as this one!"))
		return FALSE
	if(user.mind?.get_skill_level(/datum/skill/mining) >= SKILL_LEVEL_MASTER)
		. = ..()
	else
		to_chat(usr, span_warning("The rock seems to be too strong to destroy. Maybe I can break it once I become a master miner."))


/turf/closed/mineral/strong/gets_drilled(mob/user, exp_multiplier = 0)
	if(istype(user))
		SEND_SIGNAL(user, COMSIG_MOB_MINED, src, exp_multiplier)

	if(!ishuman(user))
		return // see attackby
	var/mob/living/carbon/human/H = user
	if(!(H.mind?.get_skill_level(/datum/skill/mining) >= SKILL_LEVEL_MASTER))
		return
	drop_ores()
	H.client.give_award(/datum/award/achievement/skill/legendary_miner, H)
	var/flags = NONE
	var/old_type = type
	if(defer_change) // TODO: make the defer change var a var for any changeturf flag
		flags = CHANGETURF_DEFER_CHANGE
	var/turf/open/mined = ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange), flags, old_type), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE) //beautiful destruction
	mined.update_visuals()
	H.mind?.adjust_experience(/datum/skill/mining, 100) //yay!

/turf/closed/mineral/strong/proc/drop_ores()
	if(prob(10))
		new /obj/item/stack/sheet/mineral/mythril(src, 5)
	else
		new /obj/item/stack/sheet/mineral/adamantine(src, 5)

/turf/closed/mineral/strong/acid_melt()
	return

/turf/closed/mineral/strong/ex_act(severity, target)
	return FALSE

#undef MINING_MESSAGE_COOLDOWN
