///Kinesis - Gives you the ability to move and launch objects.
/obj/item/mod/module/anomaly_locked/kinesis
	name = "MOD kinesis module"
	desc = "A modular plug-in to the forearm, this module was presumed lost for many years, \
		despite the suits it used to be mounted on still seeing some circulation. \
		This piece of technology allows the user to generate precise anti-gravity fields, \
		letting them move objects as small as a titanium rod to as large as industrial machinery. \
		Oddly enough, it doesn't seem to work on living creatures."
	icon_state = "kinesis"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked/kinesis)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_kinesis"
	overlay_state_active = "module_kinesis_on"
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/grav)
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Range of the knesis grab.
	var/grab_range = 8
	/// Time between us hitting objects with kinesis.
	var/hit_cooldown_time = 1 SECONDS
	/// Stat required for us to grab a mob.
	var/stat_required = DEAD
	/// Atom we grabbed with kinesis.
	var/atom/movable/grabbed_atom
	/// Ref of the beam following the grabbed atom.
	var/datum/beam/kinesis_beam
	/// Overlay we add to each grabbed atom.
	var/mutable_appearance/kinesis_icon
	/// Our mouse movement catcher.
	var/atom/movable/screen/fullscreen/cursor_catcher/kinesis/kinesis_catcher
	/// The sounds playing while we grabbed an object.
	var/datum/looping_sound/gravgen/kinesis/soundloop
	/// The cooldown between us hitting objects with kinesis.
	COOLDOWN_DECLARE(hit_cooldown)

/obj/item/mod/module/anomaly_locked/kinesis/Initialize(mapload)
	. = ..()
	soundloop = new(src)

/obj/item/mod/module/anomaly_locked/kinesis/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/item/mod/module/anomaly_locked/kinesis/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.client)
		return
	if(grabbed_atom)
		var/launched_object = grabbed_atom
		clear_grab(playsound = FALSE)
		launch(launched_object)
		return
	if(!range_check(target))
		balloon_alert(mod.wearer, "too far!")
		return
	if(!can_grab(target))
		balloon_alert(mod.wearer, "can't grab!")
		return
	drain_power(use_energy_cost)
	grab_atom(target)

/obj/item/mod/module/anomaly_locked/kinesis/on_deactivation(display_message = TRUE, deleting = FALSE)
	clear_grab(playsound = !deleting)

/obj/item/mod/module/anomaly_locked/kinesis/process(seconds_per_tick)
	if(!mod.wearer.client || INCAPACITATED_IGNORING(mod.wearer, INCAPABLE_GRAB))
		clear_grab()
		return
	if(!range_check(grabbed_atom))
		balloon_alert(mod.wearer, "out of range!")
		clear_grab()
		return
	drain_power(use_energy_cost/10)
	if(kinesis_catcher.mouse_params)
		kinesis_catcher.calculate_params()
	if(!kinesis_catcher.given_turf)
		return
	mod.wearer.setDir(get_dir(mod.wearer, grabbed_atom))
	if(grabbed_atom.loc == kinesis_catcher.given_turf)
		if(grabbed_atom.pixel_x == kinesis_catcher.given_x - ICON_SIZE_X/2 && grabbed_atom.pixel_y == kinesis_catcher.given_y - ICON_SIZE_Y/2)
			return //spare us redrawing if we are standing still
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - ICON_SIZE_X/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - ICON_SIZE_Y/2)
		kinesis_beam.redrawing()
		return
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - ICON_SIZE_X/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - ICON_SIZE_Y/2)
	kinesis_beam.redrawing()
	var/turf/next_turf = get_step_towards(grabbed_atom, kinesis_catcher.given_turf)
	if(grabbed_atom.Move(next_turf, get_dir(grabbed_atom, next_turf), 8))
		if(isitem(grabbed_atom) && (mod.wearer in next_turf))
			var/obj/item/grabbed_item = grabbed_atom
			clear_grab()
			grabbed_item.pickup(mod.wearer)
			mod.wearer.put_in_hands(grabbed_item)
		return
	var/pixel_x_change = 0
	var/pixel_y_change = 0
	var/direction = get_dir(grabbed_atom, next_turf)
	if(direction & NORTH)
		pixel_y_change = ICON_SIZE_Y/2
	else if(direction & SOUTH)
		pixel_y_change = -ICON_SIZE_Y/2
	if(direction & EAST)
		pixel_x_change = ICON_SIZE_X/2
	else if(direction & WEST)
		pixel_x_change = -ICON_SIZE_X/2
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + pixel_x_change, pixel_y = grabbed_atom.base_pixel_y + pixel_y_change)
	kinesis_beam.redrawing()
	if(!isitem(grabbed_atom) || !COOLDOWN_FINISHED(src, hit_cooldown))
		return
	var/atom/hitting_atom
	if(next_turf.density)
		hitting_atom = next_turf
	for(var/atom/movable/movable_content as anything in next_turf.contents)
		if(ismob(movable_content))
			continue
		if(movable_content.density)
			hitting_atom = movable_content
			break
	var/obj/item/grabbed_item = grabbed_atom
	grabbed_item.melee_attack_chain(mod.wearer, hitting_atom)
	COOLDOWN_START(src, hit_cooldown, hit_cooldown_time)

