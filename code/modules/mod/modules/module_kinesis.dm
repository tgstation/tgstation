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
	use_power_cost = DEFAULT_CHARGE_DRAIN*3
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked/kinesis)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_kinesis"
	overlay_state_active = "module_kinesis_on"
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/grav)
	var/grab_range = 5
	var/atom/movable/grabbed_atom
	var/datum/beam/kinesis_beam
	var/mutable_appearance/kinesis_icon
	var/atom/movable/screen/fullscreen/kinesis/kinesis_catcher

/obj/item/mod/module/anomaly_locked/kinesis/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(grabbed_atom)
		launch()
		clear_grab(playsound = FALSE)
		return
	if(!range_check(target))
		balloon_alert(mod.wearer, "too far!")
		return
	if(!can_grab(target))
		balloon_alert(mod.wearer, "can't grab!")
		return
	drain_power(use_power_cost)
	grabbed_atom = target
	playsound(grabbed_atom, 'sound/effects/contractorbatonhit.ogg', 75, TRUE)
	START_PROCESSING(SSfastprocess, src)
	kinesis_icon = mutable_appearance(icon='icons/effects/effects.dmi', icon_state="kinesis", layer=grabbed_atom.layer-0.1)
	grabbed_atom.add_overlay(kinesis_icon)
	grabbed_atom.animate_movement = NO_STEPS
	kinesis_beam = mod.wearer.Beam(grabbed_atom, "kinesis")
	kinesis_catcher = mod.wearer.overlay_fullscreen("kinesis", /atom/movable/screen/fullscreen/kinesis, 0)
	kinesis_catcher.kinesis_user = mod.wearer
	kinesis_catcher.RegisterSignal(mod.wearer, COMSIG_MOVABLE_PRE_MOVE, /atom/movable/screen/fullscreen/kinesis.proc/on_move)

/obj/item/mod/module/anomaly_locked/kinesis/on_deactivation()
	. = ..()
	if(!.)
		return
	clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/process(delta_time)
	if(!mod.wearer.client)
		clear_grab()
		return
	if(!range_check(grabbed_atom))
		balloon_alert(mod.wearer, "out of range!")
		clear_grab()
		return
	if(!kinesis_catcher.given_turf)
		return
	drain_power(use_power_cost/10)
	mod.wearer.setDir(get_dir(mod.wearer, grabbed_atom))
	if(grabbed_atom.loc == kinesis_catcher.given_turf)
		animate(grabbed_atom, 0.2 SECONDS, pixel_x = kinesis_catcher.given_x - world.icon_size/2, pixel_y = kinesis_catcher.given_y - world.icon_size/2)
		kinesis_beam.redrawing()
		return
	grabbed_atom.pixel_x = kinesis_catcher.given_x - world.icon_size/2
	grabbed_atom.pixel_y = kinesis_catcher.given_y - world.icon_size/2
	grabbed_atom.Move(get_step_towards(grabbed_atom, kinesis_catcher.given_turf))

/obj/item/mod/module/anomaly_locked/kinesis/proc/can_grab(atom/target)
	if(!ismovable(target))
		return FALSE
	var/atom/movable/movable_target = target
	if(movable_target.anchored)
		return FALSE
	if(movable_target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return FALSE
	if(ismob(movable_target))
		if(!isliving(movable_target))
			return FALSE
		var/mob/living/living_target = movable_target
		if(living_target.stat != DEAD)
			return FALSE
	else if(isitem(movable_target))
		var/obj/item/item_target = movable_target
		if(item_target.w_class >= WEIGHT_CLASS_GIGANTIC)
			return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/proc/clear_grab(playsound = TRUE)
	if(!grabbed_atom)
		return
	if(playsound)
		playsound(grabbed_atom, 'sound/effects/empulse.ogg', 75, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	mod.wearer.clear_fullscreen("kinesis")
	grabbed_atom.cut_overlay(kinesis_icon)
	QDEL_NULL(kinesis_beam)
	grabbed_atom.animate_movement = initial(grabbed_atom.animate_movement)
	grabbed_atom = null

/obj/item/mod/module/anomaly_locked/kinesis/proc/range_check(atom/target)
	if(ismovable(target) && !isturf(target.loc))
		return FALSE
	if(!can_see(mod.wearer, target, grab_range))
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/proc/launch()
	playsound(grabbed_atom, 'sound/magic/repulse.ogg', 100, TRUE)
	var/turf/target_turf = get_turf_in_angle(get_angle(mod.wearer, grabbed_atom), get_turf(src), 10)
	grabbed_atom.throw_at(target_turf, range = grab_range, speed = 4, thrower = mod.wearer)

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype
	name = "MOD prototype kinesis module"
	complexity = 0
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	removable = FALSE

/atom/movable/screen/fullscreen/kinesis
	icon_state = "kinesis"
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	var/mob/kinesis_user
	var/given_x = 16
	var/given_y = 16
	var/turf/given_turf
	COOLDOWN_DECLARE(coordinate_cooldown)

/atom/movable/screen/fullscreen/kinesis/proc/on_move(atom/source, atom/new_location)
	if(given_turf)
		var/x_offset = new_location.x - source.loc.x
		var/y_offset = new_location.y - source.loc.y
		given_turf = locate(given_turf.x+x_offset, given_turf.y+y_offset, given_turf.z)

/atom/movable/screen/fullscreen/kinesis/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)

/atom/movable/screen/fullscreen/kinesis/MouseMove(location, control, params)
	if(!kinesis_user?.client || usr != kinesis_user)
		return
	if(!COOLDOWN_FINISHED(src, coordinate_cooldown))
		return
	COOLDOWN_START(src, coordinate_cooldown, 0.2 SECONDS)
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/list/view = getviewsize(kinesis_user.client.view)
	icon_x *= view[1]/FULLSCREEN_OVERLAY_RESOLUTION_X
	icon_y *= view[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y
	var/our_x = round(icon_x / world.icon_size)
	var/our_y = round(icon_y / world.icon_size)
	var/mob_x = kinesis_user.x
	var/mob_y = kinesis_user.y
	var/mob_z = kinesis_user.z
	given_turf = locate(mob_x+our_x-round(view[1]/2),mob_y+our_y-round(view[2]/2),mob_z)
	given_x = round(icon_x - world.icon_size * our_x)
	given_y = round(icon_y - world.icon_size * our_y)
