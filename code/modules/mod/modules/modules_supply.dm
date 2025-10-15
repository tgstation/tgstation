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
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE

/obj/item/mod/module/gps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps/item, "MOD0", state = GLOB.deep_inventory_state, overlay_state = FALSE)

/obj/item/mod/module/gps/on_use(mob/activator)
	attack_self(mod.wearer) // todo: refactor to make compatable with pAIs.  Maybe ui_interact(activator)

///Hydraulic Clamp - Lets you pick up and drop crates.
/obj/item/mod/module/clamp
	name = "MOD hydraulic clamp module"
	desc = "A series of actuators installed into both arms of the suit, boasting a lifting capacity of almost a ton. \
		However, this design has been locked by Nanotrasen to be primarily utilized for lifting various crates. \
		A lot of people would say that loading cargo is a dull job, but you could not disagree more."
	icon_state = "clamp"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/clamp)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_clamp"
	overlay_state_active = "module_clamp_on"
	required_slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_BACK)
	/// Time it takes to load a crate.
	var/load_time = 3 SECONDS
	/// The max amount of crates you can carry.
	var/max_crates = 3
	/// Disallow mobs larger than this size in containers
	var/max_mob_size = MOB_SIZE_SMALL
	/// Items that allowed to be picked up by this module
	var/list/accepted_items
	/// The crates stored in the module.
	var/list/stored_crates = list()

/obj/item/mod/module/clamp/Initialize(mapload)
	. = ..()
	accepted_items = typecacheof(list(
		/obj/structure/closet/crate,
		/obj/item/delivery/big
	))

/obj/item/mod/module/clamp/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(is_type_in_typecache(target, accepted_items))
		var/atom/movable/picked_crate = target
		if(!check_crate_pickup(picked_crate))
			return
		playsound(src, 'sound/vehicles/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(!check_crate_pickup(picked_crate))
			return
		stored_crates += picked_crate
		picked_crate.forceMove(src)
		balloon_alert(mod.wearer, "picked up crate")
		drain_power(use_energy_cost)
	else if(length(stored_crates))
		var/turf/target_turf = get_turf(target)
		if(target_turf.is_blocked_turf())
			return
		playsound(src, 'sound/vehicles/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(target_turf.is_blocked_turf())
			return
		var/atom/movable/dropped_crate = pop(stored_crates)
		dropped_crate.forceMove(target_turf)
		balloon_alert(mod.wearer, "dropped [dropped_crate]")
		drain_power(use_energy_cost)
	else
		balloon_alert(mod.wearer, "invalid target!")

/obj/item/mod/module/clamp/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	for(var/atom/movable/crate as anything in stored_crates)
		crate.forceMove(drop_location())
		stored_crates -= crate

/obj/item/mod/module/clamp/proc/check_crate_pickup(atom/movable/target)
	if(length(stored_crates) >= max_crates)
		balloon_alert(mod.wearer, "too many crates!")
		return FALSE
	for(var/mob/living/mob in target.get_all_contents())
		if(mob.mob_size <= max_mob_size)
			continue
		balloon_alert(mod.wearer, "crate too heavy!")
		return FALSE
	return TRUE

/obj/item/mod/module/clamp/loader
	name = "MOD loader hydraulic clamp module"
	icon_state = "clamp_loader"
	complexity = 0
	removable = FALSE
	overlay_state_inactive = null
	overlay_state_active = "module_clamp_loader"
	load_time = 1 SECONDS
	max_crates = 5
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)

///Drill - Lets you dig through rock and basalt.
/obj/item/mod/module/drill
	name = "MOD drill module"
	desc = "An arm-mounted drill, typically extending over the user's hand. While useful for drilling through rock, \
		your drill is surely the one that both pierces and creates the heavens. Integrates with mining MODs' sphere \
		transformation module, changing it from a mere traversal tool to high-powered excavation unit."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/drill)
	cooldown_time = 0.2 SECONDS
	overlay_state_active = "module_drill"
	required_slots = list(ITEM_SLOT_GLOVES)
	toolspeed = 0.25
	/// Are we currently in passive sphere mode?
	var/ballin = FALSE
	/// Last tick when we bumpmined. Prevents diagonal bumpnining being thrice as fast as normal
	var/last_bumpmine_tick = -1
	/// Mining skill experience multiplier for bumpmining
	var/exp_multiplier = 1
	/// Cooldown on gibtonite detonation warnings
	COOLDOWN_DECLARE(gibtonite_warning_cd)

