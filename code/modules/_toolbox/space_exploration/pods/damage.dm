/*
* Pod Wreckage
*/

/obj/structure/pod_wreckage
	name = "pod wreckage"
	icon_state = "pod_parts"

	New(loc, var/list/size = list())
		..(loc)
		icon = file("icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi")
		bound_width = size[1] * 32
		bound_height = size[2] * 32

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/weldingtool))
			var/obj/item/weldingtool/W = I
			if(W.isOn())
				if(prob(75))
					var/obj/item/stack/sheet/S
					S = new /obj/item/stack/sheet/metal(get_turf(src))
					S.amount = (5 * pick(1, 2, 3, 4)) + rand(1, 9)
					if(prob(20))
						S = new /obj/item/stack/sheet/plasteel(get_turf(src))
						S.amount = 2 * pick(1, 2, 3)
					qdel(src)

/*
* Damage System
*/

/obj/pod
	var/health = 200
	var/max_health
	var/pod_damage = 0 // Bitflag
	var/emped_at = 0
	var/emped_duration = 0

	proc/GetDamageFlag()
		return pod_damage

	proc/SetDamageFlag(var/bf)
		pod_damage = bf
		update_icon()

	proc/RemoveDamageFlag(var/bf)
		pod_damage &= ~bf
		update_icon()

	proc/AddDamageFlag(var/bf)
		pod_damage |= bf
		update_icon()

	proc/HasDamageFlag(var/bf)
		return pod_damage & bf

	proc/HealthPercent()
		return round((health / max_health) * 100)

	proc/TakeDamage(var/damage = 0, var/ignore_defense = 0, var/obj/item/I, var/mob/living/attacker = 0)
		if(ignore_defense)
			health -= damage
			return 1

		var/obj/item/pod_attachment/armor/armor = GetAttachmentOnHardpoint(P_HARDPOINT_ARMOR)
		var/obj/item/pod_attachment/shield/shield = GetAttachmentOnHardpoint(P_HARDPOINT_SHIELD)

		if(shield)
			if(shield.Absorb(damage))
				PrintSystemNotice("Shield absorbed damage.")
				pod_log.LogDamage(damage, P_DAMAGE_ABSORBED, I)
				return 1

		var/armor_applied = 0
		if(armor)
			var/result = armor.Absorb(damage)
			if(result < damage)
				PrintSystemNotice("Armor reduced damage.")
				damage = result
				armor_applied = 1

		if(!armor_applied)
			PrintSystemAlert("Hull Damage taken.")

		pod_log.LogDamage(damage, (armor_applied ? P_DAMAGE_REDUCED : 0), I, attacker)

		health -= damage

		if(pod_damage_iterator)
			pod_damage_iterator.process()

		var/datum/effect_system/spark_spread/hit_sparks = new /datum/effect_system/spark_spread
		var/turf/hit_turf = get_turf((attacker ? attacker : I ? I : src))
		var/direction = get_dir(get_turf(src), hit_turf)
		var/angle = dir2angle(direction)
		if((angle % 90) != 0)
			direction = angle2dir((angle == 45) ? (angle + 45) : (angle - 45))
		hit_sparks.set_up(5, 0, pick(GetDirectionalTurfsUnderPod(direction)))
		hit_sparks.start()

	proc/DestroyPod()
		pod_log.Log("Pod Destroyed.")

		for(var/datum/global_iterator/iterator in GetIterators())
			iterator.stop()
			qdel(iterator)

		for(var/mob/living/carbon/human/H in GetOccupants())
			H.loc = get_turf(src)

			if(istype(get_turf(src), /turf/open/space) && inertial_direction)
				step(H, inertial_direction)

			if(H == pilot)
				pilot = 0

		explosion(get_turf(src), 0, 0, 1, 3)

		if(HasDamageFlag(P_DAMAGE_FIRE))
			explosion(get_turf(src), 0, 0, 0, 0, 1, 0, 2)

		var/obj/item/pod_attachment/cargo/cargo = GetAttachmentOnHardpoint(P_HARDPOINT_CARGO_HOLD)
		if(cargo)
			for(var/atom/movable/M in cargo)
				M.loc = get_turf(src)

		new /obj/structure/pod_wreckage(get_turf(src), size)

		for(var/turf/T in range(1, get_turf(src)))
			if(prob(40))
				if(prob(60))
					new /obj/effect/decal/cleanable/dirt(T)
				else
					new /obj/effect/decal/cleanable/oil(T)

		spawn(0)
			qdel(src)

	attack_paw(var/mob/living/user)
		TakeDamage(rand(GLOB.pod_config.paw_damage_lower, GLOB.pod_config.paw_damage_upper), 0, 0, user)
		user.changeNext_move(8)
		to_chat(user,"<span class='warning'>You scratch \the [src].</span>")

	attack_alien(var/mob/living/user)
		TakeDamage(rand(GLOB.pod_config.alien_damage_lower, GLOB.pod_config.alien_damage_lower), 0, 0, user)
		user.changeNext_move(8)
		to_chat(user,"<span class='warning'>You slash \the [src].</span>")

	attack_animal(var/mob/living/simple_animal/animal)
		TakeDamage(rand(animal.melee_damage_lower, animal.melee_damage_upper), 0, 0, animal)
		animal.changeNext_move(8)
		to_chat(animal,"<span class='warning'>You claw \the [src].</span>")

	bullet_act(var/obj/item/projectile/P)
		if(istype(P, /obj/item/projectile/ion))
			emp_act(1)
			return 0

		if((P.damage_type == BURN) || (P.damage_type == BRUTE) || (P.damage_type in list("burn", "brute", "fire")))
			if(src in P.permutated)
				del(P)
			else
				TakeDamage(P.damage, 0, P)

			return 0

		..()

		return 0

	// We're taking the reciprocal for the severity, because 1 is the most severe and 3 the least.
	emp_act(var/severity)
		playsound(get_turf(src), 'sound/effects/EMPulse.ogg', 30, 5, 0)

		for(var/obj/item/pod_attachment/attachment in GetAttachments())
			if(prob(round(GLOB.pod_config.emp_act_attachment_toggle_chance * (1 / severity))))
				attachment.ToggleActive()

		emped_duration = (1 / severity) * GLOB.pod_config.emp_act_duration
		emped_at = world.time
		AddDamageFlag(P_DAMAGE_EMPED)

		if(power_source)
			var/power_to_absorb_percent = (1 / severity) * GLOB.pod_config.emp_act_power_absorb_percent
			if(!UsePower(power_source.maxcharge * (power_to_absorb_percent / 100)))
				power_source.charge = 0
			var/datum/effect_system/lightning_spread/system = new()
			system.set_up(3, 0, pick(GetDirectionalTurfsUnderPod(GLOB.cardinals)))
			system.start()

		sparks.start()

	ex_act(var/severity)
		TakeDamage(GLOB.pod_config.ex_act_damage * (1 / severity))

	blob_act(var/severity)
		TakeDamage(GLOB.pod_config.blob_act_damage * (1 / severity))

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		fire_act(0, exposed_temperature, exposed_volume)
		..()

	fire_act(var/severity, var/temperature, var/volume, var/show_notice = 1)
		var/obj/item/pod_attachment/armor/armor = GetAttachmentOnHardpoint(P_HARDPOINT_ARMOR)
		if(!HasDamageFlag(P_DAMAGE_FIRE))
			if(armor)
				if(!armor.CanAbsorbTemperature(temperature))
					AddDamageFlag(P_DAMAGE_FIRE)
					PrintSystemAlert("Fire outburst in cabin.")
				else
					if(show_notice)
						PrintSystemNotice("Armor absorbed temperature.")
						pod_damage_iterator.last_notice_tick = world.time
			else
				AddDamageFlag(P_DAMAGE_FIRE)

		return 0

