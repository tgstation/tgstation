/// Ratwood's saplings and seedlings (code/game/objects/structures/roguetown/treesapling.dm, bushsapling.dm,
/// roguejobs/alchemist/herb_seeds.dm): planted in soil, they drink its water and eat its nutrition and grow as fast as the soil
/// grows things. A tree sapling becomes a shrub, then a young tree that stands on its own and finally a tree; a bush sapling a
/// sprout, then a bush that bears fruit and, left untrimmed, a tall hedge; a herb seedling blooms into its herb. Watered once and
/// left dry, a sapling withers. They work on SSobj every 2 seconds (Ratwood SSprocessing every second); their soil's water and
/// fertilizer are given through them.

/obj/structure/tree_sapling
	parent_type = /obj/structure/rockhill
	name = "tree sapling"
	desc = "A tender sapling bedded in mounded soil. It needs regular watering to take root."
	density = FALSE
	opacity = FALSE
	max_integrity = 20
	resistance_flags = FLAMMABLE
	icon = 'modular_redtard/rockhill/icons/obj/flora/ausflora.dmi'
	icon_state = "palebush_2"
	layer = OBJ_LAYER
	var/stage = ROGUE_TREESAP_SAPLING
	var/growth_progress = 0
	var/dead = FALSE
	var/obj/structure/soil/linked_soil
	/// Keeps it from dying before its first watering.
	var/has_grown = FALSE
	/// What tree to spawn when fully grown
	var/tree_final_type = /obj/structure/flora/newtree
	// Per-stage icon data (stage 1 uses own icon/icon_state)
	var/stage2_icon = 'modular_redtard/rockhill/icons/obj/flora/ausflora.dmi'
	var/stage2_state = "sunnybush_1"
	var/stage3_icon = 'modular_redtard/rockhill/icons/roguetown/misc/foliagetall.dmi'
	var/stage3_state = "t12"
	var/dead_icon = ROGUE_CROPS_ICON
	var/dead_state = "lemon3"
	// pixel offsets applied when advancing stages
	var/stage2_pixel_x = 0
	var/stage2_pixel_y = 0
	var/stage3_pixel_x = 1
	var/stage3_pixel_y = 0

/obj/structure/tree_sapling/Initialize(mapload)
	. = ..()
	linked_soil = locate(/obj/structure/soil) in get_turf(src)
	if(linked_soil)
		RegisterSignal(linked_soil, COMSIG_QDELETING, PROC_REF(on_soil_deleted))
	if(rogue_farming_enabled())
		START_PROCESSING(SSobj, src)

/obj/structure/tree_sapling/Destroy()
	if(linked_soil)
		UnregisterSignal(linked_soil, COMSIG_QDELETING)
	linked_soil = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/tree_sapling/proc/on_soil_deleted(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	linked_soil = null

/obj/structure/tree_sapling/process(seconds_per_tick)
	if(dead)
		return PROCESS_KILL
	var/dt = seconds_per_tick * (1 SECONDS)
	if(stage <= ROGUE_TREESAP_SHRUB)
		if(QDELETED(linked_soil))
			wither_and_die()
			return PROCESS_KILL
		if(rogue_sapling_drink(linked_soil, dt))
			has_grown = TRUE
			growth_progress += dt * linked_soil.get_environmental_growth_multiplier()
		else if(has_grown)
			growth_progress -= dt * rogue_value("farm_sapling_wither")
			if(growth_progress <= -rogue_value("farm_sapling_death"))
				wither_and_die()
				return PROCESS_KILL
	else
		growth_progress += dt
	if(growth_progress >= (stage == ROGUE_TREESAP_YOUNG ? rogue_value("farm_tree_young_time") : rogue_value("farm_tree_stage_time")))
		advance_stage()

/obj/structure/tree_sapling/proc/wither_and_die()
	STOP_PROCESSING(SSobj, src)
	dead = TRUE
	name = "withered sapling"
	set_density(FALSE)
	set_opacity(FALSE)
	pixel_x = 0
	icon = dead_icon
	icon_state = dead_state
	visible_message(span_warning("[src] withers and dies from lack of water."))

/obj/structure/tree_sapling/proc/advance_stage()
	growth_progress = 0
	stage++
	switch(stage)
		if(ROGUE_TREESAP_SHRUB)
			icon = stage2_icon
			icon_state = stage2_state
			pixel_x = stage2_pixel_x
			pixel_y = stage2_pixel_y
			max_integrity = 100
			update_integrity(100)
			rockhill_dulling = "bashchop"
			rockhill_static_debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1)
			rockhill_break_sounds = ROGUE_PLANTCROSS_SOUNDS
		if(ROGUE_TREESAP_YOUNG)
			for(var/obj/structure/soil/soil in get_turf(src))
				qdel(soil)
			linked_soil = null
			icon = stage3_icon
			icon_state = stage3_state
			set_density(TRUE)
			set_opacity(TRUE)
			pixel_x = stage3_pixel_x
			pixel_y = stage3_pixel_y
			max_integrity = 150
			update_integrity(150)
			rockhill_dulling = "cut"
			rockhill_hit_sounds = list('modular_redtard/rockhill/sound/misc/woodhit.ogg')
			rockhill_break_sounds = list('modular_redtard/rockhill/sound/misc/treefall.ogg')
		else
			spawn_final_tree()

