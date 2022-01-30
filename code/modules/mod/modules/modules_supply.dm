//Supply modules for MODsuits

///Internal GPS - Extends a GPS you can use.
/obj/item/mod/module/gps
	name = "MOD internal GPS module"
	desc = "This module uses common Nanotrasen technology to calculate the user's position anywhere in space, \
		down to the exact coordinates. This information is fed to a central database viewable from the device itself, \
		though using it to help people is up to you."
	icon_state = "gps"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/gps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps/item, "MOD0", state = GLOB.deep_inventory_state, overlay = null)

/obj/item/mod/module/gps/on_use()
	. = ..()
	if(!.)
		return
	attack_self(mod.wearer)

///Hydraulic Clamp - Lets you pick up and drop crates.
/obj/item/mod/module/clamp
	name = "MOD hydraulic clamp module"
	desc = "A series of actuators installed into both arms of the suit, boasting a lifting capacity of almost a ton. \
		However, this design has been locked by Nanotrasen to be primarily utilized for lifting various crates. \
		A lot of people would say that loading cargo is a dull job, but you could not disagree more."
	icon_state = "clamp"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/clamp)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_clamp"
	overlay_state_active = "module_clamp_on"
	/// Time it takes to load a crate.
	var/load_time = 3 SECONDS
	/// The max amount of crates you can carry.
	var/max_crates = 3
	/// The crates stored in the module.
	var/list/stored_crates = list()

/obj/item/mod/module/clamp/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /obj/structure/closet/crate))
		var/atom/movable/picked_crate = target
		if(length(stored_crates) >= max_crates)
			balloon_alert(mod.wearer, "too many crates!")
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		stored_crates += picked_crate
		picked_crate.forceMove(src)
		balloon_alert(mod.wearer, "picked up [picked_crate]")
		drain_power(use_power_cost)
	else if(length(stored_crates))
		var/turf/target_turf = get_turf(target)
		if(target_turf.is_blocked_turf())
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(target_turf.is_blocked_turf())
			return
		var/atom/movable/dropped_crate = pop(stored_crates)
		dropped_crate.forceMove(target_turf)
		balloon_alert(mod.wearer, "dropped [dropped_crate]")
		drain_power(use_power_cost)
	else
		balloon_alert(mod.wearer, "invalid target!")

/obj/item/mod/module/clamp/on_suit_deactivation()
	for(var/atom/movable/crate as anything in stored_crates)
		crate.forceMove(drop_location())
		stored_crates -= crate

/obj/item/mod/module/clamp/loader
	name = "MOD loader hydraulic clamp module"
	icon_state = "clamp_loader"
	complexity = 0
	removable = FALSE
	overlay_state_inactive = null
	overlay_state_active = "module_clamp_loader"
	load_time = 1 SECONDS
	max_crates = 5

///Drill - Lets you dig through rock and basalt.
/obj/item/mod/module/drill
	name = "MOD drill module"
	desc = "An integrated drill, typically extending over the user's hand. While useful for drilling through rock, \
		your drill is surely the one that both pierces and creates the heavens."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/drill)
	cooldown_time = 0.5 SECONDS
	overlay_state_active = "module_drill"

/obj/item/mod/module/drill/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, .proc/bump_mine)

/obj/item/mod/module/drill/on_deactivation(display_message = TRUE)
	. = ..()
	if(!.)
		return
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(mod.wearer)
		drain_power(use_power_cost)
	else if(istype(target, /turf/open/floor/plating/asteroid))
		var/turf/open/floor/plating/asteroid/sand_turf = target
		if(!sand_turf.can_dig(mod.wearer))
			return
		sand_turf.getDug()
		drain_power(use_power_cost)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/bumper, atom/bumped_into, proximity)
	SIGNAL_HANDLER
	if(!istype(bumped_into, /turf/closed/mineral) || !drain_power(use_power_cost))
		return
	var/turf/closed/mineral/mineral_turf = bumped_into
	mineral_turf.gets_drilled(mod.wearer)
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Ore Bag - Lets you pick up ores and drop them from the suit.
/obj/item/mod/module/orebag
	name = "MOD ore bag module"
	desc = "An integrated ore storage system installed into the suit, \
		this utilizes precise electromagnets and storage compartments to automatically collect and deposit ore. \
		It's recommended by Nakamura Engineering to actually deposit that ore at local refineries."
	icon_state = "ore"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	/// The ores stored in the bag.
	var/list/ores = list()

/obj/item/mod/module/orebag/on_equip()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/ore_pickup)

