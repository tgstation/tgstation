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

/datum/action/cooldown/mob_cooldown/blood_worm/spit/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/spit/set_click_ability(mob/on_who)
	. = ..()
	to_chat(span_notice("You fill your maw with blood. <b>Click to spit corrosive blood!</b>"))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	to_chat(span_notice("You empty your maw of blood."))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

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

	owner.visible_message(
		message = span_danger("\The [owner] spit[owner.p_s()] corrosive blood!"),
		self_message = span_danger("You spit corrosive blood!"),
		blind_message = span_hear("You hear spitting.")
	)

	var/obj/projectile/blood_worm_spit/spit = new projectile_type(owner.loc)

	spit.firer = owner
	spit.fired_from = owner
	spit.aim_projectile(target, owner, modifiers)
	spit.fire()

	playsound(owner, SFX_ALIEN_SPIT_ACID, vol = 25, vary = TRUE)

	owner.newtonian_move(get_angle(target, owner), instant = TRUE, drift_force = 1 NEWTONS)
	owner.face_atom(target)

	var/mob/living/basic/blood_worm/worm = src.target

	if (worm.host)
		worm.host.blood_volume -= health_cost * BLOOD_WORM_HEALTH_TO_BLOOD
	else
		worm.adjustBruteLoss(health_cost)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/Activate(atom/target)
	return TRUE // Has to return true, as otherwise the parent proc of InterceptClickOn will return false, canceling the firing of the projectile.

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
	health_cost = 7.5 // This is enough for 20 shots in a row at full health.
	projectile_type = /obj/projectile/blood_worm_spit/adult

/obj/projectile/blood_worm_spit/adult
	damage = 25 // 500 damage total, assuming no armor.
	armour_penetration = 40 // Yeah no your armor isn't saving you from this.
	wound_bonus = 5 // Okay, now we're talking.
