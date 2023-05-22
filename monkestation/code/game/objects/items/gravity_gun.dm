///Kinesis - Gives you the ability to move and launch objects.
/obj/item/gravity_gun
	name = "Gravity Gun"
	desc = "A gravity gun, can suck in objects and launch them."
	icon_state = "gravity_gun"
	icon = 'monkestation/icons/obj/gravity_gun.dmi'
	/// Range of the knesis grab.
	var/grab_range = 5
	/// Time between us hitting objects with kinesis.
	var/hit_cooldown_time = 1 SECONDS
	/// How long we stun a mob for.
	var/mob_stun_time = 5 SECONDS
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
	var/mob/living/picked_owner

/obj/item/gravity_gun/Initialize(mapload)
	. = ..()
	soundloop = new(src)

/obj/item/gravity_gun/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/item/gravity_gun/pickup(mob/user)
	. = ..()
	picked_owner = user
	RegisterSignal(picked_owner, COMSIG_MOB_MIDDLECLICKON, TYPE_PROC_REF(/obj/item/gravity_gun, on_select_use))

/obj/item/gravity_gun/dropped(mob/user, silent)
	. = ..()
	if(grabbed_atom)
		clear_grab()
	picked_owner = null

/obj/item/gravity_gun/proc/on_select_use(mob/source, atom/target)
	SIGNAL_HANDLER

	if(!picked_owner.client)
		return
	if(grabbed_atom)
		launch()
		clear_grab(playsound = FALSE)
		return
	if(!range_check(target))
		balloon_alert(picked_owner, "too far!")
		return
	if(!can_grab(target))
		balloon_alert(picked_owner, "can't grab!")
		return

	grabbed_atom = target
	if(isliving(grabbed_atom))
		var/mob/living/grabbed_mob = grabbed_atom
		grabbed_mob.Stun(mob_stun_time)
	playsound(grabbed_atom, 'sound/effects/contractorbatonhit.ogg', 75, TRUE)
	kinesis_icon = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "kinesis", layer = grabbed_atom.layer - 0.1)
	kinesis_icon.appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM
	kinesis_icon.overlays += emissive_appearance(icon = 'icons/effects/effects.dmi', icon_state = "kinesis", offset_spokesman = grabbed_atom)
	grabbed_atom.add_overlay(kinesis_icon)
	kinesis_beam = picked_owner.Beam(grabbed_atom, "kinesis")
	kinesis_catcher = picked_owner.overlay_fullscreen("kinesis", /atom/movable/screen/fullscreen/cursor_catcher/kinesis, 0)
	kinesis_catcher.assign_to_mob(picked_owner)
	soundloop.start()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gravity_gun/process(seconds_per_tick)
	if(!picked_owner.client || picked_owner.incapacitated(IGNORE_GRAB))
		clear_grab()
		return
	if(!range_check(grabbed_atom))
		balloon_alert(picked_owner, "out of range!")
		clear_grab()
		return
	if(kinesis_catcher.mouse_params)
		kinesis_catcher.calculate_params()
	if(!kinesis_catcher.given_turf)
		return
	picked_owner.setDir(get_dir(picked_owner, grabbed_atom))
	if(grabbed_atom.loc == kinesis_catcher.given_turf)
		if(grabbed_atom.pixel_x == kinesis_catcher.given_x - world.icon_size/2 && grabbed_atom.pixel_y == kinesis_catcher.given_y - world.icon_size/2)
			return //spare us redrawing if we are standing still
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - world.icon_size/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - world.icon_size/2)
		kinesis_beam.redrawing()
		return
	animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x + kinesis_catcher.given_x - world.icon_size/2, pixel_y = grabbed_atom.base_pixel_y + kinesis_catcher.given_y - world.icon_size/2)
	kinesis_beam.redrawing()
	var/turf/next_turf = get_step_towards(grabbed_atom, kinesis_catcher.given_turf)
	if(grabbed_atom.Move(next_turf, get_dir(grabbed_atom, next_turf), 8))
		if(isitem(grabbed_atom) && (picked_owner in next_turf))
			var/obj/item/grabbed_item = grabbed_atom
			clear_grab()
			grabbed_item.pickup(picked_owner)
			picked_owner.put_in_hands(grabbed_item)
		return
	var/pixel_x_change = 0
	var/pixel_y_change = 0
	var/direction = get_dir(grabbed_atom, next_turf)
	if(direction & NORTH)
		pixel_y_change = world.icon_size/2
	else if(direction & SOUTH)
		pixel_y_change = -world.icon_size/2
	if(direction & EAST)
		pixel_x_change = world.icon_size/2
	else if(direction & WEST)
		pixel_x_change = -world.icon_size/2
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
	grabbed_item.melee_attack_chain(picked_owner, hitting_atom)
	COOLDOWN_START(src, hit_cooldown, hit_cooldown_time)

/obj/item/gravity_gun/proc/can_grab(atom/target)
	if(picked_owner == target)
		return FALSE
	if(iseffect(target))
		return FALSE
	return TRUE

/obj/item/gravity_gun/proc/clear_grab(playsound = TRUE)
	if(!grabbed_atom)
		return
	if(playsound)
		playsound(grabbed_atom, 'sound/effects/empulse.ogg', 75, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	kinesis_catcher = null
	picked_owner.clear_fullscreen("kinesis")
	grabbed_atom.cut_overlay(kinesis_icon)
	QDEL_NULL(kinesis_beam)
	if(!isitem(grabbed_atom))
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = grabbed_atom.base_pixel_x, pixel_y = grabbed_atom.base_pixel_y)
	grabbed_atom = null
	soundloop.stop()

/obj/item/gravity_gun/proc/range_check(atom/target)
	if(!isturf(picked_owner.loc))
		return FALSE
	if(ismovable(target) && !isturf(target.loc))
		return FALSE
	if(!can_see(picked_owner, target, grab_range))
		return FALSE
	return TRUE

/obj/item/gravity_gun/proc/launch()
	playsound(grabbed_atom, 'sound/magic/repulse.ogg', 100, TRUE)
	RegisterSignal(grabbed_atom, COMSIG_MOVABLE_IMPACT, PROC_REF(launch_impact))
	var/turf/target_turf = get_turf_in_angle(get_angle(picked_owner, grabbed_atom), get_turf(src), 10)
	grabbed_atom.throw_at(target_turf, range = grab_range, speed = grabbed_atom.density ? 3 : 4, thrower = picked_owner, spin = isitem(grabbed_atom))

/obj/item/gravity_gun/proc/launch_impact(atom/movable/source, atom/hit_atom, datum/thrownthing/thrownthing)
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
