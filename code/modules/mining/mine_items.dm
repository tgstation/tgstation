/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades. we also use the base effect for certain lighting effects while mapping.
/obj/effect/light_emitter
	name = "light emitter"
	icon_state = "lighting_marker"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/Initialize(mapload)
	. = ..()
	set_light(set_luminosity, set_cap)

/obj/effect/light_emitter/singularity_pull()
	return

/obj/effect/light_emitter/singularity_act()
	return

/obj/effect/light_emitter/podbay
	set_cap = 1

/obj/effect/light_emitter/thunderdome
	set_cap = 1
	set_luminosity = 1.6

/obj/effect/light_emitter/fake_outdoors
	light_color = COLOR_LIGHT_YELLOW
	set_cap = 1

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mining_wardrobe"

/obj/structure/closet/wardrobe/miner/PopulateContents()
	new /obj/item/storage/backpack/duffelbag/explorer(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel/explorer(src)
	new /obj/item/storage/backpack/messenger/explorer(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment locker"
	icon_state = "mining"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/unlocked
	locked = FALSE

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/card/mining_point_card(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/radio/headset/headset_cargo/mining(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/mining_scanner(src)
	new /obj/item/clothing/glasses/meson(src)
	if (HAS_TRAIT(SSstation, STATION_TRAIT_SMALLER_PODS))
		new /obj/item/survivalcapsule/bathroom(src)
	else
		new /obj/item/survivalcapsule(src)
	new /obj/item/assault_pod/mining(src)


/obj/structure/closet/secure_closet/miner/populate_contents_immediate()
	. = ..()

	new /obj/item/gun/energy/recharge/kinetic_accelerator(src)

/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "mining shuttle console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"
	no_destination_swap = TRUE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/machinery/computer/shuttle/mining/attack_hand(mob/user, list/modifiers)
	if(is_station_level(user.z) && user.mind && IS_HEAD_REVOLUTIONARY(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, span_warning("You get a feeling that leaving the station might be a REALLY dumb idea..."))
		dumb_rev_heads += user.mind
		return

	if (HAS_TRAIT(user, TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION) && !is_station_level(user.z))
		to_chat(user, span_warning("You get the feeling you shouldn't mess with this."))
		return

	if(isliving(user))
		var/mob/living/living_user = user
		for(var/obj/item/implant/exile/exile_implant in living_user.implants)
			to_chat(living_user, span_warning("A warning flashes across the screen, and the shuttle controls lock in response to your exile implant."))
			return

	return ..()

/obj/machinery/computer/shuttle/mining/common
	name = "lavaland shuttle console"
	desc = "Used to call and send the lavaland shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle/common
	shuttleId = "mining_common"
	possible_destinations = "commonmining_home;lavaland_common_away;landing_zone_dock;mining_public"

/obj/docking_port/stationary/mining_home
	name = "SS13: Mining Dock"
	shuttle_id = "mining_home"
	roundstart_template = /datum/map_template/shuttle/mining/delta
	width = 7
	dwidth = 3
	height = 5

/obj/docking_port/stationary/mining_home/kilo
	roundstart_template = /datum/map_template/shuttle/mining/kilo
	height = 10

/obj/docking_port/stationary/mining_home/northstar
	roundstart_template = /datum/map_template/shuttle/mining/northstar
	height = 6

/obj/docking_port/stationary/mining_home/common
	name = "SS13: Common Mining Dock"
	shuttle_id = "commonmining_home"
	roundstart_template = /datum/map_template/shuttle/mining_common/meta

/obj/docking_port/stationary/mining_home/common/kilo
	roundstart_template = /datum/map_template/shuttle/mining_common/kilo

/obj/docking_port/stationary/mining_home/common/northstar
	roundstart_template = /datum/map_template/shuttle/mining_common/northstar

/obj/structure/closet/crate/miningcar
	name = "mine cart"
	desc = "A cart for use on rails. Or off rails, if you're so inclined."
	icon_state = "miningcar"
	base_icon_state = "miningcar"
	drag_slowdown = 2
	open_sound = 'sound/machines/trapdoor/trapdoor_open.ogg'
	close_sound = 'sound/machines/trapdoor/trapdoor_shut.ogg'
	set_dir_on_move = TRUE
	can_buckle = TRUE
	can_weld_shut = FALSE

	/// Whether we're on a set of rails or just on the ground
	var/on_rails = FALSE
	/// How many turfs we are travelling, also functions as speed (more momentum = faster)
	var/momentum = 0

/obj/structure/closet/crate/miningcar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement, 'sound/effects/tank_treads.ogg', 50)
	if(locate(/obj/structure/minecart_rail) in loc)
		update_rail_state(TRUE)

/obj/structure/closet/crate/miningcar/examine(mob/user)
	. = ..()
	if(on_rails)
		. += span_notice("You can give this a bump to send it on its way, or drag it off the rails to drag it around.")
	else
		. += span_notice("Drag this onto a mine cart rail to set it on its way.")

/obj/structure/closet/crate/miningcar/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(isnull(newloc))
		return ..()
	if(!on_rails)
		return ..()
	// Allows people to drag minecarts along the rails rather than solely shoving it
	if(can_travel_on_turf(get_turf(newloc), direct))
		return ..()
	momentum = 0
	return FALSE

/obj/structure/closet/crate/miningcar/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!on_rails || momentum <= 0)
		return

	// Handling running OVER people
	for(var/mob/living/smacked in loc)
		if(smacked.body_position != LYING_DOWN)
			continue
		if(momentum <= 8)
			momentum = floor(momentum / 2)
			break
		smack(smacked, 3, 1.5)
		if(QDELETED(src))
			break

/obj/structure/closet/crate/miningcar/is_buckle_possible(mob/living/target, force, check_loc)
	return !opened && ..()

/obj/structure/closet/crate/miningcar/after_open(mob/living/user, force)
	. = ..()
	unbuckle_all_mobs()

// Hack: If a mob is buckled onto the cart, bumping the cart will instead bump the mob (because higher layer)
// So if we want to allow people to shove carts people are riding, we gotta check the mob for bumped and redirect it
/obj/structure/closet/crate/miningcar/post_buckle_mob(mob/living/buckled_mob)
	RegisterSignal(buckled_mob, COMSIG_ATOM_BUMPED, PROC_REF(buckled_bumped))
	RegisterSignal(buckled_mob, COMSIG_MOVABLE_BUMP_PUSHED, PROC_REF(block_bump_push))

/obj/structure/closet/crate/miningcar/post_unbuckle_mob(mob/living/unbuckled_mob)
	UnregisterSignal(unbuckled_mob, list(COMSIG_ATOM_BUMPED, COMSIG_MOVABLE_BUMP_PUSHED))

/obj/structure/closet/crate/miningcar/proc/buckled_bumped(datum/source, atom/bumper)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(shove_off), bumper)

/**
 * Called when the minecart smacks into someone.
 *
 * * smacked - The mob that was smacked.
 * * damage_mod - How much to multiply the momentum by to get the damage.
 * * momentum_mod - How much to divide the momentum by after the smack.
 */
/obj/structure/closet/crate/miningcar/proc/smack(mob/living/smacked, damage_mod = 2, momentum_mod = 2)
	ASSERT(momentum_mod >= 1)
	if(!smacked.apply_damage(damage_mod * momentum, BRUTE, BODY_ZONE_CHEST, wound_bonus = damage_mod * 10, attack_direction = dir))
		return
	if(get_integrity() <= max_integrity * 0.05)
		smacked.visible_message(
			span_danger("[src] smashes into [smacked], breaking into pieces!"),
			span_userdanger("You are smacked by [src] as it breaks into pieces!"),
		)
		playsound(src, 'sound/effects/break_stone.ogg', 50, vary = TRUE)
		momentum = 0

	else
		smacked.visible_message(
			span_danger("[src] smashes into [smacked]!"),
			span_userdanger("You are smacked by [src]!"),
		)
	playsound(src, 'sound/effects/bang.ogg', 50, vary = TRUE)
	take_damage(max_integrity * 0.05)
	momentum = floor(momentum / momentum_mod)
	if(smacked.body_position == LYING_DOWN)
		smacked.Paralyze(4 SECONDS)
		return

	smacked.Knockdown(5 SECONDS)
	for(var/side_dir in shuffle(GLOB.alldirs))
		// Don't throw people in front of the cart, and
		// don't throw people in any direction behind us
		if(side_dir == dir || (side_dir & REVERSE_DIR(dir)))
			continue
		var/turf/open/open_turf = get_step(src, side_dir)
		if(!istype(open_turf))
			continue
		smacked.safe_throw_at(open_turf, 1, 3, spin = FALSE, gentle = TRUE)

/**
 * Updates the state of the minecart to be on or off rails.
 */
/obj/structure/closet/crate/miningcar/proc/update_rail_state(new_state)
	if(on_rails == new_state)
		return
	on_rails = new_state
	if(on_rails)
		drag_slowdown = 0.5
		RegisterSignal(src, COMSIG_MOVABLE_BUMP_PUSHED, PROC_REF(block_bump_push))
	else
		drag_slowdown = 2
		UnregisterSignal(src, COMSIG_MOVABLE_BUMP_PUSHED)

// We want a low move resistance so people can drag it along the tracks
// But we also don't want people to nudge it with a push (since it requires a do_after to set off)
/obj/structure/closet/crate/miningcar/proc/block_bump_push(datum/source, mob/living/bumper, force)
	SIGNAL_HANDLER
	if(on_rails)
		return COMPONENT_NO_PUSH
	if(force < MOVE_FORCE_STRONG)
		return COMPONENT_NO_PUSH
	return NONE

/obj/structure/closet/crate/miningcar/forceMove(atom/destination)
	update_rail_state(FALSE)
	return ..()

/obj/structure/closet/crate/miningcar/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!isliving(user))
		return
	if(on_rails)
		if(isopenturf(over))
			try_take_off_rails(user, over)
		return

	if(istype(over, /obj/structure/minecart_rail) || (isopenturf(over) && (locate(/obj/structure/minecart_rail) in over)))
		try_put_on_rails(user, get_turf(over))
		return

/**
 * Attempt to remove the cart from rails
 *
 * * user - The user attempting to remove the cart from the rails.
 * * new_destination - The turf the cart will be moved to.
 */
/obj/structure/closet/crate/miningcar/proc/try_take_off_rails(mob/living/user, turf/open/new_destination)
	balloon_alert(user, "removing from rails...")
	if(!do_after(user, 2 SECONDS, src))
		return
	update_rail_state(FALSE)
	Move(new_destination)
	var/sound/thud_sound = sound('sound/items/weapons/thudswoosh.ogg')
	thud_sound.pitch = 0.5
	playsound(src, thud_sound, 50, TRUE)

/**
 * Attempt to put the cart on rails
 *
 * * user - The user attempting to put the cart on the rails.
 * * new_destination - The turf the cart will be moved to.
 */
/obj/structure/closet/crate/miningcar/proc/try_put_on_rails(mob/living/user, turf/open/new_destination)
	balloon_alert(user, "putting on rails...")
	if(!do_after(user, 2 SECONDS, src))
		return
	var/obj/structure/minecart_rail/set_rail = locate() in new_destination
	if(isnull(set_rail))
		return
	Move(new_destination)
	setDir(set_rail.dir)
	update_rail_state(TRUE)
	var/sound/click_sound = sound('sound/machines/click.ogg')
	click_sound.pitch = 0.5
	playsound(src, click_sound, 50, TRUE)

/obj/structure/closet/crate/miningcar/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return

	// Handling running INTO people
	if(!isliving(bumped_atom) || momentum <= 0)
		return
	if(momentum <= 8)
		momentum = floor(momentum / 2)
		return
	smack(bumped_atom)

/obj/structure/closet/crate/miningcar/Bumped(atom/movable/bumped_atom)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(shove_off), bumped_atom)