/obj/item/mod/module/drill/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_MOD_MODULE_ACTIVATED, PROC_REF(on_module_activated))
	RegisterSignal(mod, COMSIG_MOD_MODULE_DEACTIVATED, PROC_REF(on_module_deactivated))

/obj/item/mod/module/drill/on_uninstall(deleting)
	. = ..()
	UnregisterSignal(mod, list(COMSIG_MOD_MODULE_ACTIVATED, COMSIG_MOD_MODULE_DEACTIVATED))
	toolspeed = initial(toolspeed)
	use_energy_cost = initial(use_energy_cost)
	exp_multiplier = initial(exp_multiplier)
	ballin = FALSE

/obj/item/mod/module/drill/on_activation(mob/activator)
	if (ballin)
		return
	tool_behaviour = TOOL_MINING
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, PROC_REF(bump_mine))

/obj/item/mod/module/drill/on_deactivation(mob/activator, display_message = TRUE, deleting = FALSE)
	if (ballin)
		return
	tool_behaviour = NONE
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!. || !mod.wearer.Adjacent(target))
		return

	if(!ismineralturf(target) || !isasteroidturf(target))
		return

	if(drain_power(use_energy_cost))
		target.attackby(src, mod.wearer)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/bumper, atom/bumped_into, proximity)
	SIGNAL_HANDLER

	if (world.time == last_bumpmine_tick)
		return

	if (!ismineralturf(bumped_into) || !drain_power(use_energy_cost))
		return

	var/turf/closed/mineral/gibtonite/giberal_turf = bumped_into
	if (!istype(giberal_turf) || giberal_turf.stage != GIBTONITE_UNSTRUCK)
		last_bumpmine_tick = world.time
		var/turf/closed/mineral/rock = bumped_into
		INVOKE_ASYNC(rock, TYPE_PROC_REF(/atom, attackby), src, bumper, null, null, exp_multiplier)
		return

	if (!COOLDOWN_FINISHED(src, gibtonite_warning_cd))
		return

	COOLDOWN_START(src, gibtonite_warning_cd, 3 SECONDS)
	playsound(bumper, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(bumper, span_warning("[icon2html(src, bumper)] Unstable gibtonite ore deposit detected!"))

/obj/item/mod/module/drill/proc/on_module_activated(datum/source, obj/item/mod/module/module)
	SIGNAL_HANDLER
	if (!istype(module, /obj/item/mod/module/sphere_transform))
		return
	// In sphere mode we get instamine and halved power drain
	toolspeed = 0
	use_energy_cost *= 0.5
	exp_multiplier *= 0.2
	if (!active)
		on_activation()
	ballin = TRUE

/obj/item/mod/module/drill/proc/on_module_deactivated(datum/source, obj/item/mod/module/module)
	SIGNAL_HANDLER
	if (!istype(module, /obj/item/mod/module/sphere_transform))
		return
	toolspeed = initial(toolspeed)
	use_energy_cost *= 2
	exp_multiplier /= 2
	ballin = FALSE
	if (!active)
		on_deactivation()

/// Ore Bag - Lets you pick up ores and drop them from the suit.
/obj/item/mod/module/orebag
	name = "MOD ore bag module"
	desc = "An integrated ore storage system installed into the suit, \
		this utilizes precise electromagnets and storage compartments to automatically collect and deposit ore. \
		It's recommended by Nakamura Engineering to actually deposit that ore at local refineries."
	icon_state = "ore"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	required_slots = list(ITEM_SLOT_BACK)
	/// Are we currently dropping off ores? Used to prevent the bag from instantly picking up ores after dropping them
	var/dropping_ores = FALSE

/obj/item/mod/module/orebag/on_equip()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_wearer_moved))
	if (mod.wearer.loc)
		RegisterSignal(mod.wearer.loc, COMSIG_ATOM_ENTERED, PROC_REF(on_obj_entered))
		RegisterSignal(mod.wearer.loc, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_initialized_on))

/obj/item/mod/module/orebag/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	if (mod.wearer.loc)
		UnregisterSignal(mod.wearer.loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))