/obj/structure/tree_sapling/proc/spawn_final_tree()
	var/atom/movable/final_tree = new tree_final_type(get_turf(src))
	final_tree.pixel_x = pixel_x
	final_tree.pixel_y = pixel_y
	qdel(src)

/obj/structure/tree_sapling/proc/drop_withered_loot()
	if(prob(20))
		new /obj/item/grown/log/tree/small(get_turf(src))
		return
	new /obj/item/grown/log/tree/stick(get_turf(src))
	new /obj/item/grown/log/tree/stick(get_turf(src))

/obj/structure/tree_sapling/atom_destruction(damage_flag)
	if(stage == ROGUE_TREESAP_YOUNG && !dead)
		new /obj/item/grown/log/tree(get_turf(src))
		if(prob(50))
			new /obj/item/grown/log/tree/stick(get_turf(src))
	return ..()

/obj/structure/tree_sapling/examine(mob/user)
	// While alive and rooted in soil, examine shows the soil plot: it holds all the growth and status info.
	if(!dead && !QDELETED(linked_soil))
		return linked_soil.examine(user)
	. = ..()
	if(dead)
		. += span_warning("It has withered and died. Shovel it out to clear the spot.")
		return
	// Standalone young tree, its soil gone.
	if(stage == ROGUE_TREESAP_YOUNG)
		. += span_notice("A young tree still taking root. It should grow on its own now.")
		if(isliving(user))
			var/mob/living/living_user = user
			if(living_user.rogue_learned_rank(ROGUE_FARMING_SKILL) >= ROGUE_RANK_EXPERT || HAS_TRAIT(living_user, TRAIT_SEEDKNOW))
				. += span_info("Estimated time to finish growing: [DisplayTimeText(max(rogue_value("farm_tree_young_time") - growth_progress, 0))].")

/obj/structure/tree_sapling/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(stage <= ROGUE_TREESAP_SHRUB && !dead && !QDELETED(linked_soil))
		if(linked_soil.try_handle_watering(tool, user) || linked_soil.try_handle_fertilizing(tool, user))
			return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/rogueweapon/shovel))
		to_chat(user, span_notice("I begin uprooting [src]..."))
		playsound(src, ROGUE_DIG_SOUND, 80, TRUE)
		if(do_after(user, rogue_value("farm_sapling_dig_time"), target = src))
			if(dead)
				drop_withered_loot()
			to_chat(user, span_notice("I remove [src]."))
			qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/tree_sapling/pine
	name = "pine sapling"
	desc = "A tender pine sapling. Keep it watered and it will grow into a tall pine tree."
	icon_state = "palebush_3"
	stage2_state = "pointybush_1"
	stage3_state = "t11"
	dead_state = "apple3"
	tree_final_type = /obj/structure/flora/roguetree/pine

/obj/structure/tree_sapling/sakura
	name = "sakura sapling"
	desc = "A tender cherry-blossom sapling. Water it faithfully and it will reward you with clouds of pink bloom."
	icon_state = "palebush_1"
	stage2_state = "pinkbush"
	stage3_state = "t10"
	stage3_pixel_x = -10
	dead_state = "apple3"
	tree_final_type = /obj/structure/flora/sakura