/// Starts the cart moving automatically.
/obj/structure/closet/crate/miningcar/proc/shove_off(atom/movable/bumped_atom)
	if(!on_rails || momentum > 0)
		return

	var/movedir = bumped_atom.dir
	var/turf/next_turf = get_step(src, movedir)
	if(!can_travel_on_turf(next_turf, movedir))
		return

	if(isliving(bumped_atom))
		var/obj/structure/minecart_rail/rail = locate() in loc
		var/mob/living/bumper = bumped_atom
		if(bumper.mob_size <= MOB_SIZE_SMALL)
			return
		if(DOING_INTERACTION_WITH_TARGET(bumper, src))
			return
		balloon_alert(bumper, "setting off...")
		if(!do_after(bumper, 1.5 SECONDS, src))
			return
		if(QDELETED(rail) || !on_rails || !can_travel_on_turf(next_turf, movedir))
			return
		momentum += 20

	else if(isitem(bumped_atom))
		var/obj/item/bumped_item = bumped_atom
		if(bumped_item.w_class <= WEIGHT_CLASS_SMALL)
			return
		momentum += bumped_item.w_class

	else if(istype(bumped_atom, /obj/structure/closet/crate/miningcar))
		var/obj/structure/closet/crate/miningcar/bumped_car = bumped_atom
		if(bumped_car.momentum <= 0)
			return
		momentum += bumped_car.momentum
		bumped_car.momentum = 0

	if(momentum <= 0)
		return

	setDir(movedir)
	var/datum/move_loop/loop = GLOB.move_manager.move(src, dir, delay = calculate_delay(), subsystem = SSconveyors, flags = MOVEMENT_LOOP_START_FAST|MOVEMENT_LOOP_IGNORE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(check_rail))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(decay_momentum))