/*
* Damage Iterator
*/

/datum/global_iterator/pod_damage
	delay = 2

	var/last_fire_tick
	var/last_notice_tick

	process(var/obj/pod/pod)
		if(!pod)
			return

		if(pod.health <= 0)
			pod.DestroyPod()
			return 0

		pod.health = CLAMP(pod.health, 0, pod.max_health)

		var/health_percent = pod.HealthPercent()
		if(health_percent <= GLOB.pod_config.damage_overlay_threshold)
			if(!pod.HasDamageFlag(P_DAMAGE_GENERAL))
				pod.AddDamageFlag(P_DAMAGE_GENERAL)
		else
			if(pod.HasDamageFlag(P_DAMAGE_GENERAL))
				pod.RemoveDamageFlag(P_DAMAGE_GENERAL)

		if(pod.HasDamageFlag(P_DAMAGE_FIRE) && ((last_fire_tick + GLOB.pod_config.fire_damage_cooldown) <= world.time))
			// If we are in space, the fire consumes a bit of oxygen from the internal air (which is refilled by the gas canister in the pod)
			if(istype(get_turf(pod), /turf/open/space))
				if(!pod.internal_air || pod.internal_air.gases[/datum/gas/oxygen][MOLES] < GLOB.pod_config.fire_damage_oygen_cutoff)
					pod.RemoveDamageFlag(P_DAMAGE_FIRE)

				pod.internal_air.gases[/datum/gas/oxygen][MOLES] = (pod.internal_air.gases[/datum/gas/oxygen][MOLES] - (pod.internal_air.gases[/datum/gas/oxygen][MOLES] * GLOB.pod_config.fire_oxygen_consumption_percent))

			pod.TakeDamage(GLOB.pod_config.fire_damage)
			last_fire_tick = world.time

		if(pod.HasDamageFlag(P_DAMAGE_EMPED))
			if((pod.emped_at + pod.emped_duration) <= world.time)
				pod.RemoveDamageFlag(P_DAMAGE_EMPED)
			else
				if(prob(GLOB.pod_config.emp_sparkchance))
					pod.sparks.start()

		for(var/obj/effect/hotspot/H in pod.GetTurfsUnderPod())
			var/show_notice = ((last_notice_tick + GLOB.pod_config.damage_notice_cooldown) <= world.time)
			pod.fire_act(0, H.temperature, H.volume, show_notice)
