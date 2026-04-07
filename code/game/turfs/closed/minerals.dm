#define MINING_MESSAGE_COOLDOWN 20
#define DEFAULT_BORDER_DISTANCE -1

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
	var/obj/item/stack/ore/mineral_type = null
	/// If we spawn a boulder like on the gulag, we use this in lou of mineral_type
	var/obj/item/boulder/spawned_boulder = null
	/// How much ore we spawn when we're mining a mineral_type.
	var/mineral_amt = 3
	/// The icon of the image we display when we're pinged by a mining scanner, to be overridden if you want to use an alternate file for a subtype.
	var/scan_icon = 'icons/effects/ore_visuals.dmi'
	/// Placeholder for the image we display when we're pinged by a mining scanner
	var/scan_state = ""
	/// If true, this turf will not call AfterChange during change_turf calls.
	var/defer_change = FALSE
	/// If true you can mine the mineral turf without tools.
	var/weak_turf = FALSE
	/// How long it takes to mine this turf with tools, before the tool's speed and the user's skill modifier are factored in.
	var/tool_mine_speed = 4 SECONDS
	/// How long it takes to mine this turf without tools, if it's weak.
	var/hand_mine_speed = 15 SECONDS
	/// Distance to the nearest open turf
	var/open_turf_distance = DEFAULT_BORDER_DISTANCE

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

/turf/closed/mineral/proc/spread_vein(ore_type)
	if(!ispath(ore_type, /obj/item/stack/ore))
		change_ore(ore_type)
		return

	var/obj/item/stack/ore/ore_path = ore_type
	if (!ore_path::vein_type)
		change_ore(ore_type)
		return

	// No need to recalculate ore vein size lists every time we want to spawn one
	var/static/list/vein_sizes = null
	if (!vein_sizes)
		vein_sizes = list()

	var/min_vein_size = ore_path::min_vein_size
	var/max_vein_size = ore_path::max_vein_size
	if (!vein_sizes[ore_path])
		var/list/ore_sizes = list()
		// Larger veins are rarer by default
		for (var/i in min_vein_size to max_vein_size)
			ore_sizes["[i]"] = max_vein_size - i + 1
		vein_sizes[ore_path] = ore_sizes

	var/vein_size = text2num(pick_weight(vein_sizes[ore_path]))

	switch (ore_path::vein_type)
		if (ORE_VEIN_CLUSTER)
			for (var/turf/closed/mineral/rock in range(vein_size, src))
				if (rock.mineral_type)
					continue

				var/spread_prob = 100
				// Easiest way to check for different rock types
				if (rock.base_icon_state != base_icon_state)
					spread_prob = 50

				if (rock == src || prob(spread_prob * sqrt(max(0, 1 - sqrt((x - rock.x) ** 2 + (y - rock.y) ** 2) / vein_size))))
					rock.change_ore(ore_path)

		if (ORE_VEIN_SCATTER)
			var/list/turf/closed/mineral/rocks = list()
			for (var/turf/closed/mineral/rock in range(vein_size, src))
				if (rock.base_icon_state != base_icon_state && prob(50))
					continue
				if (!rock.mineral_type)
					rocks += rock

			for (var/i in 1 to rand(min_vein_size ** 2, max_vein_size ** 2))
				var/turf/closed/mineral/rock = pick_n_take(rocks)
				if (istype(rock))
					rock.change_ore(ore_path, FALSE)
					rock.mineral_amt = 1

		if (ORE_VEIN_PLAIN)
			var/list/turf/closed/mineral/rocks = list()
			for (var/turf/closed/mineral/rock in range(vein_size, src))
				if (rock.base_icon_state != base_icon_state && prob(50))
					continue
				if (!rock.mineral_type)
					rocks += rock

			if (!length(rocks))
				return

			var/turf/first_end = pick(rocks)
			var/first_dist = get_dist(src, first_end)
			var/second_dist = vein_size - first_dist
			var/turf/second_end = locate(x - round((first_end.x - x) / first_dist * second_dist, 1), y - round((first_end.y - y) / first_dist * second_dist, 1), z)
			if (!istype(second_end))
				second_end = src

			rocks.Cut()
			for (var/turf/closed/mineral/rock in range(1, second_end))
				if (!rock.mineral_type)
					rocks += rock

			if (!length(rocks))
				return

			second_end = pick(rocks)
			for (var/turf/closed/mineral/rock in get_line(first_end, src) + get_line(second_end, src))
				rock.change_ore(ore_path)
				if (rock == src || prob(100 / get_dist(src, rock)))
					var/turf/closed/mineral/other_rock = get_step(rock, pick(GLOB.cardinals))
					if (istype(other_rock) && !other_rock.mineral_type)
						other_rock.change_ore(ore_path)

		if (ORE_VEIN_BRANCH)
			for (var/branch in 1 to rand(3, 5))
				var/list/turf/closed/mineral/rocks = list()
				for (var/turf/closed/mineral/rock in range(vein_size, src))
					if (rock.base_icon_state != base_icon_state && prob(50))
						continue
					if (!rock.mineral_type)
						rocks += rock

				if (!length(rocks))
					continue

				for (var/turf/closed/mineral/rock in get_line(src, pick(rocks)))
					if (!rock.mineral_type)
						rock.change_ore(ore_path)