// Do not copy the sapling's pixel_x to the sakura tree: the tree has its own offset.
/obj/structure/tree_sapling/sakura/spawn_final_tree()
	new tree_final_type(get_turf(src))
	qdel(src)

/// A sapling or a seedling takes its share of its soil's water and nutrition, a sapling's by default; FALSE when the soil has
/// none to give (Ratwood process()).
/proc/rogue_sapling_drink(obj/structure/soil/soil, dt, water_use, nutrition_use)
	if(soil.water <= 0 || soil.nutrition <= 0)
		return FALSE
	var/rate = dt / (1 MINUTES)
	soil.adjust_water(-rate * (isnull(water_use) ? rogue_value("farm_sapling_water_use") : water_use))
	soil.adjust_nutrition(-rate * (isnull(nutrition_use) ? rogue_value("farm_sapling_nutrition_use") : nutrition_use))
	return TRUE

/obj/structure/bush_sapling
	parent_type = /obj/structure/rockhill
	name = "bush sapling"
	desc = "A small bush sapling, ready for planting. It draws from the soil while it takes root."
	density = FALSE
	opacity = FALSE
	max_integrity = 15
	resistance_flags = FLAMMABLE
	icon = ROGUE_CROPS_ICON
	icon_state = "blackberry2"
	layer = OBJ_LAYER
	var/stage = ROGUE_BUSHSAP_SAPLING
	var/growth_progress = 0
	var/dead = FALSE
	var/obj/structure/soil/linked_soil
	/// What a grown bush bears, as a wild bush does (Ratwood bushtype).
	var/bushtype = null
	var/list/looty = list()
	/// world.time threshold for loot refresh
	var/res_replenish = 0
	/// Keeps it from dying before its first watering.
	var/has_grown = FALSE

/obj/structure/bush_sapling/Initialize(mapload)
	. = ..()
	linked_soil = locate(/obj/structure/soil) in get_turf(src)
	if(linked_soil)
		RegisterSignal(linked_soil, COMSIG_QDELETING, PROC_REF(on_soil_deleted))
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)
	if(rogue_farming_enabled())
		START_PROCESSING(SSobj, src)

/obj/structure/bush_sapling/Destroy()
	if(linked_soil)
		UnregisterSignal(linked_soil, COMSIG_QDELETING)
	linked_soil = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bush_sapling/proc/on_soil_deleted(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	linked_soil = null

/obj/structure/bush_sapling/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!dead && isliving(arrived))
		playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 50, FALSE, -1)

/obj/structure/bush_sapling/process(seconds_per_tick)
	if(dead)
		return PROCESS_KILL
	var/dt = seconds_per_tick * (1 SECONDS)
	if(stage <= ROGUE_BUSHSAP_BUDDING)
		if(QDELETED(linked_soil))
			wither_and_die()
			return PROCESS_KILL
		if(rogue_sapling_drink(linked_soil, dt))
			has_grown = TRUE
			growth_progress += dt * linked_soil.get_environmental_growth_multiplier()
		else if(has_grown)
			growth_progress -= dt * rogue_value("farm_sapling_wither")
			if(growth_progress <= -rogue_value("farm_sapling_death"))
				wither_and_die()
				return PROCESS_KILL
	else
		growth_progress += dt
	if(growth_progress >= (stage == ROGUE_BUSHSAP_MATURE ? rogue_value("farm_bush_hedge_time") : rogue_value("farm_bush_stage_time")))
		advance_stage()

/obj/structure/bush_sapling/proc/wither_and_die()
	STOP_PROCESSING(SSobj, src)
	dead = TRUE
	name = "dead bush sapling"
	set_density(FALSE)
	set_opacity(FALSE)
	pixel_x = 0
	icon = ROGUE_CROPS_ICON
	icon_state = "apple3"
	visible_message(span_warning("[src] withers and dies from poor soil conditions."))