/obj/structure/closet/crate/miningcar/proc/check_rail(datum/move_loop/move/source)
	SIGNAL_HANDLER

	if(momentum <= 0)
		stack_trace("Mine cart moving on 0 momentum!")
		GLOB.move_manager.stop_looping(src, SSconveyors)
		return MOVELOOP_SKIP_STEP
	// Forced to not move
	if(anchored || !has_gravity())
		return MOVELOOP_SKIP_STEP
	// Going straight
	if(can_travel_on_turf(get_step(src, dir)))
		return NONE
	// Trying to turn
	for(var/next_dir in shuffle(list(turn(dir, 90), turn(dir, -90))))
		if(!can_travel_on_turf(get_step(src, next_dir), dir|next_dir))
			continue
		momentum -= 1 // Extra cost for turning
		if(momentum <= 0)
			break
		source.direction = next_dir
		return NONE
	// Can't go straight and cant turn = STOP
	GLOB.move_manager.stop_looping(src, SSconveyors)
	if(momentum >= 8)
		visible_message(span_warning("[src] comes to a halt!"))
		throw_contents()
	else
		visible_message(span_notice("[src] comes to a slow stop."))
	momentum = 0
	return MOVELOOP_SKIP_STEP

/obj/structure/closet/crate/miningcar/proc/decay_momentum(datum/move_loop/move/source)
	SIGNAL_HANDLER

	if(momentum > 0)
		var/obj/structure/minecart_rail/railbreak/stop_break = locate() in loc
		var/obj/structure/cable/cable = locate() in loc
		// There is a break and it is powered, so STOP
		if(stop_break && cable?.avail(10 KILO JOULES))
			if(momentum >= 8)
				visible_message(span_notice("[src] comes to a sudden stop."))
			else
				visible_message(span_notice("[src] comes to a stop."))
			momentum = 0
			GLOB.move_manager.stop_looping(src, SSconveyors)
			cable.add_delayedload(10 KILO JOULES)
			return
		// This is a powered rail, so maintain speed
		if(cable?.avail(1 KILO JOULES))
			// Speeds up the cart to 5 or 10, then stops decay
			if(momentum <= 5)
				momentum = 5
				cable.add_delayedload(0.5 KILO JOULES)
			else if(momentum <= 10)
				momentum = 10
				cable.add_delayedload(1 KILO JOULES)
			return
		// Here is where actual slowdown happens
		momentum -= 1

	// No more momentum = STOP
	if(momentum <= 0)
		GLOB.move_manager.stop_looping(src, SSconveyors)
		visible_message(span_notice("[src] comes to a slow stop."))
		return

	// Handles slowing down the move loop / cart
	var/datum/move_loop/loop = GLOB.move_manager.processing_on(src, SSconveyors)
	loop?.set_delay(calculate_delay())