/turf/closed/mineral/proc/change_ore(ore_type, random = TRUE)
	if (ispath(ore_type, /obj/item/boulder))
		scan_state = "rock_boulder" // Yes even the lowly boulder has a scan state
		spawned_boulder = /obj/item/boulder/gulag_expanded
		return

	if (random)
		mineral_amt = rand(1, 5)

	if (!ispath(ore_type, /obj/item/stack/ore))
		return

	var/obj/item/stack/ore/the_ore = ore_type
	scan_state = initial(the_ore.scan_state) // If it has a scan_state, switch to it
	mineral_type = ore_type // Everything else assumes that this is typed correctly so don't set it to non-ores thanks.

/turf/closed/mineral/proc/flash_scan()
	var/obj/effect/temp_visual/mining_overlay/scan_overlay = locate(/obj/effect/temp_visual/mining_overlay) in src
	if(scan_overlay)
		deltimer(scan_overlay.timerid)
		scan_overlay.timerid = QDEL_IN_STOPPABLE(scan_overlay, scan_overlay.duration)
		animate(scan_overlay, alpha = 0, time = scan_overlay.duration, easing = scan_overlay.easing_style)
		return
	scan_overlay = new(src)
	var/mutable_appearance/scan_state_overlay = mutable_appearance(scan_icon, scan_state)
	scan_state_overlay.pixel_x = 224
	scan_state_overlay.pixel_y = 224
	scan_overlay.add_overlay(scan_state_overlay)

/turf/closed/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()

/turf/closed/mineral/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers, exp_multiplier = 1)
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
	if(!I.use_tool(src, user, tool_mine_speed, volume=50))
		TIMER_COOLDOWN_END(src, REF(user)) //if we fail we can start again immediately
		return

	if(ismineralturf(src))
		gets_drilled(user, exp_multiplier)
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
	if(mineral_type && (mineral_amt > 0))
		new mineral_type(src, mineral_amt)
		SSblackbox.record_feedback("tally", "ore_mined", mineral_amt, mineral_type)
	if(spawned_boulder)
		var/obj/item/boulder/wall_boulder = new spawned_boulder(src)
		wall_boulder.platform_lifespan = PLATFORM_LIFE_GULAG
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(exp_multiplier)
			if (mineral_type && (mineral_amt > 0))
				H.mind.adjust_experience(/datum/skill/mining, initial(mineral_type.mine_experience) * mineral_amt * exp_multiplier)
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

/// When the turf gets drilled from an AOE explosion
/// Has a chance of not being drilled based on own hardness
/turf/closed/mineral/proc/drill_aoe(mob/user, exp_multiplier = 0)
	var/speed_change = /turf/closed/mineral::tool_mine_speed / tool_mine_speed
	// Probability scaling isn't linear to still mine somewhat reliably in dense rocks
	// Rocks with ores always get broken by AOE
	if (speed_change >= 1 || mineral_type || spawned_boulder || prob(100 * sqrt(speed_change)))
		return gets_drilled(user, exp_multiplier)

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	balloon_alert(user, "digging...")
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
	if(do_after(user, tool_mine_speed, target = src))
		gets_drilled(user)

