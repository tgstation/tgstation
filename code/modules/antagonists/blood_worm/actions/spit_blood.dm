/datum/action/cooldown/mob_cooldown/blood_worm_spit
	name = "Spit Blood"
	desc = "Spit corrosive blood at your target in exchange for your own health."

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

	var/health_cost = 0
	var/minimum_health = 20

	var/projectile_type = null

/datum/action/cooldown/mob_cooldown/blood_worm_spit/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm_spit/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm_spit/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

	if (worm.health - health_cost < minimum_health)
		if (feedback)
			owner.balloon_alert(owner, "out of blood!")
		return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm_spit/InterceptClickOn(mob/living/clicker, params, atom/target)
	. = ..()
	if (!.)
		unset_click_ability(owner, refund_cooldown = FALSE)
		return

	var/modifiers = params2list(params)

	owner.visible_message(
		message = span_danger("\The [owner] spit[owner.p_s()] blood!"),
		self_message = span_warning("You spit blood!"),
		blind_message = span_hear("You hear spitting.")
	)

	var/obj/projectile/blood_worm_spit/spit = new projectile_type(owner.loc)

	spit.firer = owner
	spit.fired_from = owner
	spit.aim_projectile(target, owner, modifiers)
	spit.fire()

	playsound(owner, SFX_ALIEN_SPIT_ACID, vol = 25, vary = TRUE)

	owner.newtonian_move(get_angle(target, owner), instant = TRUE, drift_force = 1 NEWTONS)

	if (ishuman(owner))
		var/mob/living/carbon/human/host = owner
		host.blood_volume -= health_cost * BLOOD_WORM_HEALTH_TO_BLOOD
	else
		var/mob/living/basic/blood_worm/worm = owner
		worm.adjustBruteLoss(health_cost)

/datum/action/cooldown/mob_cooldown/blood_worm_spit/Activate(atom/target)
	return TRUE // Has to return true, as otherwise the parent proc of InterceptClickOn will return false, canceling the firing of the projectile.

/obj/projectile/blood_worm_spit
	name = "blood spit"
	icon_state = "neurotoxin" // TEMP ICON

	damage_type = BURN
	armor_flag = ACID

	hitsound = 'sound/items/weapons/sear.ogg'
	hitsound_wall = 'sound/items/weapons/sear.ogg'

	impact_effect_type = /obj/effect/temp_visual/impact_effect/blood_worm_spit

/obj/effect/temp_visual/impact_effect/blood_worm_spit
	color = "#5BDD04" // TEMP COLOR

/datum/action/cooldown/mob_cooldown/blood_worm_spit/hatchling
	health_cost = 3 // This is enough for 10 shots at full health.
	projectile_type = /obj/projectile/blood_worm_spit/hatchling

/obj/projectile/blood_worm_spit/hatchling
	damage = 15
	armour_penetration = 40
