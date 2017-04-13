//screeeeeeeeeeeeee

/datum/sutando_abilities/charge
	id = "charge"
	name = "Stampede Force"
	value = 7
	var/charging = FALSE
	var/obj/screen/alert/chargealert

/datum/sutando_abilities/charge/Destroy()
	QDEL_NULL(chargealert)
	return ..()

/datum/sutando_abilities/charge/proc/charging_end()
	charging = FALSE

/datum/sutando_abilities/charge/handle_stats()
	. = ..()
	stand.melee_damage_lower += 9
	stand.melee_damage_upper += 9
	stand.ranged = TRUE //technically
	stand.ranged_message = "charges"
	stand.ranged_cooldown_time += 20
	stand.speed -= 1
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.2

/datum/sutando_abilities/charge/openfire_act(atom/A)
	if(!charging)
		stand.visible_message("<span class='danger'><b>[stand]</b> [stand.ranged_message] at [A]!</span>")
		stand.ranged_cooldown = world.time + stand.ranged_cooldown_time
		stand.clear_alert("charge")
		chargealert = null
		stand.Shoot(A)

/datum/sutando_abilities/charge/life_act()
	if(stand.ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = stand.throw_alert("charge", /obj/screen/alert/cancharge)
	else
		stand.clear_alert("charge")
		chargealert = null

/datum/sutando_abilities/charge/ranged_attack(atom/targeted_atom)
	charging = 1
	stand.throw_at(targeted_atom, stand.range, 1, stand, 0, callback = CALLBACK(stand, .proc/charging_end))


/datum/sutando_abilities/charge/move_act()
	if(charging)
		new /obj/effect/overlay/temp/decoy/fading(stand.loc,stand)
	. = stand.Move()

/datum/sutando_abilities/charge/impact_act(atom/A)
	if(!charging)
		return

	else if(A)
		if(isliving(A) && A != user)
			var/mob/living/L = A
			var/blocked = FALSE
			if(stand.hasmatchingsummoner(A)) //if the user matches don't hurt them
				blocked = TRUE
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(90, "[stand.name]", stand, attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = TRUE
			if(!blocked)
				L.drop_all_held_items()
				L.visible_message("<span class='danger'>[stand] slams into [L]!</span>", "<span class='userdanger'>[stand] slams into you!</span>")
				L.apply_damage(20, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(stand, 2, 3)

		charging = FALSE

/datum/sutando_abilities/charge/snapback_act()
	if(!charging)
		. = stand.snapback()
