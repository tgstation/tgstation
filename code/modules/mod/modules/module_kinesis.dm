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
	use_power_cost = DEFAULT_CHARGE_DRAIN*5
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked/kinesis)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_kinesis"
	overlay_state_active = "module_kinesis_on"
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/grav)
	var/grab_range = 5
	var/atom/movable/grabbed_atom

/obj/item/mod/module/anomaly_locked/kinesis/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(grabbed_atom)
		clear_grab()
		return
	if(get_dist(grabbed_atom, mod.wearer) > grab_range)
		balloon_alert(mod.wearer, "too far!")
		return
	if(!can_grab(target))
		balloon_alert(mod.wearer, "can't grab!")
		return
	drain_power(use_power_cost)
	grabbed_atom = target
	START_PROCESSING(SSfastprocess, src)

/obj/item/mod/module/anomaly_locked/kinesis/on_deactivation()
	. = ..()
	if(!.)
		return
	clear_grab()

/obj/item/mod/module/anomaly_locked/kinesis/process(delta_time)
	if(get_dist(grabbed_atom, mod.wearer) > grab_range)
		balloon_alert(mod.wearer, "out of range!")
		clear_grab()
		return
	new /obj/effect/temp_visual/emp/pulse(grabbed_atom.loc)

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
	grabbed_atom = null

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype
	name = "MOD prototype kinesis module"
	complexity = 0
	use_power_cost = DEFAULT_CHARGE_DRAIN * 8
	removable = FALSE