/turf/closed/mineral/attack_hulk(mob/living/carbon/human/H)
	..()
	if(do_after(H, tool_mine_speed * 1.25, target = src))
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

	var/hardness = /turf/closed/mineral::tool_mine_speed / tool_mine_speed
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gets_drilled()
		if(EXPLODE_HEAVY)
			if(prob(90 * hardness))
				gets_drilled()
		if(EXPLODE_LIGHT)
			if(prob(75 * hardness))
				gets_drilled()

	return TRUE

/turf/closed/mineral/blob_act(obj/structure/blob/B)
	if(prob(50 * /turf/closed/mineral::tool_mine_speed / tool_mine_speed))
		gets_drilled()

/proc/calculate_rock_edges()
	var/cardinals = GLOB.cardinals.Copy() // i'm sorry
	for(var/mining_z in SSmapping.levels_by_trait(ZTRAIT_MINING))
		var/list/adjacent_minerals = list()
		for(var/turf/open/open_turf in Z_TURFS(mining_z))
			for (var/neighbour_dir in cardinals)
				var/turf/neighbour = get_step(open_turf, neighbour_dir)
				if (!ismineralturf(neighbour))
					continue

				var/turf/closed/mineral/rock = neighbour
				if(rock.open_turf_distance != DEFAULT_BORDER_DISTANCE)
					continue

				rock.open_turf_distance = 1
				adjacent_minerals += rock
				continue

		var/index = 1
		while(index <= length(adjacent_minerals))
			var/turf/closed/mineral/rock = adjacent_minerals[index]
			index += 1
			for (var/neighbour_dir in cardinals)
				var/turf/neighbour = get_step(rock, neighbour_dir)
				if (!ismineralturf(neighbour))
					continue

				var/turf/closed/mineral/rock_neighbour = neighbour
				if(rock_neighbour.open_turf_distance == DEFAULT_BORDER_DISTANCE)
					rock_neighbour.open_turf_distance = rock.open_turf_distance + 1
					adjacent_minerals += rock_neighbour

/turf/closed/mineral/random
	/// What are the base odds that this turf spawns a mineral in the wall on initialize?
	var/mineral_chance = 7
	/// Does this turf's chance of spawning ore increase with distance to open air?
	var/exposure_based = FALSE
	/// Chance of spawning a specific mineral per type, cached for speed
	var/static/list/mineral_chances_by_type = list()
	/// Chance of spawning a specific mineral per type per depth
	var/static/list/mineral_chances_by_depth = list()
	/// Sum of ore spawn probabilities per type per depth
	var/static/list/spawn_chances_by_depth = list()

/// Returns a list of the chances for minerals to spawn.
/// Will only run once, and will then be cached.
/turf/closed/mineral/random/proc/mineral_chances()
	return list(
		/obj/item/stack/ore/bananium = check_holidays(APRIL_FOOLS) ? 3 : 0,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/ore/gold = 8,
		/obj/item/stack/ore/iron = 18, // Iron and plasma are this low due to how much they spread into veins
		/obj/item/stack/ore/plasma = 12,
		/obj/item/stack/ore/silver = 8,
		/obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite = 4,
	)

/turf/closed/mineral/random/Initialize(mapload)
	. = ..()
	if (exposure_based)
		SSore_generation.ore_turfs += src
		return

	var/list/spawn_chance_list = mineral_chances_by_type[type]
	if (isnull(spawn_chance_list))
		mineral_chances_by_type[type] = expand_weights(mineral_chances())
		spawn_chance_list = mineral_chances_by_type[type]

	if (prob(mineral_chance))
		spawn_ore(pick(spawn_chance_list))

/turf/closed/mineral/random/proc/randomize_ore()
#ifdef TESTING
	if (open_turf_distance == -1)
		color = COLOR_BLUE
	else
		color = BlendRGB(COLOR_GREEN, COLOR_RED, clamp((open_turf_distance - 1) / 5, 0, 0.99))
	maptext_x = 4
	maptext_y = 4
	maptext = MAPTEXT_TINY_UNICODE("[open_turf_distance]")
