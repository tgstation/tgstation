//screeeeeeeeeeeeee

/datum/guardian_abilities/charge
	id = "charge"
	name = "Stampede Force"
	value = 7
	var/charging = FALSE
	var/obj/screen/alert/chargealert

/datum/guardian_abilities/charge/Destroy()
	QDEL_NULL(chargealert)
	return ..()

/datum/guardian_abilities/charge/proc/charging_end()
	charging = FALSE

/datum/guardian_abilities/charge/handle_stats()
	. = ..()
	guardian.melee_damage_lower += 9
	guardian.melee_damage_upper += 9
	guardian.ranged = TRUE //technically
	guardian.ranged_message = "charges"
	guardian.ranged_cooldown_time += 20
	guardian.speed -= 1
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.2

/datum/guardian_abilities/charge/openfire_act(atom/A)
	if(!charging)
		guardian.visible_message("<span class='danger'><b>[guardian]</b> [guardian.ranged_message] at [A]!</span>")
		guardian.ranged_cooldown = world.time + guardian.ranged_cooldown_time
		guardian.clear_alert("charge")
		chargealert = null
		guardian.Shoot(A)

/datum/guardian_abilities/charge/life_act()
	if(guardian.ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = guardian.throw_alert("charge", /obj/screen/alert/cancharge)
	else
		guardian.clear_alert("charge")
		chargealert = null

/datum/guardian_abilities/charge/ranged_attack(atom/targeted_atom)
	charging = 1
	guardian.throw_at(targeted_atom, guardian.range, 1, guardian, 0, callback = CALLBACK(guardian, .proc/charging_end))


/datum/guardian_abilities/charge/move_act()
	if(charging)
		new /obj/effect/overlay/temp/decoy/fading(guardian.loc,guardian)
	. = guardian.Move()

/datum/guardian_abilities/charge/impact_act(atom/A)
	if(!charging)
		return

	else if(A)
		if(isliving(A) && A != user)
			var/mob/living/L = A
			var/blocked = FALSE
			if(guardian.hasmatchingsummoner(A)) //if the user matches don't hurt them
				blocked = TRUE
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(90, "[guardian.name]", guardian, attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = TRUE
			if(!blocked)
				L.drop_all_held_items()
				L.visible_message("<span class='danger'>[guardian] slams into [L]!</span>", "<span class='userdanger'>[guardian] slams into you!</span>")
				L.apply_damage(20, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(guardian, 2, 3)

		charging = FALSE

/datum/guardian_abilities/charge/snapback_act()
	if(!charging)
		. = guardian.snapback()