/obj/structure/bush_sapling/proc/advance_stage()
	growth_progress = 0
	stage++
	switch(stage)
		if(ROGUE_BUSHSAP_BUDDING)
			name = "bush sprout"
			icon = 'modular_redtard/rockhill/icons/roguetown/misc/foliage.dmi'
			icon_state = "bush2"
		if(ROGUE_BUSHSAP_MATURE)
			name = "bush"
			for(var/obj/structure/soil/soil in get_turf(src))
				qdel(soil)
			linked_soil = null
			// Pick loot type, same weighting as the wild bush
			if(isnull(bushtype))
				bushtype = pick_weight(list(
					/obj/item/reagent_containers/food/snacks/grown/berries/rogue = 5,
					/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison = 3,
					/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed = 1,
				))
			loot_replenish()
			icon = 'modular_redtard/rockhill/icons/roguetown/misc/foliage.dmi'
			icon_state = "bush2"
			// Match regular wild bush integrity and add blade dulling
			max_integrity = 100
			update_integrity(100)
			rockhill_dulling = "cut"
			rockhill_break_sounds = ROGUE_PLANTCROSS_SOUNDS
		else
			spawn_hedge()

/obj/structure/bush_sapling/proc/loot_replenish()
	looty = list()
	if(bushtype)
		looty += bushtype
	if(prob(66))
		looty += /obj/item/natural/thorn
	looty += /obj/item/natural/fibers

/obj/structure/bush_sapling/proc/spawn_hedge()
	new /obj/structure/flora/roguegrass/bush/wall/tall/grown(get_turf(src))
	qdel(src)

/obj/structure/bush_sapling/atom_destruction(damage_flag)
	if(stage == ROGUE_BUSHSAP_MATURE && !dead)
		// Drop loot like a wild bush being destroyed
		new /obj/item/natural/fibers(get_turf(src))
		new /obj/item/natural/thorn(get_turf(src))
		if(length(looty))
			var/loot_type = pick(looty)
			new loot_type(get_turf(src))
	return ..()

/obj/structure/bush_sapling/examine(mob/user)
	// While still rooted in soil (stages 1-2), examine shows the soil plot: it holds all the status and growth info.
	if(!dead && !QDELETED(linked_soil))
		return linked_soil.examine(user)
	. = ..()
	if(dead)
		. += span_warning("It has withered and died. Shovel it out to clear the spot.")
		return
	// Standalone mature bush, its soil gone.
	if(stage == ROGUE_BUSHSAP_MATURE)
		var/hedge_time = rogue_value("farm_bush_hedge_time")
		var/time_to_hedge = max(hedge_time - growth_progress, 0)
		if(growth_progress >= hedge_time * 0.7)
			. += span_warning("It is looking overgrown. Shear it soon, or it will become a tall hedge in [DisplayTimeText(time_to_hedge)].")
		else
			. += span_notice("A mature bush. Shear it with scissors to keep it manageable, or leave it to grow into a taller hedge in [DisplayTimeText(time_to_hedge)].")

/// Ratwood attack_hand() at the bush stage: searched like a wild bush.
/obj/structure/bush_sapling/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || stage != ROGUE_BUSHSAP_MATURE || dead || !isliving(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 50, FALSE, -1)
	INVOKE_ASYNC(src, PROC_REF(search_bush), user)
	return TRUE

/obj/structure/bush_sapling/proc/search_bush(mob/living/user)
	if(!do_after(user, rogue_value("farm_bush_search_time"), target = src))
		return
	if(!length(looty) && world.time > res_replenish)
		loot_replenish()
	if(prob(rogue_value("farm_bush_find_chance")) && length(looty))
		if(length(looty) == 1)
			res_replenish = world.time + rogue_value("farm_bush_regrow_time")
		var/found_type = pick_n_take(looty)
		var/obj/item/found = new found_type(user.loc)
		user.put_in_hands(found)
		user.visible_message(span_notice("[user] finds [found] in [src]."))
		return
	user.visible_message(span_warning("[user] searches through [src]."))
	if(!length(looty))
		to_chat(user, span_warning("Picked clean... I should try later."))

/obj/structure/bush_sapling/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(stage <= ROGUE_BUSHSAP_BUDDING && !dead && !QDELETED(linked_soil))
		if(linked_soil.try_handle_watering(tool, user) || linked_soil.try_handle_fertilizing(tool, user))
			return ITEM_INTERACT_SUCCESS
	// Shearing at stage 3 - requires snip intent so the player opts in deliberately
	if(istype(tool, /obj/item/rogueweapon/huntingknife/scissors) && istype(user.rogue_active_intent(), /datum/intent/snip) && stage == ROGUE_BUSHSAP_MATURE && !dead)
		to_chat(user, span_notice("I begin trimming [src]..."))
		if(do_after(user, rogue_value("farm_bush_trim_time"), target = src))
			var/num_fibers = rand(1, 2)
			for(var/i in 1 to num_fibers)
				new /obj/item/natural/fibers(user.loc)
			to_chat(user, span_notice("I trim back the overgrowth and collect [num_fibers] [num_fibers == 1 ? "fiber" : "fibers"]."))
			growth_progress = 0 // resets hedge-growth timer
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/rogueweapon/shovel))
		to_chat(user, span_notice("I begin uprooting [src]..."))
		if(do_after(user, rogue_value("farm_sapling_dig_time"), target = src))
			to_chat(user, span_notice("I remove [src]."))
			qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/// A seedling bedded in soil: it drinks and eats from it, and once grown blooms into what it was sown as, the soil giving way to