#endif

	var/list/spawn_type_list = mineral_chances_by_depth[type]
	if (isnull(spawn_type_list))
		spawn_type_list = list()
		mineral_chances_by_depth[type] = spawn_type_list

	var/list/ore_depth_chances = spawn_chances_by_depth[type]
	if (isnull(ore_depth_chances))
		ore_depth_chances = list()
		spawn_chances_by_depth[type] = ore_depth_chances

	var/list/spawn_chance_list = spawn_type_list["[open_turf_distance]"]
	var/ore_depth_chance = ore_depth_chances["[open_turf_distance]"]
	if (isnull(spawn_chance_list))
		spawn_chance_list = mineral_chances()
		var/total_spawn_sum = 0
		var/base_spawn_sum = 0
		var/lowest_factor = 1
		for (var/obj/item/stack/ore/ore_type as anything in spawn_chance_list)
			if (!spawn_chance_list[ore_type])
				continue
			base_spawn_sum += spawn_chance_list[ore_type]
			if (!ispath(ore_type, /obj/item/stack/ore))
				total_spawn_sum += spawn_chance_list[ore_type]
				continue

			var/depth_factor = 1 / (1 + abs(ore_type::vein_distance - open_turf_distance))
			lowest_factor = clamp(ceil(1 / (spawn_chance_list[ore_type] * depth_factor)), lowest_factor, ORE_CHANCE_PRECISION)
			spawn_chance_list[ore_type] *= depth_factor
			total_spawn_sum += spawn_chance_list[ore_type]

		for (var/obj/item/stack/ore/ore_type as anything in spawn_chance_list)
			spawn_chance_list[ore_type] = floor(spawn_chance_list[ore_type] * lowest_factor)

		ore_depth_chance = mineral_chance * total_spawn_sum / base_spawn_sum

		LAZYSET(SSore_generation.ore_spread_probabilities[type], "[open_turf_distance]", spawn_chance_list.Copy() + list("chance" = ore_depth_chance, "count" = 0))

		spawn_chance_list = expand_weights(spawn_chance_list)

		spawn_type_list["[open_turf_distance]"] = spawn_chance_list
		ore_depth_chances["[open_turf_distance]"] = ore_depth_chance

	SSore_generation.ore_spread_probabilities[type]["[open_turf_distance]"]["count"] += 1
	if (prob(ore_depth_chance))
		spawn_ore(pick(spawn_chance_list))

/turf/closed/mineral/random/proc/spawn_ore(ore_path)
	if (!SSore_generation.ores_generated[ore_path])
		SSore_generation.ores_generated[ore_path] = 0
	SSore_generation.ores_generated[ore_path] += 1

	if(!ispath(ore_path, /turf))
		change_ore(ore_path)
		if (!ispath(ore_path, /obj/item/stack/ore))
			return
		var/obj/item/stack/ore/ore_type = ore_path
		if (prob(ore_type::spread_chance))
			spread_vein(ore_path)
		return

	var/stored_flags = 0
	if(turf_flags & NO_RUINS)
		stored_flags |= NO_RUINS
	var/turf/new_turf = ChangeTurf(ore_path, null, CHANGETURF_IGNORE_AIR)
	new_turf.flags_1 |= stored_flags

	if(ismineralturf(new_turf))
		src = new_turf
		new_turf.levelupdate()
		return

	var/turf/closed/mineral/new_rock = new_turf
	new_rock.turf_type = src.turf_type
	src = new_rock
	new_rock.levelupdate()

	if(mineral_type && !mineral_amt)
		stack_trace("Mineral turf with mineral_amt being zero initialized at [src.x], [src.y], [src.z] ([get_area(src)])")

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineral_chance = 14
	exposure_based = FALSE

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
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	exposure_based = FALSE

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
	mineral_chance = 2

/turf/closed/mineral/random/low_chance/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 4,
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/silver = 6,
		/obj/item/stack/ore/titanium = 4,
		/obj/item/stack/ore/uranium = 2,
		/turf/closed/mineral/gibtonite = 2,
	)

//extremely low chance of rare ores, meant mostly for populating stations with large amounts of asteroid
/turf/closed/mineral/random/stationside
	icon_state = "rock_nochance"
	mineral_chance = 1