/obj/item/mod/module/orebag/proc/on_wearer_moved(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(old_loc)
		UnregisterSignal(old_loc, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))

	if(mod.wearer.loc)
		RegisterSignal(mod.wearer.loc, COMSIG_ATOM_ENTERED, PROC_REF(on_obj_entered))
		RegisterSignal(mod.wearer.loc, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_initialized_on))

	var/ore_found = FALSE
	for(var/obj/item/stack/ore/ore in get_turf(mod.wearer))
		ore_found = TRUE
		INVOKE_ASYNC(src, PROC_REF(move_ore), ore)

	if (ore_found)
		playsound(mod.wearer, SFX_RUSTLE, 50, TRUE)

/obj/item/mod/module/orebag/proc/move_ore(obj/item/stack/ore)
	for(var/obj/item/stack/ore/stored_ore as anything in src)
		if(!ore.can_merge(stored_ore))
			continue
		ore.merge(stored_ore)
		if(QDELETED(ore))
			return
	ore.forceMove(src)

/obj/item/mod/module/orebag/on_use(mob/activator)
	dropping_ores = TRUE
	for(var/obj/item/ore as anything in src)
		ore.forceMove(mod.drop_location())
	dropping_ores = FALSE
	drain_power(use_energy_cost)

/obj/item/mod/module/orebag/proc/on_obj_entered(atom/new_loc, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	if(istype(arrived, /obj/item/stack/ore) && !dropping_ores)
		INVOKE_ASYNC(src, PROC_REF(move_ore), arrived)
		playsound(mod.wearer, SFX_RUSTLE, 50, TRUE)

/obj/item/mod/module/orebag/proc/on_atom_initialized_on(atom/loc, atom/new_atom)
	SIGNAL_HANDLER
	if(is_type_in_list(new_atom, /obj/item/stack/ore))
		INVOKE_ASYNC(src, PROC_REF(move_ore), new_atom)
		playsound(mod.wearer, SFX_RUSTLE, 50, TRUE)

/obj/item/mod/module/hydraulic
	name = "MOD loader hydraulic arms module"
	desc = "A pair of powerful hydraulic arms installed in a MODsuit."
	icon_state = "launch_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN*10
	incompatible_modules = list(/obj/item/mod/module/hydraulic)
	cooldown_time = 4 SECONDS
	overlay_state_inactive = "module_hydraulic"
	overlay_state_active = "module_hydraulic_active"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)
	/// Time it takes to launch
	var/launch_time = 2 SECONDS
	/// User overlay
	var/mutable_appearance/lightning

/obj/item/mod/module/hydraulic/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/atom/game_renderer = mod.wearer.hud_used.get_plane_master(MUTATE_PLANE(RENDER_PLANE_GAME, mod.wearer))
	var/matrix/render_matrix = matrix(game_renderer.transform)
	render_matrix.Scale(1.25, 1.25)
	animate(game_renderer, launch_time, transform = render_matrix)
	var/current_time = world.time
	mod.wearer.visible_message(span_warning("[mod.wearer] starts whirring!"), \
		blind_message = span_hear("You hear a whirring sound."))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	lightning = mutable_appearance('icons/effects/effects.dmi', "electricity3", layer = LOW_MOB_LAYER)
	mod.wearer.add_overlay(lightning)
	balloon_alert(mod.wearer, "you start charging...")
	var/power = launch_time
	if(!do_after(mod.wearer, launch_time, target = mod))
		power = world.time - current_time
		animate(game_renderer)
	drain_power(use_energy_cost)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	game_renderer.transform = game_renderer.transform.Scale(0.8, 0.8)
	mod.wearer.cut_overlay(lightning)
	var/angle = get_angle(mod.wearer, target)
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	mod.wearer.throw_at(get_ranged_target_turf_direct(mod.wearer, target, power), \
		range = power, speed = max(round(0.2*power), 1), thrower = mod.wearer, spin = FALSE, \
		callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/hydraulic/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)

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

/obj/item/mod/module/disposal_connector/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))

/obj/item/mod/module/disposal_connector/on_part_deactivation(deleting = FALSE)
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
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/magnet)
	cooldown_time = 1.5 SECONDS
	overlay_state_active = "module_magnet"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)

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
		callback = CALLBACK(src, PROC_REF(check_locker), locker))

/obj/item/mod/module/magnet/on_deactivation(mob/activator, display_message = TRUE, deleting = FALSE)
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		mod.wearer.stop_pulling()