/// it. Dry or hungry soil sets it back.
/obj/structure/soil_seedling
	parent_type = /obj/structure/rockhill
	name = "seedling"
	desc = "A small seedling bedded in a soil plot."
	density = FALSE
	opacity = FALSE
	max_integrity = 5
	resistance_flags = FLAMMABLE
	icon = 'modular_redtard/rockhill/icons/roguetown/items/produce.dmi'
	icon_state = "seeds"
	layer = OBJ_LAYER
	var/obj/structure/soil/linked_soil
	var/final_type
	var/grow_duration = 5 MINUTES
	var/growth_progress = 0
	var/final_pixel_x_jitter = 0
	var/stage = 1

/obj/structure/soil_seedling/Initialize(mapload)
	. = ..()
	if(rogue_farming_enabled())
		START_PROCESSING(SSobj, src)

/obj/structure/soil_seedling/Destroy()
	if(linked_soil)
		UnregisterSignal(linked_soil, COMSIG_QDELETING)
	linked_soil = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/soil_seedling/proc/on_soil_deleted(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	linked_soil = null

/obj/structure/soil_seedling/proc/configure_seedling(obj/structure/soil/soil, seed_icon, seed_state, new_final_type, new_grow_duration)
	if(linked_soil)
		UnregisterSignal(linked_soil, COMSIG_QDELETING)
	linked_soil = soil
	if(linked_soil)
		RegisterSignal(linked_soil, COMSIG_QDELETING, PROC_REF(on_soil_deleted))
	final_type = new_final_type
	grow_duration = new_grow_duration
	icon = seed_icon
	icon_state = seed_state

/obj/structure/soil_seedling/process(seconds_per_tick)
	if(QDELETED(linked_soil))
		qdel(src)
		return PROCESS_KILL
	var/dt = seconds_per_tick * (1 SECONDS)
	var/use = rogue_value("farm_seedling_use")
	if(rogue_sapling_drink(linked_soil, dt, use, use))
		growth_progress += dt * linked_soil.get_environmental_growth_multiplier()
	else
		growth_progress = max(growth_progress - dt * rogue_value("farm_seedling_wither"), 0)
	if(stage == 1 && growth_progress >= grow_duration / 2)
		stage = 2
		icon = ROGUE_CROPS_ICON
		icon_state = "sunflower0"
	if(growth_progress >= grow_duration)
		bloom()
		return PROCESS_KILL

/obj/structure/soil_seedling/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(!QDELETED(linked_soil) && (linked_soil.try_handle_watering(tool, user) || linked_soil.try_handle_fertilizing(tool, user)))
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/rogueweapon/shovel))
		to_chat(user, span_notice("I begin uprooting [src]..."))
		if(do_after(user, 2 SECONDS, target = src))
			qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/soil_seedling/examine(mob/user)
	// Examine shows the soil plot: it holds all the growth and soil status info.
	if(!QDELETED(linked_soil))
		return linked_soil.examine(user)
	return ..()

/obj/structure/soil_seedling/proc/bloom()
	if(QDELETED(src) || !ispath(final_type))
		return
	var/atom/movable/final_growth = new final_type(get_turf(src))
	if(final_pixel_x_jitter)
		final_growth.pixel_x += rand(-final_pixel_x_jitter, final_pixel_x_jitter)
	if(!QDELETED(linked_soil))
		linked_soil.visible_message(span_info("The [linked_soil] parts as [final_growth] pushes through the earth!"))
		qdel(linked_soil)
	qdel(src)

/obj/structure/soil_seedling/herb
	name = "herb seedling"
	final_pixel_x_jitter = 3