/obj/item/mod/module/anomaly_locked/kinesis/proc/can_grab(atom/target)
	if(mod.wearer == target)
		return FALSE
	if(!ismovable(target))
		return FALSE
	if(iseffect(target))
		return FALSE
	var/atom/movable/movable_target = target
	if(movable_target.anchored)
		return FALSE
	if(movable_target.throwing)
		return FALSE
	if(movable_target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return FALSE
	if(ismob(movable_target))
		if(!isliving(movable_target))
			return FALSE
		var/mob/living/living_target = movable_target
		if(living_target.buckled)
			return FALSE
		if(living_target.stat < stat_required)
			return FALSE
	else if(isitem(movable_target))
		var/obj/item/item_target = movable_target
		if(item_target.w_class >= WEIGHT_CLASS_GIGANTIC)
			return FALSE
		if(item_target.item_flags & ABSTRACT)
			return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/proc/grab_atom(atom/movable/target)
	grabbed_atom = target
	if(isliving(grabbed_atom))
		grabbed_atom.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), REF(src))
		RegisterSignal(grabbed_atom, COMSIG_MOB_STATCHANGE, PROC_REF(on_statchange))
	ADD_TRAIT(grabbed_atom, TRAIT_NO_FLOATING_ANIM, REF(src))
	RegisterSignal(grabbed_atom, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_setanchored))
	playsound(grabbed_atom, 'sound/items/weapons/contractor_baton/contractorbatonhit.ogg', 75, TRUE)
	kinesis_icon = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "kinesis", layer = grabbed_atom.layer - 0.1, appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM|KEEP_APART)
	kinesis_icon.overlays += emissive_appearance(icon = 'icons/effects/effects.dmi', icon_state = "kinesis", offset_spokesman = grabbed_atom)
	grabbed_atom.add_overlay(kinesis_icon)
	kinesis_beam = mod.wearer.Beam(grabbed_atom, "kinesis")
	kinesis_catcher = mod.wearer.overlay_fullscreen("kinesis", /atom/movable/screen/fullscreen/cursor_catcher/kinesis, 0)
	kinesis_catcher.assign_to_mob(mod.wearer)
	RegisterSignal(kinesis_catcher, COMSIG_SCREEN_ELEMENT_CLICK, PROC_REF(on_catcher_click))
	soundloop.start()
	START_PROCESSING(SSfastprocess, src)

/obj/item/mod/module/anomaly_locked/kinesis/proc/clear_grab(playsound = TRUE)
	if(!grabbed_atom)
		return
	. = grabbed_atom
	if(playsound)
		playsound(grabbed_atom, 'sound/effects/empulse.ogg', 75, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(grabbed_atom, list(COMSIG_MOB_STATCHANGE, COMSIG_MOVABLE_SET_ANCHORED))
	kinesis_catcher = null
	mod.wearer.clear_fullscreen("kinesis")
	grabbed_atom.cut_overlay(kinesis_icon)
	QDEL_NULL(kinesis_beam)
	if(isliving(grabbed_atom))
		grabbed_atom.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), REF(src))
	REMOVE_TRAIT(grabbed_atom, TRAIT_NO_FLOATING_ANIM, REF(src))
	if(!isitem(grabbed_atom))
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x, pixel_y = grabbed_atom.base_pixel_y)
	grabbed_atom = null
	soundloop.stop()

/obj/item/mod/module/anomaly_locked/kinesis/proc/range_check(atom/target)
	if(!isturf(mod.wearer.loc))
		return FALSE
	if(ismovable(target) && !isturf(target.loc))
		return FALSE
	if(!can_see(mod.wearer, target, grab_range))
		return FALSE
	return TRUE


