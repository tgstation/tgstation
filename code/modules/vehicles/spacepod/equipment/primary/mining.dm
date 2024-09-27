/obj/item/pod_equipment/primary/projectile_weapon/energy/plasma_cutter
	name = "plasma cutter apparatus"
	desc = "An apparatus for pods that fires plasma cutter beams."
	icon_state = "plasmacutter"
	casing_path = /obj/item/ammo_casing/energy/plasma
	fire_sound = /obj/item/ammo_casing/energy/plasma::fire_sound
	cooldown_time = 2 SECONDS
	power_used_to_fire = STANDARD_BATTERY_CHARGE / 50

/obj/item/pod_equipment/primary/projectile_weapon/energy/kinetic_accelerator
	name = "pod proto-kinetic accelerator"
	icon_state = "pka"
	projectile_path = /obj/item/ammo_casing/energy/kinetic::projectile_type
	fire_sound = /obj/item/ammo_casing/energy/kinetic::fire_sound
	cooldown_time = 1.75 SECONDS
	power_used_to_fire = STANDARD_BATTERY_CHARGE / 60

/obj/item/pod_equipment/primary/drill
	name = "pod mining drill"
	desc = "A rig for pods that drills rocks infront of it."
	cooldown_time = 1 SECONDS
	icon_state = "drill"
	interface_id = "GenericLines"
	/// damage vs objects
	var/damage_obj = 10
	/// damage vs mobs
	var/damage_mob = 20
	/// power used to drill
	var/power_used = STANDARD_BATTERY_CHARGE / 80
	/// force multiplier if we hit a rock to drill it
	var/force_mult = 0

/obj/item/pod_equipment/primary/drill/on_attach(mob/user)
	. = ..()
	RegisterSignal(pod, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))

/obj/item/pod_equipment/primary/drill/on_detach(mob/user)
	. = ..()
	UnregisterSignal(pod, COMSIG_MOVABLE_BUMP)

/obj/item/pod_equipment/primary/drill/ui_data(mob/user)
	return list(
		"lines" = list(
			"Power used to drill" = power_used,
			"Force remaining after impact" = "[force_mult]x of impact speed"
		)
	)

/obj/item/pod_equipment/primary/drill/proc/on_bump(datum/source, atom/bumped)
	SIGNAL_HANDLER
	if(get_dir(pod, bumped) != pod.dir)
		return

	if(!ismineralturf(get_step(pod, pod.dir)))
		if(!COOLDOWN_FINISHED(src, use_cooldown))
			return
		COOLDOWN_START(src, use_cooldown, cooldown_time)

	if(action())
		if(pod.drift_handler)
			if(!force_mult)
				qdel(pod.drift_handler)
			else
				var/force_needed = abs(pod.drift_handler.drift_force - pod.drift_handler.drift_force * force_mult)
				pod.newtonian_move(dir2angle(REVERSE_DIR(pod.dir)), instant = TRUE, drift_force = force_needed)
		return COMPONENT_INTERCEPT_BUMPED // OK SO if the moveloop fails to move it qdels itself which is exactly what breaks this, idk how to fix

/obj/item/pod_equipment/primary/drill/action(mob/user)
	if(!pod.use_power(power_used))
		return FALSE
	var/turf/target_turf = get_step(pod, pod.dir)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/mineral_turf = target_turf
		playsound(pod.loc, 'sound/items/weapons/drill.ogg', 50 , TRUE)
		mineral_turf.gets_drilled()
		return TRUE
	if(isclosedturf(target_turf))
		playsound(pod.loc, 'sound/items/weapons/drill.ogg', 50 , TRUE)
		return FALSE
	for(var/atom/movable/potential_target as anything in target_turf.contents)
		if(!potential_target.density)
			continue
		if(isliving(potential_target))
			var/mob/living/target = potential_target
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				return FALSE
			playsound(pod.loc, 'sound/items/weapons/drill.ogg', 50 , TRUE)
			potential_target.visible_message(span_danger("[potential_target] is drilled by the [pod]!"))
			target.apply_damage(damage_mob, BRUTE)
			if(iscarbon(target) && prob(35)) // no
				target.Knockdown(1 SECONDS)
		else
			playsound(pod.loc, 'sound/items/weapons/drill.ogg', 50 , TRUE)
			potential_target.visible_message(span_danger("[potential_target] is drilled by the [pod]!"))
			potential_target.take_damage(damage_obj, BRUTE, attack_dir = REVERSE_DIR(pod.dir))
		return TRUE
	return FALSE

/obj/item/pod_equipment/primary/drill/impact
	name = "pod impact drill"
	desc = "Advanced variant of the pod drill, this one mines anything it bumps into. Equipped with advanced velocity tech, if it can be drilled, you only slightly lose speed."
	power_used = STANDARD_BATTERY_CHARGE / 60
	force_mult = 0.8

/obj/item/pod_equipment/primary/drill/impact/improved
	name = "improved pod impact drill"
	desc = "Advanced variant of the pod drill, this one mines anything it bumps into. Improves on its previous version by slowing you down even less."
	force_mult = 0.9
	power_used = STANDARD_BATTERY_CHARGE / 40

/obj/item/pod_equipment/primary/metalfoam
	name = "pod metal foam dispenser"
	desc = "Puts metal foam infront of your pod. Comes with a tool to also clear foam, or maybe beat up the local fish, not capable of exerting enough force to damage anything else."
	icon_state = "foamthing"
	interface_id = "GenericLines"
	cooldown_time = 3 SECONDS
	/// power used
	var/power_usage = STANDARD_BATTERY_CHARGE / 50

/obj/item/pod_equipment/primary/metalfoam/ui_data(mob/user)
	return list(
		"lines" = list(
			"Power used" = power_usage,
		)
	)

/obj/item/pod_equipment/primary/metalfoam/action(mob/user)
	var/turf/target_turf = get_step(pod, pod.dir)
	if(isclosedturf(target_turf))
		return FALSE
	for(var/atom/movable/potential_target as anything in target_turf.contents)
		if(!potential_target.density)
			continue

		if(istype(potential_target, /obj/structure/foamedmetal))
			if(!pod.use_power(power_usage))
				return FALSE
			playsound(pod.loc, 'sound/items/weapons/drill.ogg', 35 , TRUE)
			potential_target.visible_message(span_warning("[pod] clears [potential_target]."))
			potential_target.take_damage(300, BRUTE)

		else if(isliving(potential_target))
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				return FALSE
			if(!pod.use_power(power_usage))
				return FALSE
			var/mob/living/target = potential_target
			playsound(pod.loc, 'sound/items/weapons/drill.ogg', 50 , TRUE)
			potential_target.visible_message(span_danger("[pod] hits [potential_target] with a clearing apparatus!"))
			target.apply_damage(8, BRUTE)

		return TRUE

	if(!pod.use_power(power_usage))
		return FALSE

	var/datum/effect_system/fluid_spread/foam/foam = new /datum/effect_system/fluid_spread/foam/metal()
	foam.set_up(range = 1, amount = 1, holder = src, location = target_turf)
	foam.start()

	return TRUE
