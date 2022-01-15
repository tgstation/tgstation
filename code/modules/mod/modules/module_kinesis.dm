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

/obj/item/mod/module/anomaly_locked/kinesis/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(grabbed_atom)
		clear_grab()
		return
	ifif(!range_check(target))
		balloon_alert(mod.wearer, "too far!")
		return
	if(!can_grab(target))
		balloon_alert(mod.wearer, "can't grab!")
		return
	drain_power(use_power_cost)
	grabbed_atom = target
	START_PROCESSING(SSfastprocess, src)
	kinesis_icon = mutable_appearance(icon='icons/effects/effects.dmi', icon_state="kinesis", layer=grabbed_atom.layer-0.1)
	grabbed_atom.add_overlay(kinesis_icon)
	kinesis_beam = mod.wearer.Beam(grabbed_atom, "kinesis")

/obj/item/mod/module/anomaly_locked/kinesis/on_deactivation()
	. = ..()
	if(!.)
		return
	clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/process(delta_time)
	if(!range_check(grabbed_atom))
		balloon_alert(mod.wearer, "out of range!")
		clear_grab()
		return
	drain_power(use_power_cost/10)
	kinesis_beam.redrawing()

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

/obj/item/mod/module/anomaly_locked/kinesis/proc/clear_grab()
	if(!grabbed_atom)
		return
	STOP_PROCESSING(SSfastprocess, src)
	grabbed_atom.cut_overlay(kinesis_icon)
	QDEL_NULL(kinesis_beam)
	grabbed_atom = null

/obj/item/mod/module/anomaly_locked/kinesis/proc/range_check(atom/target)
	if(!isturf(target.loc))
		return FALSE
	if(get_dist(grabbed_atom, mod.wearer) > grab_range)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype
	name = "MOD prototype kinesis module"
	complexity = 0
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	removable = FALSE