/// Calculates how fast the cart is going
/obj/structure/closet/crate/miningcar/proc/calculate_delay()
	return (-0.05 SECONDS * momentum) + 1.1 SECONDS

/// Checks if we can travel on the passed turf
/obj/structure/closet/crate/miningcar/proc/can_travel_on_turf(turf/next_turf, dir_to_check = dir)
	for(var/obj/structure/minecart_rail/rail in next_turf)
		if(rail.dir & (dir_to_check|REVERSE_DIR(dir_to_check)))
			return TRUE

	return FALSE

/// Throws all the contents of the cart out ahead
/obj/structure/closet/crate/miningcar/proc/throw_contents()
	var/was_open = opened
	var/list/to_yeet = contents.Copy()
	var/yeet_rider = has_buckled_mobs()
	if(yeet_rider)
		to_yeet += buckled_mobs
		unbuckle_all_mobs()

	bust_open()
	if(!opened)
		return

	if(!length(to_yeet))
		if(!was_open)
			visible_message(span_warning("[src] breaks open!"))
		return

	var/throw_distance = clamp(ceil(momentum / 3) - 4, 1, 5)
	var/turf/some_distant_turf = get_edge_target_turf(src, dir)
	for(var/atom/movable/yeeten in to_yeet)
		yeeten.throw_at(some_distant_turf, throw_distance, 3, quickstart = TRUE)

	if(was_open)
		visible_message(span_warning("[src] spills its contents!"))
	else
		// Update this message if someone allows multiple people to ride one minecart
		visible_message(span_warning("[src] breaks open, spilling its contents[yeet_rider ? " and throwing its rider":""]!"))

/obj/structure/minecart_rail
	name = "cart rail"
	desc = "Carries carts along the track."
	icon = 'icons/obj/track.dmi'
	icon_state = "track"
	layer = TRAM_RAIL_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	move_resist = INFINITY

/obj/structure/minecart_rail/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_TURF_IGNORE_SLOWDOWN)))
	AddElement(/datum/element/footstep_override, footstep = FOOTSTEP_CATWALK)
	for(var/obj/structure/closet/crate/miningcar/cart in loc)
		cart.update_rail_state(TRUE)

/obj/structure/minecart_rail/examine(mob/user)
	. = ..()
	. += rail_examine()

/obj/structure/minecart_rail/proc/rail_examine()
	return span_notice("Run a powered cable underneath it to power carts as they travel, maintaining their speed.")

/obj/structure/minecart_rail/railbreak
	name = "cart rail brake"
	desc = "Stops carts in their tracks. On the tracks. You get what I mean."
	icon_state = "track_break"
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = NO_BUCKLE_LYING

/obj/structure/minecart_rail/railbreak/rail_examine()
	return span_notice("Run a powered cable underneath it to stop carts that pass over it.")