/turf/closed/mineral/random/stationside/mineral_chances()
	return list(
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/plasma = 3,
		/obj/item/stack/ore/silver = 4,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/uranium = 1,
	)

/turf/closed/mineral/random/volcanic
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	exposure_based = TRUE
	mineral_chance = 7 // N% functionally, 7.17% default, accounts for ~65% turfs

/turf/closed/mineral/random/volcanic/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/ore/gold = 8,
		/obj/item/stack/ore/iron = 16,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/silver = 8,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/uranium = 7,
		/turf/closed/mineral/gibtonite/volcanic = 2,
	)

/turf/closed/mineral/random/volcanic/red_rock
	name = "siderite"
	icon = MAP_SWITCH('icons/turf/walls/red_rock.dmi', 'icons/turf/mining.dmi')
	icon_state = "red_rock"
	base_icon_state = "red_rock"
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_RED_ROCK_WALLS
	canSmoothWith = SMOOTH_GROUP_RED_ROCK_WALLS
	tool_mine_speed = 5 SECONDS // 25% harder than basalt
	hand_mine_speed = 17 SECONDS
	mineral_chance = 8 // N% functionally, 6.67% default, accounts for ~22% turfs

/turf/closed/mineral/random/volcanic/red_rock/mineral_chances()
	return list(
		// Cannot spawn these two
		// /obj/item/stack/ore/bluespace_crystal = 0,
		// /obj/item/stack/ore/diamond = 0,
		/obj/item/stack/ore/gold = 2,
		/obj/item/stack/ore/iron = 32, // Iron and plasma are this low due to how much they spread into veins
		/obj/item/stack/ore/plasma = 6,
		/obj/item/stack/ore/silver = 14,
		/obj/item/stack/ore/titanium = 25,
		/obj/item/stack/ore/uranium = 3,
		/turf/closed/mineral/gibtonite/volcanic/red_rock = 1,
	)

/turf/closed/mineral/random/volcanic/shale
	name = "shale"
	icon = MAP_SWITCH('icons/turf/walls/shale.dmi', 'icons/turf/mining.dmi')
	icon_state = "shale"
	base_icon_state = "shale"
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_SHALE_WALLS
	canSmoothWith = SMOOTH_GROUP_SHALE_WALLS
	tool_mine_speed = 7 SECONDS // 75% harder than basalt
	hand_mine_speed = 20 SECONDS
	mineral_chance = 8 // N% functionally, 7.01% default, accounts for ~13% turfs

/turf/closed/mineral/random/volcanic/shale/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1.5,
		/obj/item/stack/ore/diamond = 3,
		/obj/item/stack/ore/gold = 12,
		/obj/item/stack/ore/iron = 10, // Iron and plasma are this low due to how much they spread into veins
		/obj/item/stack/ore/plasma = 28,
		/obj/item/stack/ore/silver = 4,
		/obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/uranium = 14,
		/turf/closed/mineral/gibtonite/volcanic/shale = 3,
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
	exposure_based = TRUE

/turf/closed/mineral/random/snow/change_ore(ore_type, random = TRUE)
	. = ..()
	if(mineral_type)
		icon = 'icons/turf/walls/icerock_wall.dmi'
		icon_state = "icerock_wall-0"
		base_icon_state = "icerock_wall"
		smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/random/snow/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/ore/gold = 8,
		/obj/item/stack/ore/iron = 22,
		/obj/item/stack/ore/plasma = 12,
		/obj/item/stack/ore/silver = 8,
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
	mineral_chance = 11

/turf/closed/mineral/random/snow/underground/mineral_chances()
	return list(
		/obj/item/stack/ore/bananium = 1,
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stack/ore/diamond = 4,
		/obj/item/stack/ore/gold = 20,
		/obj/item/stack/ore/iron = 10, // Iron and plasma are this low due to how much they spread into veins,
		/obj/item/stack/ore/plasma = 14,
		/obj/item/stack/ore/silver = 24,
		/obj/item/stack/ore/titanium = 22,
		/obj/item/stack/ore/uranium = 10,
		/turf/closed/mineral/gibtonite/ice/icemoon = 8,
	)

/turf/closed/mineral/random/snow/high_chance
	exposure_based = FALSE

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
	name = "basalt"
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

