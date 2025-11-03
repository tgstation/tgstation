/datum/action/cooldown/mob_cooldown/blood_worm/spit
	name = "Spit Blood"
	desc = "Spit corrosive blood at your target in exchange for your own health."

	button_icon_state = "spit_blood"

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

	var/health_cost = 0
	var/minimum_health = 10

	var/projectile_type = null

	var/can_burst = FALSE
	var/burst_count = 5

	var/set_message = "You fill your maw with blood. <b>Click to spit corrosive blood!</b>"

/datum/action/cooldown/mob_cooldown/blood_worm/spit/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/spit/set_click_ability(mob/on_who)
	. = ..()
	to_chat(owner, span_notice(set_message))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	to_chat(owner, span_notice("You empty your maw of blood."))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

	if (worm.host?.is_mouth_covered())
		if (feedback)
			owner.balloon_alert(owner, "mouth is covered!")
		return FALSE

	if (worm.health - health_cost < minimum_health)
		if (feedback)
			owner.balloon_alert(owner, "out of blood!")
		return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/spit/InterceptClickOn(mob/living/clicker, params, atom/target)
	. = ..()
	if (!.)
		unset_click_ability(owner, refund_cooldown = FALSE)
		return FALSE

	var/modifiers = params2list(params)

	// Don't block examines, grabs, etc.
	if (modifiers[SHIFT_CLICK] || modifiers[ALT_CLICK] || modifiers[CTRL_CLICK])
		return FALSE

	owner.face_atom(target)

	var/mob/living/basic/blood_worm/worm = src.target

	if (can_burst && worm.host)
		owner.balloon_alert(owner, "no burst while in a host!")

	if (modifiers[RIGHT_CLICK] && can_burst && !worm.host)
		fire_burst(clicker, modifiers, target)
	else
		fire_normal(clicker, modifiers, target)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/Activate(atom/target)
	return TRUE // Has to return true, as otherwise the parent proc of InterceptClickOn will return false, canceling the firing of the projectile.

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/fire_normal(mob/living/clicker, modifiers, atom/target)
	owner.visible_message(
		message = span_danger("\The [owner] spit[owner.p_s()] corrosive blood!"),
		self_message = span_danger("You spit corrosive blood!"),
		blind_message = span_hear("You hear spitting.")
	)

	spit(target, modifiers)

	playsound(owner, SFX_ALIEN_SPIT_ACID, vol = 25, vary = TRUE)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/fire_burst(mob/living/clicker, modifiers, atom/target)
	if (!fire_burst_checks(feedback = TRUE))
		return

	owner.visible_message(
		message = span_danger("\The [owner] pull[owner.p_s()] back [owner.p_their()] head in preparation for something!"),
		self_message = span_danger("You pull back your head in preparation to spit a burst of corrosive blood!")
	)

	if (!do_after(owner, 1 SECONDS, owner, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(fire_burst_checks))))
		owner.balloon_alert(owner, "interrupted!")
		return

	owner.visible_message(
		message = span_danger("\The [owner] spit[owner.p_s()] a burst of corrosive blood!"),
		self_message = span_danger("You spit a burst of corrosive blood!"),
		blind_message = span_hear("You hear spitting.")
	)

	spit(target, modifiers, count = burst_count, spread = 10)

	playsound(owner, SFX_ALIEN_SPIT_ACID, vol = 40, vary = TRUE)
	playsound(owner, 'sound/mobs/non-humanoids/bileworm/bileworm_spit.ogg', vol = 40, vary = TRUE)

	StartCooldown()

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/spit(target, modifiers, count = 1, spread = 0)
	for (var/i in 1 to count)
		var/obj/projectile/blood_worm_spit/spit = new projectile_type(owner.loc)

		spit.firer = owner
		spit.fired_from = owner
		spit.aim_projectile(target, owner, modifiers, deviation = lerp(-spread, spread, (i - 1) / (count - 1)))
		spit.fire()

	owner.newtonian_move(get_angle(target, owner), instant = TRUE, drift_force = count)

	var/mob/living/basic/blood_worm/worm = src.target

	if (worm.host)
		worm.host.blood_volume -= health_cost * BLOOD_WORM_HEALTH_TO_BLOOD * count
	else
		worm.adjustBruteLoss(health_cost * count)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/fire_burst_checks(feedback)
	if (!IsAvailable(feedback))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target
	if (worm.health - health_cost * burst_count < minimum_health)
		if (feedback)
			owner.balloon_alert(owner, "out of blood!")
		return FALSE

	return TRUE

/obj/projectile/blood_worm_spit
	name = "corrosive blood spit"
	icon_state = "blood_spit"

	damage_type = BURN
	armor_flag = BULLET // I'm sorry. Acid armor is too nonsensical for combat, as its granted based on how easily acid should destroy objects.

	hitsound = 'sound/items/weapons/sear.ogg'
	hitsound_wall = 'sound/items/weapons/sear.ogg'

	impact_effect_type = /obj/effect/temp_visual/impact_effect/blood_worm_spit

/obj/effect/temp_visual/impact_effect/blood_worm_spit
	color = "#ff1313"

/datum/action/cooldown/mob_cooldown/blood_worm/spit/juvenile
	health_cost = 6 // This is enough for 15 shots in a row at full health.
	projectile_type = /obj/projectile/blood_worm_spit/juvenile

/obj/projectile/blood_worm_spit/juvenile
	damage = 20 // 300 damage total, assuming no armor.
	armour_penetration = 25 // So that sec cant just nullify half the kit of the blood worms with bulletproof armor.
	wound_bonus = 0 // Juveniles can afford to fix wounds on their hosts. This doesn't cause critical wounds. (at least not in testing)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/adult
	desc = "Spit corrosive blood at your target in exchange for your own health. Right-click to fire a burst while outside of a host."
	cooldown_time = 10 SECONDS // Only applies to burst.
	health_cost = 7.5 // This is enough for 20 shots in a row at full health.
	projectile_type = /obj/projectile/blood_worm_spit/adult
	can_burst = TRUE
	set_message = "You fill your maw with blood. <b>Left-click to spit once, right-click to fire a burst!</b>"

/obj/projectile/blood_worm_spit/adult
	damage = 25 // 500 damage total, assuming no armor.
	armour_penetration = 40 // Yeah no your armor isn't saving you from this.
	wound_bonus = 5 // Okay, now we're talking.