/obj/item/mod/module/orebag/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/orebag/proc/ore_pickup(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	for(var/obj/item/stack/ore/ore in get_turf(mod.wearer))
		INVOKE_ASYNC(src, .proc/move_ore, ore)
		playsound(src, "rustle", 50, TRUE)

/obj/item/mod/module/orebag/proc/move_ore(obj/item/stack/ore)
	for(var/obj/item/stack/stored_ore as anything in ores)
		if(!ore.can_merge(stored_ore))
			continue
		ore.merge(stored_ore)
		if(QDELETED(ore))
			return
		break
	ore.forceMove(src)
	ores += ore

/obj/item/mod/module/orebag/on_use()
	. = ..()
	if(!.)
		return
	for(var/obj/item/ore as anything in ores)
		ore.forceMove(drop_location())
		ores -= ore
	drain_power(use_power_cost)

/obj/item/mod/module/hydraulic
	name = "MOD loader hydraulic arms module"
	desc = "A pair of powerful hydraulic arms installed in a MODsuit."
	icon_state = "launch_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN*10
	incompatible_modules = list(/obj/item/mod/module/hydraulic)
	cooldown_time = 4 SECONDS
	overlay_state_inactive = "module_hydraulic"
	overlay_state_active = "module_hydraulic_active"
	/// Time it takes to launch
	var/launch_time = 2 SECONDS
	/// User overlay
	var/mutable_appearance/lightning

/obj/item/mod/module/hydraulic/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/atom/game_renderer = mod.wearer.hud_used.plane_masters["[RENDER_PLANE_GAME]"]
	var/matrix/render_matrix = matrix(game_renderer.transform)
	render_matrix.Scale(1.25, 1.25)
	animate(game_renderer, launch_time, flags = SINE_EASING|EASE_IN, transform = render_matrix)
	var/current_time = world.time
	mod.wearer.visible_message(span_warning("[mod.wearer] starts whirring!"), \
		blind_message = span_hear("You hear a whirring sound."))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	lightning = mutable_appearance('icons/effects/effects.dmi', "electricity3", plane = GAME_PLANE_FOV_HIDDEN)
	mod.wearer.add_overlay(lightning)
	balloon_alert(mod.wearer, "you start charging...")
	var/power = launch_time
	if(!do_after(mod.wearer, launch_time, target = mod))
		power = world.time - current_time
		animate(game_renderer)
	drain_power(use_power_cost)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	game_renderer.transform = game_renderer.transform.Scale(0.8, 0.8)
	mod.wearer.cut_overlay(lightning)
	var/angle = get_angle(mod.wearer, target)
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	mod.wearer.throw_at(get_ranged_target_turf_direct(mod.wearer, target, power), \
		range = power, speed = max(round(0.2*power), 1), thrower = mod.wearer, spin = FALSE, \
		callback = CALLBACK(src, .proc/on_throw_end, target, -angle))

/obj/item/mod/module/hydraulic/proc/on_throw_end(atom/target, angle)
	if(!mod?.wearer)
		return
	mod.wearer.transform = mod.wearer.transform.Turn(angle)

/obj/item/mod/module/disposal_connector
	name = "MOD disposal selector module"
	desc = "A module that connects to the disposal pipeline, causing the user to go into their config selected disposal. \
		Only seems to work when the suit is on."
	icon_state = "disposal"
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/disposal_connector)
	var/disposal_tag = NONE

/obj/item/mod/module/disposal_connector/Initialize(mapload)
	. = ..()
	disposal_tag = pick(GLOB.TAGGERLOCATIONS)

/obj/item/mod/module/disposal_connector/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_DISPOSING, .proc/disposal_handling)

/obj/item/mod/module/disposal_connector/on_suit_deactivation()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_DISPOSING)

/obj/item/mod/module/disposal_connector/get_configuration()
	. = ..()
	.["disposal_tag"] = add_ui_configuration("Disposal Tag", "list", GLOB.TAGGERLOCATIONS[disposal_tag], GLOB.TAGGERLOCATIONS)

/obj/item/mod/module/disposal_connector/configure_edit(key, value)
	switch(key)
		if("disposal_tag")
			for(var/tag in 1 to length(GLOB.TAGGERLOCATIONS))
				if(GLOB.TAGGERLOCATIONS[tag] == value)
					disposal_tag = tag
					break