/obj/item/mod/module/magnet/proc/check_locker(obj/structure/closet/locker)
	if(!mod?.wearer)
		return
	if(!locker.Adjacent(mod.wearer) || !isturf(locker.loc) || !isturf(mod.wearer.loc))
		return
	mod.wearer.start_pulling(locker)
	ADD_TRAIT(locker, TRAIT_STRONGPULL, REF(mod.wearer))
	RegisterSignal(locker, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(on_stop_pull))

/obj/item/mod/module/magnet/proc/on_stop_pull(obj/structure/closet/locker, atom/movable/last_puller)
	SIGNAL_HANDLER

	REMOVE_TRAIT(locker, TRAIT_STRONGPULL, REF(mod.wearer))
	UnregisterSignal(locker, COMSIG_ATOM_NO_LONGER_PULLED)

/obj/item/mod/module/ash_accretion
	name = "MOD ash accretion module"
	desc = "A module that collects ash from the terrain, covering the suit in a protective layer, this layer is \
		lost when moving across standard terrain."
	icon_state = "ash_accretion"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/ash_accretion)
	overlay_state_inactive = "module_ash"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// How many tiles we can travel to max out the armor.
	var/max_traveled_tiles = 10
	/// How many tiles we traveled through.
	var/traveled_tiles = 0
	/// Armor values per tile.
	var/datum/armor/armor_mod = /datum/armor/mod_ash_accretion
	/// Speed added when you're fully covered in ash.
	var/speed_added = -0.5
	/// Turfs that let us accrete ash.
	var/static/list/accretion_turfs
	/// Turfs that let us keep ash.
	var/static/list/keep_turfs

/datum/armor/mod_ash_accretion
	melee = 3 // 50 armor when fully covered in ash, equal to two plates on an explorer suit
	bullet = 1
	laser = 2
	energy = 2
	bomb = 3

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	if(!accretion_turfs)
		accretion_turfs = typecacheof(list(
			/turf/open/misc/asteroid,
			/turf/open/misc/ashplanet,
			/turf/open/misc/dirt,
		))
	if(!keep_turfs)
		keep_turfs = typecacheof(list(
			/turf/open/misc/grass,
			/turf/open/floor/plating/snowed,
			/turf/open/misc/sandy_dirt,
			/turf/open/misc/ironsand,
			/turf/open/misc/ice,
			/turf/open/indestructible/hierophant,
			/turf/open/indestructible/boss,
			/turf/open/indestructible/necropolis,
			/turf/open/lava,
			/turf/open/water,
		))

/obj/item/mod/module/ash_accretion/on_part_activation()
	mod.wearer.add_traits(list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), REF(src))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/ash_accretion/on_part_deactivation(deleting = FALSE)
	mod.wearer.remove_traits(list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), REF(src))
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)
	if(!traveled_tiles)
		return
	var/datum/armor/to_remove = get_armor_by_type(armor_mod)
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.set_armor(part.get_armor().subtract_other_armor(to_remove.generate_new_with_multipliers(list(ARMOR_ALL = traveled_tiles))))
	if(traveled_tiles == max_traveled_tiles)
		mod.update_speed()
	traveled_tiles = 0

/obj/item/mod/module/ash_accretion/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	return ..()

/obj/item/mod/module/ash_accretion/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (traveled_tiles == max_traveled_tiles)
		module_slowdowns += speed_added

/obj/item/mod/module/ash_accretion/proc/on_move(atom/source, atom/oldloc, dir, forced)
	if(!isturf(mod.wearer.loc)) //dont lose ash from going in a locker
		return

	if(is_type_in_typecache(mod.wearer.loc, accretion_turfs))
		if(traveled_tiles >= max_traveled_tiles)
			return

		traveled_tiles++
		for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
			part.set_armor(part.get_armor().add_other_armor(armor_mod))

		if(traveled_tiles < max_traveled_tiles)
			return

		balloon_alert(mod.wearer, "fully ash covered")
		var/cur_color = mod.wearer.color
		mod.wearer.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3) // Make them super light
		animate(mod.wearer, 1 SECONDS, color = cur_color, flags = ANIMATION_PARALLEL)
		playsound(src, 'sound/effects/sparks/sparks1.ogg', 100, TRUE)
		mod.update_speed()
		return

	if(is_type_in_typecache(mod.wearer.loc, keep_turfs))
		return

	if(traveled_tiles) //leave ash every tile
		new /obj/effect/temp_visual/light_ash(get_turf(src))

	if(traveled_tiles <= 0)
		return

	traveled_tiles--
	if(traveled_tiles == max_traveled_tiles - 1) // Just lost our speed buff
		mod.update_speed()

	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.set_armor(part.get_armor().subtract_other_armor(armor_mod))

	if(traveled_tiles <= 0)
		balloon_alert(mod.wearer, "ran out of ash!")