/turf/closed/mineral/random/labormineral/ice/change_ore(ore_type, random = TRUE)
	. = ..()
	if(mineral_type)
		icon = 'icons/turf/walls/icerock_wall.dmi'
		icon_state = "icerock_wall-0"
		base_icon_state = "icerock_wall"
		smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/iron
	mineral_type = /obj/item/stack/ore/iron
	scan_state = "rock_iron"

/turf/closed/mineral/iron/volcanic
	name = "basalt"
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
	mineral_type = /obj/item/stack/ore/uranium
	scan_state = "rock_uranium"

/turf/closed/mineral/uranium/volcanic
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/diamond
	mineral_type = /obj/item/stack/ore/diamond
	scan_state = "rock_diamond"

/turf/closed/mineral/diamond/volcanic
	name = "basalt"
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
	mineral_type = /obj/item/stack/ore/gold
	scan_state = "rock_gold"

/turf/closed/mineral/gold/volcanic
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver
	mineral_type = /obj/item/stack/ore/silver
	scan_state = "rock_silver"

/turf/closed/mineral/silver/volcanic
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver/ice/icemoon
	turf_type = /turf/open/misc/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/closed/mineral/titanium
	mineral_type = /obj/item/stack/ore/titanium
	scan_state = "rock_titanium"

/turf/closed/mineral/titanium/volcanic
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/plasma
	mineral_type = /obj/item/stack/ore/plasma
	scan_state = "rock_plasma"

/turf/closed/mineral/plasma/volcanic
	name = "basalt"
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
	mineral_type = /obj/item/stack/ore/bananium
	mineral_amt = 3
	scan_state = "rock_bananium"

/turf/closed/mineral/bananium/volcanic
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bscrystal
	mineral_type = /obj/item/stack/ore/bluespace_crystal
	mineral_amt = 1
	scan_state = "rock_bscrystal"

/turf/closed/mineral/bscrystal/volcanic
	name = "basalt"
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
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	defer_change = TRUE

/// Rock type which replaces itself with whichever rock would've been generated by the biome underneath
/turf/closed/mineral/volcanic/lava_land_surface/biome_replace
	icon = 'icons/turf/mining.dmi'
	icon_state = "volcanic_biome"
	smoothing_flags = NONE

/turf/closed/mineral/volcanic/lava_land_surface/biome_replace/Initialize(mapload)
	. = ..()
	var/area/cur_area = loc
	if (!cur_area) // what
		return

	// Just spawn a normal lavaland rock if we fail to get a mapgen, such as being spawned over lava
	var/supposed_type = /turf/closed/mineral/volcanic/lava_land_surface
	var/datum/map_generator/cave_generator/map_generator = cur_area.get_generator()
	if (istype(map_generator))
		for (var/datum/biome/biome as anything in map_generator.generated_turfs_per_biome)
			var/list/gen_turfs = map_generator.generated_turfs_per_biome[biome]
			if (gen_turfs[src])
				// Ignore what we were supposed to spawn as in favor of the closed turf
				supposed_type = biome.closed_turf_type
				break

	var/turf/new_turf = new supposed_type(src)
	if(turf_flags & NO_RUINS)
		new_turf.turf_flags |= NO_RUINS

/// Wall piece
/turf/closed/mineral/ash_rock
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
	icon = MAP_SWITCH('icons/turf/walls/red_rock.dmi', 'icons/turf/mining.dmi')
	icon_state = "red_rock"
	base_icon_state = "red_rock"
	layer = EDGED_TURF_LOWER_LAYER
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_RED_ROCK_WALLS
	canSmoothWith = SMOOTH_GROUP_RED_ROCK_WALLS

/turf/closed/mineral/random/stationside/asteroid
	name = "iron rock"
	icon = MAP_SWITCH('icons/turf/walls/red_rock.dmi', 'icons/turf/mining.dmi')
	icon_state = "red_rock"
	base_icon_state = "red_rock"
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_RED_ROCK_WALLS
	canSmoothWith = SMOOTH_GROUP_RED_ROCK_WALLS

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
	mineral_amt = 1
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

