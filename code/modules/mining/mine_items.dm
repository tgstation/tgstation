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

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	name = "mine cart"
	desc = "A cart for use on rails."
	icon_state = "miningcar"
	base_icon_state = "miningcar"
	drag_slowdown = 2
	open_sound = 'sound/machines/trapdoor/trapdoor_open.ogg'
	close_sound = 'sound/machines/trapdoor/trapdoor_shut.ogg'
	move_resist = MOVE_RESIST_DEFAULT
	set_dir_on_move = TRUE
	can_buckle = TRUE
	/// Whether we're on a set of rails or just on the ground
	var/on_rails = FALSE
	/// How many turfs we are travelling, also functions as speed (more momentum = faster)
	var/momentum = 0

/obj/structure/closet/crate/miningcar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noisy_movement, 'sound/effects/tank_treads.ogg', 50)
	if(locate(/obj/structure/minecart_rail) in loc)
		update_rail_state(TRUE)

/obj/structure/closet/crate/miningcar/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(isnull(newloc))
		return ..()
	if(!on_rails)
		return ..()
	if(locate(/obj/structure/minecart_rail) in newloc)
		return ..()
	momentum = 0
	return FALSE

/obj/structure/closet/crate/miningcar/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!on_rails)
		return
	if(momentum <= 0)
		return

	for(var/mob/living/smacked in loc)
		if(smacked.body_position != LYING_DOWN)
			continue
		if(momentum <= 8)
			momentum = floor(momentum / 2)
			break
		smack(smacked, 3, 1.5)

/obj/structure/closet/crate/miningcar/proc/smack(mob/living/smacked, damage_mod = 2, momentum_mod = 2)
	if(!smacked.apply_damage(damage_mod * momentum, BRUTE, BODY_ZONE_CHEST, wound_bonus = damage_mod * 10, attack_direction = dir))
		return
	smacked.visible_message(
		span_danger("[src] smashes into [smacked]!"),
		span_userdanger("You are smacked by [src]!"),
	)
	playsound(src, 'sound/effects/bang.ogg', 50, vary = TRUE)
	if(smacked.body_position == LYING_DOWN)
		smacked.Paralyze(4 SECONDS)
	else
		smacked.Knockdown(5 SECONDS)
	momentum = floor(momentum / momentum_mod)
	for(var/side_dir in shuffle(GLOB.alldirs))
		if(side_dir == dir || side_dir == REVERSE_DIR(dir))
			continue
		var/turf/open/open_turf = get_step(src, side_dir)
		if(!istype(open_turf))
			continue
		smacked.safe_throw_at(open_turf, 1, 2, gentle = TRUE)

/obj/structure/closet/crate/miningcar/proc/update_rail_state(new_state)
	on_rails = new_state
	if(on_rails)
		drag_slowdown = 0
		move_resist = INFINITY
	else
		drag_slowdown = 2
		move_resist = MOVE_RESIST_DEFAULT

/obj/structure/closet/crate/miningcar/forceMove(atom/destination)
	update_rail_state(FALSE)
	return ..()

/obj/structure/closet/crate/miningcar/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!isliving(usr) || !usr.Adjacent(over) || !usr.Adjacent(src))
		return
	if(on_rails)
		if(isopenturf(over))
			try_take_off_rails(usr, over)
		return

	if(istype(over, /obj/structure/minecart_rail) || (isopenturf(over) && (locate(/obj/structure/minecart_rail) in over)))
		try_put_on_rails(usr, get_turf(over))
		return

/obj/structure/closet/crate/miningcar/proc/try_take_off_rails(mob/living/user, turf/open/new_destination)
	balloon_alert(user, "removing from rails...")
	if(!do_after(user, 2 SECONDS, src))
		return
	update_rail_state(FALSE)
	forceMove(new_destination)
	var/sound/thud_sound = sound('sound/weapons/thudswoosh.ogg')
	thud_sound.pitch = 0.5
	playsound(src, thud_sound, 50, TRUE)