/obj/item/mod/module/sphere_transform
	name = "MOD sphere transform module"
	desc = "A module able to move the suit's parts around, turning it and the user into a sphere. \
		The sphere can move quickly, even through lava, and launch mining bombs to decimate terrain."
	icon_state = "sphere"
	module_type = MODULE_ACTIVE
	removable = FALSE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/sphere_transform)
	cooldown_time = 1 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Time it takes us to complete the animation.
	var/animate_time = 0.25 SECONDS
	/// Armor values when active
	var/datum/armor/armor_mod = /datum/armor/mod_sphere_transform
	/// List of traits to add/remove from our subject as needed.
	var/list/user_traits = list(
		TRAIT_FORCED_STANDING,
		TRAIT_HANDS_BLOCKED,
		TRAIT_NO_SLIP_ALL,
	)
	/// Has the module been upgraded with bileworm hide plating?
	var/hide_upgrade = FALSE
	/// How much hide is required to reinforce the MOD
	var/hide_amount = 2 // These are rather rare as of now, should be increased later once other methods of crossing lava are removed

/datum/armor/mod_sphere_transform
	melee = 20 // Can get up to 70 armor when ash covered and ballin, which is as good as a HECK suit... but you can't really attack anymore
	bomb = 20

/obj/item/mod/module/sphere_transform/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))

// Isn't supposed to happen outside of deletion but just in case
/obj/item/mod/module/sphere_transform/on_uninstall(deleting)
	. = ..()
	// No need to drop the hide as we're supposed to be inbuilt and unremovable
	UnregisterSignal(mod, COMSIG_ATOM_ITEM_INTERACTION)

/obj/item/mod/module/sphere_transform/proc/on_item_interaction(atom/movable/source, mob/living/user, obj/item/item, modifiers)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/stack/sheet/animalhide/bileworm))
		return NONE

	if (hide_upgrade)
		to_chat(user, span_warning("[mod] is already reinforced with bileworm skin!"))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stack/sheet/animalhide/bileworm/hide = item
	if (!hide.use(hide_amount))
		to_chat(user, span_warning("You need more hide to fully reinforce [mod]!"))
		return ITEM_INTERACT_BLOCKING

	hide_upgrade = TRUE
	overlay_state_inactive = "module_bileworm_bracing"
	user_traits += TRAIT_LAVA_IMMUNE
	mod.balloon_alert(user, "plating reinforced!")
	if (active)
		ADD_TRAIT(mod.wearer, TRAIT_LAVA_IMMUNE, REF(src))
	update_clothing_slots()
	return ITEM_INTERACT_SUCCESS

/obj/item/mod/module/sphere_transform/activate(mob/activator)
	if(!mod.wearer.has_gravity())
		balloon_alert(activator, "no gravity!")
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_activation(mob/activator)
	playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE)
	mod.wearer.add_filter("mod_ball", 1, alpha_mask_filter(icon = icon('icons/mob/clothing/modsuit/mod_modules.dmi', "ball_mask"), flags = MASK_INVERSE))
	mod.wearer.add_filter("mod_blur", 2, angular_blur_filter(size = 15))
	mod.wearer.add_filter("mod_outline", 3, outline_filter(color = "#000000AA"))
	mod.wearer.add_offsets(REF(src), y_add = -4)
	mod.wearer.SpinAnimation(1.5, tag = "sphere_transform")
	mod.wearer.add_traits(user_traits, REF(src))
	mod.wearer.RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	mod.wearer.AddElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, sound_vary = TRUE)
	mod.wearer.add_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/damage_slowdown)
	mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/sphere)
	RegisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE, PROC_REF(on_statchange))
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.set_armor(part.get_armor().add_other_armor(armor_mod))