/turf/closed/mineral/gibtonite/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers, exp_multiplier = 1)
	var/previous_stage = stage
	if(istype(attacking_item, /obj/item/goliath_infuser_hammer) && stage == GIBTONITE_ACTIVE)
		user.visible_message(span_notice("[user] digs [attacking_item] to [src]..."), span_notice("Your tendril hammer instictively digs and wraps around [src] to stop it..."))
		defuse(user)
	else if(istype(attacking_item, /obj/item/mining_scanner) || istype(attacking_item, /obj/item/t_scanner/adv_mining_scanner) && stage == GIBTONITE_ACTIVE)
		user.visible_message(span_notice("[user] holds [attacking_item] to [src]..."), span_notice("You use [attacking_item] to locate where to cut off the chain reaction and attempt to stop it..."))
		defuse(user)
	. = ..()
	if(istype(attacking_item, /obj/item/clothing/gloves/gauntlets) && previous_stage == GIBTONITE_UNSTRUCK && stage == GIBTONITE_ACTIVE && istype(user))
		user.Immobilize(0.5 SECONDS)
		user.throw_at(get_ranged_target_turf(src, get_dir(src, user), 5), range = 5, speed = 3, spin = FALSE)
		user.visible_message(span_danger("[user] hit gibtonite with [attacking_item.name], launching [user.p_them()] back!"), span_danger("You've struck gibtonite! Your [attacking_item.name] launched you back!"))

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null)
	if(stage != GIBTONITE_UNSTRUCK)
		return

	activated_overlay = mutable_appearance('icons/turf/smoothrocks_overlays.dmi', "rock_Gibtonite_inactive", ON_EDGED_TURF_LAYER) //shows in gaps between pulses if there are any
	activated_overlay.pixel_x = 2
	activated_overlay.pixel_y = 2
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
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0 && mineral_amt >= 1)
		var/mutable_appearance/boom_overlay = mutable_appearance('icons/turf/smoothrocks_overlays.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER + 0.1)
		boom_overlay.pixel_x = 2
		boom_overlay.pixel_y = 2
		flick_overlay_view(boom_overlay, 0.5 SECONDS) //makes the animation pulse one time per tick
		det_time--
		sleep(0.5 SECONDS)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0 && mineral_amt >= 1)
			var/turf/bombturf = get_turf(src)
			mineral_amt = 0
			stage = GIBTONITE_DETONATE
			explosion(bombturf, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flame_range = 0, flash_range = 0, adminlog = notify_admins, explosion_cause = src)

/turf/closed/mineral/gibtonite/proc/defuse(mob/living/defuser)
	if(stage != GIBTONITE_ACTIVE)
		return
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

	if(stage == GIBTONITE_UNSTRUCK && mineral_amt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,TRUE)
		explosive_reaction(user)
		return
	if(stage == GIBTONITE_ACTIVE && mineral_amt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineral_amt = 0
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
	name = "basalt"
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gibtonite/volcanic/red_rock
	name = "siderite"
	icon = MAP_SWITCH('icons/turf/walls/red_rock.dmi', 'icons/turf/mining.dmi')
	icon_state = "red_rock"
	base_icon_state = "red_rock"
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_RED_ROCK_WALLS
	canSmoothWith = SMOOTH_GROUP_RED_ROCK_WALLS
	tool_mine_speed = 5 SECONDS // 25% harder than basalt
	hand_mine_speed = 17 SECONDS

/turf/closed/mineral/gibtonite/volcanic/shale
	name = "shale"
	icon = MAP_SWITCH('icons/turf/walls/shale.dmi', 'icons/turf/mining.dmi')
	icon_state = "shale"
	base_icon_state = "shale"
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_SHALE_WALLS
	canSmoothWith = SMOOTH_GROUP_SHALE_WALLS
	tool_mine_speed = 7 SECONDS // 75% harder than basalt
	hand_mine_speed = 20 SECONDS

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
	name = "very strong rock"
	desc = "Seems to be stronger than the other rocks in the area. Only a master of mining techniques could destroy this."
	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1
	icon = MAP_SWITCH('icons/turf/walls/rock_wall.dmi', 'icons/turf/mining.dmi')
	base_icon_state = "rock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/strong/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers, exp_multiplier = 1)
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
#undef DEFAULT_BORDER_DISTANCE