/obj/structure/closet/crate/miningcar/proc/try_put_on_rails(mob/living/user, turf/open/new_destination)
	balloon_alert(user, "putting on rails...")
	if(!do_after(user, 2 SECONDS, src))
		return
	if(!(locate(/obj/structure/minecart_rail) in new_destination))
		return
	forceMove(new_destination)
	update_rail_state(TRUE)
	var/sound/click_sound = sound('sound/machines/click.ogg')
	click_sound.pitch = 0.5
	playsound(src, click_sound, 50, TRUE)

/obj/structure/closet/crate/miningcar/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return

	if(!isliving(bumped_atom) || momentum <= 0)
		return
	if(momentum <= 8)
		momentum = floor(momentum / 2)
		break
	smack(bumped_atom)

/obj/structure/closet/crate/miningcar/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!on_rails || momentum > 0)
		return
	var/movedir = bumped_atom.dir
	var/turf/next_turf = get_step(src, movedir)
	if(isnull(next_turf) || !(locate(/obj/structure/minecart_rail) in next_turf))
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
		if(QDELETED(rail) || !on_rails)
			return
		momentum += 20

	else if(isitem(bumped_atom))
		var/obj/item/bumped_item = bumped_atom
		if(bumped_item.w_class <= WEIGHT_CLASS_SMALL)
			return
		momentum += bumped_item.w_class

	setDir(movedir)
	var/datum/move_loop/loop = GLOB.move_manager.move(src, dir, delay = calculate_delay(), subsystem = SSconveyors, flags = MOVEMENT_LOOP_START_FAST|MOVEMENT_LOOP_IGNORE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(check_rail))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(decay_momentum))

/obj/structure/closet/crate/miningcar/proc/check_rail(datum/move_loop/move/source)
	SIGNAL_HANDLER

	if(anchored || !has_gravity())
		return MOVELOOP_SKIP_STEP

	var/turf/next_turf = get_step(src, dir)
	if(locate(/obj/structure/minecart_rail) in next_turf)
		return NONE

	var/list/valid_turfs = get_adjacent_open_turfs(src)
	valid_turfs -= next_turf
	valid_turfs -= get_step(src, REVERSE_DIR(dir))

	for(var/turf/open/corner_turf as anything in shuffle(valid_turfs))
		if(!(locate(/obj/structure/minecart_rail) in corner_turf))
			continue
		momentum -= 1 // Extra cost for turning
		if(momentum <= 0)
			break
		source.direction = get_dir(src, corner_turf)
		return NONE

	GLOB.move_manager.stop_looping(src, SSconveyors)
	if(momentum >= 10)
		visible_message(span_warning("[src] comes to a halt!"))
	else
		visible_message(span_notice("[src] comes to a slow stop."))
	momentum = 0
	return MOVELOOP_SKIP_STEP

/obj/structure/closet/crate/miningcar/proc/decay_momentum(datum/move_loop/move/source)
	SIGNAL_HANDLER
	momentum -= 1
	if(momentum <= 0)
		GLOB.move_manager.stop_looping(src, SSconveyors)
		visible_message(span_notice("[src] comes to a slow stop."))
		return

	var/datum/move_loop/loop = GLOB.move_manager.processing_on(src, SSconveyors)
	loop?.set_delay(calculate_delay())

/obj/structure/closet/crate/miningcar/proc/calculate_delay()
	return (-0.05 SECONDS * momentum) + 1.1 SECONDS

/obj/structure/minecart_rail
	name = "rail"
	desc = "No gold necessary, fortunately."
	icon = 'icons/obj/tram/tram_rails.dmi'
	icon_state = "rail"
	layer = TRAM_RAIL_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE

/obj/structure/minecart_rail/Initialize(mapload)
	. = ..()
	var/static/list/give_turf_traits = list(TRAIT_TURF_IGNORE_SLOWDOWN)
	AddElement(/datum/element/give_turf_traits, give_turf_traits)
	AddElement(/datum/element/footstep_override, footstep = FOOTSTEP_CATWALK)
	for(var/obj/structure/closet/crate/miningcar/cart in loc)
		cart.update_rail_state(TRUE)