/obj/item/mod/module/sphere_transform/on_deactivation(mob/activator, display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE, frequency = -1)
	mod.wearer.remove_offsets(REF(src))
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/datum, remove_filter), list("mod_ball", "mod_blur", "mod_outline")), animate_time)
	mod.wearer.remove_traits(user_traits, REF(src))
	mod.wearer.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/damage_slowdown)
	animate(mod.wearer, tag = "sphere_transform")
	mod.wearer.RemoveElement(/datum/element/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, sound_vary = TRUE)
	mod.wearer.AddElement(/datum/element/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/sphere)
	UnregisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE)
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.set_armor(part.get_armor().subtract_other_armor(armor_mod))

/obj/item/mod/module/sphere_transform/used(mob/activator)
	if(!lavaland_equipment_pressure_check(get_turf(src)))
		balloon_alert(activator, "too much pressure!")
		playsound(src, 'sound/items/weapons/gun/general/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/bullet/mining_bomb/bomb = new(mod.wearer.loc)
	bomb.aim_projectile(target, mod.wearer)
	bomb.firer = mod.wearer
	playsound(src, 'sound/items/weapons/gun/general/grenade_launch.ogg', 75, TRUE)
	INVOKE_ASYNC(bomb, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

/obj/item/mod/module/sphere_transform/on_active_process(seconds_per_tick)
	if(!mod.wearer.has_gravity())
		deactivate() //deactivate in no grav

/obj/item/mod/module/sphere_transform/proc/on_statchange(datum/source)
	SIGNAL_HANDLER
	if(mod.wearer.stat)
		deactivate()

/obj/projectile/bullet/mining_bomb
	name = "mining bomb"
	desc = "A bomb. Why are you examining this?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 6
	suppressed = SUPPRESSED_VERY
	armor_flag = BOMB
	light_system = OVERLAY_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_LIGHT_ORANGE
	embed_type = null
	can_hit_turfs = TRUE

/obj/projectile/bullet/mining_bomb/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/projectile_drop, /obj/structure/mining_bomb)
	RegisterSignal(src, COMSIG_PROJECTILE_ON_SPAWN_DROP, PROC_REF(handle_drop))

/obj/projectile/bullet/mining_bomb/proc/handle_drop(datum/source, obj/structure/mining_bomb/mining_bomb)
	SIGNAL_HANDLER
	addtimer(CALLBACK(mining_bomb, TYPE_PROC_REF(/obj/structure/mining_bomb, prime), firer), mining_bomb.prime_time)

/obj/structure/mining_bomb
	name = "mining bomb"
	desc = "A bomb. Why are you examining this?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	light_system = OVERLAY_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_LIGHT_ORANGE
	/// Time to prime the explosion
	var/prime_time = 0.1 SECONDS
	/// Time to explode from the priming
	var/explosion_time = 0.9 SECONDS // Roughly this much until the blast part of the explosion animation
	/// Damage done on explosion.
	var/damage = 7
	/// Damage multiplier on hostile fauna.
	var/fauna_boost = 4

/obj/structure/mining_bomb/proc/prime(atom/movable/firer)
	var/mutable_appearance/explosion_image = mutable_appearance('icons/effects/96x96.dmi', "judicial_explosion", FLOAT_LAYER, src, ABOVE_GAME_PLANE)
	explosion_image.pixel_w = -32
	explosion_image.pixel_z = -32
	var/turf/our_loc = get_turf(src)
	our_loc.flick_overlay_view(explosion_image, 1.35 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(boom), firer), explosion_time)

/obj/structure/mining_bomb/proc/boom(atom/movable/firer)
	visible_message(span_danger("[src] explodes!"))
	playsound(src, 'sound/effects/magic/magic_missile.ogg', 200, vary = TRUE)
	for(var/turf/closed/mineral/rock in circle_range_turfs(src, 1))
		rock.gets_drilled()
	for(var/mob/living/victim in range(1, src))
		if(HAS_TRAIT(victim, TRAIT_MINING_AOE_IMMUNE))
			continue
		victim.apply_damage(damage * (ismining(victim) ? fauna_boost : 1), BRUTE, spread_damage = TRUE)
		to_chat(victim, span_userdanger("You are hit by a mining bomb explosion!"))
		if(!firer)
			continue
		if(ishostile(victim))
			var/mob/living/simple_animal/hostile/hostile_mob = victim
			hostile_mob.GiveTarget(firer)
		else if(isbasicmob(victim))
			victim.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, firer)
	for(var/obj/object in range(1, src))
		object.take_damage(damage, BRUTE, BOMB)
	qdel(src)