/obj/item/mod/module/anomaly_locked/kinesis/proc/on_catcher_click(atom/source, location, control, params, user)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/proc/on_statchange(mob/grabbed_mob, new_stat)
	SIGNAL_HANDLER

	if(new_stat < stat_required)
		clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/proc/on_setanchored(atom/movable/grabbed_atom, anchorvalue)
	SIGNAL_HANDLER

	if(grabbed_atom.anchored)
		clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/proc/launch(atom/movable/launched_object)
	playsound(launched_object, 'sound/effects/magic/repulse.ogg', 100, TRUE)
	RegisterSignal(launched_object, COMSIG_MOVABLE_IMPACT, PROC_REF(launch_impact))
	var/turf/target_turf = get_turf_in_angle(get_angle(mod.wearer, launched_object), get_turf(src), 10)
	launched_object.throw_at(target_turf, range = grab_range, speed = launched_object.density ? 3 : 4, thrower = mod.wearer, spin = isitem(launched_object))

/obj/item/mod/module/anomaly_locked/kinesis/proc/launch_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/thrownthing)
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!(isstructure(source) || ismachinery(source) || isvehicle(source)))
		return
	var/damage_self = TRUE
	var/damage = 8
	if(source.density)
		damage_self = FALSE
		damage = 15
	if(isliving(hit_atom))
		var/mob/living/living_atom = hit_atom
		living_atom.apply_damage(damage, BRUTE)
	else if(hit_atom.uses_integrity)
		hit_atom.take_damage(damage, BRUTE, MELEE)
	if(damage_self && source.uses_integrity)
		source.take_damage(source.max_integrity/5, BRUTE, MELEE)

/atom/movable/screen/fullscreen/cursor_catcher/kinesis
	icon_state = "kinesis"

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/locked
	core_removable = FALSE

/obj/item/mod/module/anomaly_locked/kinesis/prototype
	name = "MOD prototype kinesis module"
	prebuilt = TRUE
	complexity = 0
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	removable = FALSE
	core_removable = FALSE

/obj/item/mod/module/anomaly_locked/kinesis/plus
	name = "MOD kinesis+ module"
	desc = "A modular plug-in to the forearm, this module was recently redeveloped in secret. \
		The bane of all ne'er-do-wells, the kinesis+ module is a powerful tool that allows the user \
		to manipulate the world around them. Like its older counterpart, it's capable of manipulating \
		structures, machinery, vehicles, and, thanks to the fruitful efforts of its creators - living beings."
	complexity = 0
	prebuilt = TRUE
	stat_required = CONSCIOUS

/// Admin suit version of kinesis. Can grab anything at any range, may enable phasing through walls.
/obj/item/mod/module/anomaly_locked/kinesis/admin
	name = "MOD kinesis++ module"
	desc = "A modular plug-in to the forearm, this module was recently reredeveloped in super secret. \
		This one can force some of the grasped objects to phase through walls. Oh no."
	complexity = 0
	grab_range = INFINITY
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0
	prebuilt = TRUE
	stat_required = CONSCIOUS
	/// Does our object phase through stuff?
	var/phasing = FALSE

/obj/item/mod/module/anomaly_locked/kinesis/admin/grab_atom(atom/movable/target)
	. = ..()
	if(phasing)
		ADD_TRAIT(grabbed_atom, TRAIT_MOVE_PHASING, REF(src))

/obj/item/mod/module/anomaly_locked/kinesis/admin/clear_grab(playsound)
	. = ..()
	if(!.)
		return
	var/atom/movable/previous_grab = .
	if(phasing)
		REMOVE_TRAIT(previous_grab, TRAIT_MOVE_PHASING, REF(src))

/obj/item/mod/module/anomaly_locked/kinesis/admin/can_grab(atom/target)
	if(mod.wearer == target)
		return FALSE
	if(!ismovable(target))
		return FALSE
	var/atom/movable/movable_target = target
	if(movable_target.throwing)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/admin/range_check(atom/target)
	if(!isturf(mod.wearer.loc))
		return FALSE
	if(ismovable(target) && !isturf(target.loc))
		return FALSE
	if(target.z != mod.wearer.z)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/admin/on_setanchored(atom/movable/grabbed_atom, anchorvalue)
	return //thog dont care

/obj/item/mod/module/anomaly_locked/kinesis/admin/get_configuration()
	. = ..()
	.["phasing"] = add_ui_configuration("Phasing", "bool", phasing)

/obj/item/mod/module/anomaly_locked/kinesis/admin/configure_edit(key, value)
	switch(key)
		if("phasing")
			phasing = value
			if(!grabbed_atom)
				return
			if(phasing)
				ADD_TRAIT(grabbed_atom, TRAIT_MOVE_PHASING, REF(src))
			else
				REMOVE_TRAIT(grabbed_atom, TRAIT_MOVE_PHASING, REF(src))