/obj/item/mod/module/disposal_connector/proc/disposal_handling(datum/disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER

	disposal_holder.destinationTag = disposal_tag

/obj/item/mod/module/magnet
	name = "MOD loader hydraulic magnet module"
	desc = "A powerful hydraulic electromagnet able to launch crates and lockers towards the user, and keep 'em attached."
	icon_state = "magnet_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN*3
	incompatible_modules = list(/obj/item/mod/module/magnet)
	cooldown_time = 1.5 SECONDS
	overlay_state_active = "module_magnet"

/obj/item/mod/module/magnet/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		var/obj/structure/closet/locker = mod.wearer.pulling
		playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
		locker.forceMove(mod.wearer.loc)
		locker.throw_at(target, range = 7, speed = 4, thrower = mod.wearer)
		return
	if(!istype(target, /obj/structure/closet) || !(target in view(mod.wearer)))
		balloon_alert(mod.wearer, "invalid target!")
		return
	var/obj/structure/closet/locker = target
	if(locker.anchored || locker.move_resist >= MOVE_FORCE_OVERPOWERING)
		balloon_alert(mod.wearer, "target anchored!")
		return
	new /obj/effect/temp_visual/mook_dust(get_turf(locker))
	playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
	locker.throw_at(mod.wearer, range = 7, speed = 3, force = MOVE_FORCE_WEAK, \
		callback = CALLBACK(src, .proc/check_locker, locker))

/obj/item/mod/module/magnet/on_deactivation(display_message = TRUE)
	. = ..()
	if(!.)
		return
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		mod.wearer.stop_pulling()

/obj/item/mod/module/magnet/proc/check_locker(obj/structure/closet/locker)
	if(!mod?.wearer)
		return
	if(!locker.Adjacent(mod.wearer) || !isturf(locker.loc) || !isturf(mod.wearer.loc))
		return
	mod.wearer.start_pulling(locker)
	locker.strong_grab = TRUE
	RegisterSignal(locker, COMSIG_ATOM_NO_LONGER_PULLED, .proc/on_stop_pull)

/obj/item/mod/module/magnet/proc/on_stop_pull(obj/structure/closet/locker, atom/movable/last_puller)
	SIGNAL_HANDLER

	locker.strong_grab = FALSE
	UnregisterSignal(locker, COMSIG_ATOM_NO_LONGER_PULLED)

/obj/item/mod/module/ash_accretion
	name = "MOD ash accretion module"
	desc = "A module that collects ash from the terrain, covering the suit in a protective layer, this layer is \
		lost when moving across standard terrain."
	icon_state = "ash_accretion"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/ash_accretion)
	/// How many tiles we can travel to max out the armor.
	var/max_traveled_tiles = 10
	/// How many tiles we traveled through.
	var/traveled_tiles = 0
	/// Armor values per tile.
	var/list/armor_values = list(MELEE = 5, BULLET = 1.5, LASER = 2, ENERGY = 2.5, BOMB = 2.5)
	/// Speed added when you're fully covered in ash.
	var/speed_added = 0.5
	/// Turfs that let us accrete ash.
	var/static/list/accretion_turfs
	/// Turfs that let us keep ash.
	var/static/list/keep_turfs

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	if(!accretion_turfs)
		accretion_turfs = typecacheof(list(
			/turf/open/floor/plating/asteroid,
			/turf/open/floor/plating/ashplanet,
			/turf/open/floor/plating/dirt,
		))
	if(!keep_turfs)
		keep_turfs = typecacheof(list(
			/turf/open/floor/plating/grass,
			/turf/open/floor/plating/snowed,
			/turf/open/floor/plating/sandy_dirt,
			/turf/open/floor/plating/ironsand,
			/turf/open/indestructible/hierophant,
			/turf/open/indestructible/boss,
			/turf/open/indestructible/necropolis,
			/turf/open/lava,
			/turf/open/water,
		))

/obj/item/mod/module/ash_accretion/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ASHSTORM_IMMUNE, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_SNOWSTORM_IMMUNE, MOD_TRAIT)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, .proc/on_move)

/obj/item/mod/module/ash_accretion/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_ASHSTORM_IMMUNE, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_SNOWSTORM_IMMUNE, MOD_TRAIT)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	if(!traveled_tiles)
		return
	var/list/parts = mod.mod_parts + mod
	var/list/removed_armor = armor_values.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type] * traveled_tiles
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.modifyRating(arglist(removed_armor))
	if(traveled_tiles == max_traveled_tiles)
		mod.slowdown += speed_added
		mod.wearer.update_equipment_speed_mods()
	traveled_tiles = 0

/obj/item/mod/module/ash_accretion/proc/on_move(atom/source, atom/oldloc, dir, forced)
	if(!isturf(mod.wearer.loc)) //dont lose ash from going in a locker
		return
	if(traveled_tiles && prob(25)) //leave ash every few tiles
		new /obj/effect/temp_visual/light_ash(get_turf(src))
	if(is_type_in_typecache(mod.wearer.loc, accretion_turfs))
		if(traveled_tiles >= max_traveled_tiles)
			return
		traveled_tiles++
		var/list/parts = mod.mod_parts + mod
		for(var/obj/item/part as anything in parts)
			part.armor = part.armor.modifyRating(arglist(armor_values))
		if(traveled_tiles >= max_traveled_tiles)
			balloon_alert(mod.wearer, "fully ash covered")
			mod.wearer.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3) //make them super light
			animate(mod.wearer, 1 SECONDS, color = null, flags = ANIMATION_PARALLEL)
			playsound(src, 'sound/effects/sparks1.ogg', 100, TRUE)
			mod.slowdown -= speed_added
			mod.wearer.update_equipment_speed_mods()
	else if(is_type_in_typecache(mod.wearer.loc, keep_turfs))
		return
	else
		if(traveled_tiles <= 0)
			return
		if(traveled_tiles == max_traveled_tiles)
			mod.slowdown += speed_added
			mod.wearer.update_equipment_speed_mods()
		traveled_tiles--
		var/list/parts = mod.mod_parts + mod
		var/list/removed_armor = armor_values.Copy()
		for(var/armor_type in removed_armor)
			removed_armor[armor_type] = -removed_armor[armor_type]
		for(var/obj/item/part as anything in parts)
			part.armor = part.armor.modifyRating(arglist(removed_armor))
		if(traveled_tiles <= 0)
			balloon_alert(mod.wearer, "ran out of ash!")

/obj/item/mod/module/sphere_transform
	name = "MOD sphere transform module"
	desc = "A module able to move the suit's parts around, turning it and the user into a sphere. \
		The sphere can move quickly, even through lava, and launch mining bombs to decimate terrain."
	icon_state = "sphere"
	module_type = MODULE_ACTIVE
	removable = FALSE
	active_power_cost = DEFAULT_CHARGE_DRAIN*0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN*3
	incompatible_modules = list(/obj/item/mod/module/sphere_transform)
	cooldown_time = 1.5 SECONDS
	/// Time it takes us to complete the animation.
	var/animate_time = 0.25 SECONDS

/obj/item/mod/module/sphere_transform/on_activation()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/modsuit/ballin.ogg', 100)
	mod.wearer.add_filter("mod_ball", 1, alpha_mask_filter(icon = icon('icons/mob/clothing/mod.dmi', "ball_mask"), flags = MASK_INVERSE))
	mod.wearer.add_filter("mod_blur", 2, angular_blur_filter(size = 15))
	mod.wearer.add_filter("mod_outline", 3, outline_filter(color = "#000000AA"))
	mod.wearer.base_pixel_y -= 4
	animate(mod.wearer, animate_time, pixel_y = mod.wearer.base_pixel_y, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(mod.wearer, /atom.proc/SpinAnimation, 1.5), animate_time)
	ADD_TRAIT(mod.wearer, TRAIT_LAVA_IMMUNE, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_IGNORETURFSLOWDOWN, MOD_TRAIT)
	mod.wearer.RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	mod.wearer.AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6)
	mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/sphere)

/obj/item/mod/module/sphere_transform/on_deactivation(display_message = TRUE)
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/modsuit/ballout.ogg', 100)
	mod.wearer.base_pixel_y = 0
	animate(mod.wearer, animate_time, pixel_y = mod.wearer.base_pixel_y)
	addtimer(CALLBACK(mod.wearer, /atom.proc/remove_filter, list("mod_ball", "mod_blur", "mod_outline")), animate_time)
	REMOVE_TRAIT(mod.wearer, TRAIT_LAVA_IMMUNE, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_IGNORETURFSLOWDOWN, MOD_TRAIT)
	mod.wearer.RemoveElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6)
	mod.wearer.AddElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/sphere)

/obj/item/mod/module/sphere_transform/on_use()
	if(!lavaland_equipment_pressure_check(get_turf(src)))
		balloon_alert(mod.wearer, "too much pressure!")
		playsound(src, 'sound/weapons/gun/general/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/bomb = new /obj/projectile/mining_bomb(mod.wearer.loc)
	bomb.preparePixelProjectile(target, mod.wearer)
	bomb.firer = mod.wearer
	playsound(src, 'sound/weapons/gun/general/grenade_launch.ogg', 75, TRUE)
	INVOKE_ASYNC(bomb, /obj/projectile.proc/fire)
	drain_power(use_power_cost)

/obj/projectile/mining_bomb
