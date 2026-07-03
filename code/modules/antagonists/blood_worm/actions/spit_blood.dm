/datum/action/cooldown/mob_cooldown/blood_worm/spit
	name = "Плевок кровью"
	desc = "Плюньте токсичной кровью в свою цель в обмен на собственное здоровье. ПКМ находясь в носителе чтобы расплавить оковы."

	button_icon_state = "spit_blood"

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

	var/health_cost = 0
	var/minimum_health = 10

	var/projectile_type = null
	var/burst_projectile_type = null
	var/burst_count = 5

/datum/action/cooldown/mob_cooldown/blood_worm/spit/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/spit/set_click_ability(mob/on_who)
	. = ..()
	var/right_click_message = ishuman(owner) ? ", <b>нажмите ПКМ чтобы расплавить оковы</b>" : (burst_projectile_type ? ",<b> нажмите ПКМ чтобы плюнуть сгустком крови</b>" : "")
	to_chat(owner, span_notice("Вы заполняете [ishuman(owner) ? "рот" : "пасть"] кровью. <b>Нажмите ЛКМ чтобы плюнуть токсичной кровью[right_click_message]!</b>"))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	to_chat(owner, span_notice("Вы опустошаете [ishuman(owner) ? "рот" : "пасть"]  от крови."))

/datum/action/cooldown/mob_cooldown/blood_worm/spit/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

	if (worm.host?.is_mouth_covered())
		if (feedback)
			owner.balloon_alert(owner, "рот закрыт!")
		return FALSE
	if (worm.get_worm_health() - health_cost < minimum_health)
		if (feedback)
			owner.balloon_alert(owner, "закончилась кровь!")
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

	if (modifiers[RIGHT_CLICK] && worm.host)
		melt_restraints()
	else if (modifiers[RIGHT_CLICK] && burst_projectile_type)
		fire_burst(clicker, modifiers, target)
	else
		fire_normal(clicker, modifiers, target)

	if (!IsAvailable(feedback = FALSE))
		unset_click_ability(owner, refund_cooldown = FALSE)

	return TRUE // Intercepts the attack chain.

/datum/action/cooldown/mob_cooldown/blood_worm/spit/Activate(atom/target)
	return TRUE // Has to return true, as otherwise the parent proc of InterceptClickOn will return false, canceling the firing of the projectile.

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/fire_normal(mob/living/clicker, modifiers, atom/target)
	if (target == owner)
		return

	owner.visible_message(
		message = span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] плюётся токсичной кровью!"),
		self_message = span_danger("Вы плюётесь токсичной кровью!"),
		blind_message = span_hear("Вы слышите звук плевка.")
	)

	spit(target, modifiers, projectile_type)

	playsound(owner, SFX_ALIEN_SPIT_ACID, vol = 25, vary = TRUE)

	owner.changeNext_move(CLICK_CD_RANGE)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/fire_burst(mob/living/clicker, modifiers, atom/target)
	if (target == owner)
		return

	var/mob/living/basic/blood_worm/worm = src.target
	if (worm.get_worm_health() - health_cost * burst_count < minimum_health)
		owner.balloon_alert(owner, "закончилась кровь!")
		return

	owner.visible_message(
		message = span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] выплёвывает сгусток токсичной крови!"),
		self_message = span_danger("Вы плюёте сгустком токсичной крови!"),
		blind_message = span_hear("Вы слышите звук плевка.")
	)

	spit(target, modifiers, burst_projectile_type, count = burst_count, spread = 10)

	playsound(owner, SFX_ALIEN_SPIT_ACID, vol = 40, vary = TRUE)
	playsound(owner, 'sound/mobs/non-humanoids/bileworm/bileworm_spit.ogg', vol = 40, vary = TRUE)

	owner.changeNext_move(CLICK_CD_RANGE)
	StartCooldown(10 SECONDS)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/spit(target, modifiers, projectile_type, count = 1, spread = 0)
	for (var/i in 1 to count)
		var/obj/projectile/blood_worm_spit/spit = new projectile_type(owner.loc)

		spit.firer = owner
		spit.fired_from = owner
		spit.aim_projectile(target, owner, modifiers, deviation = count == 1 ? 0 : lerp(-spread, spread, (i - 1) / (count - 1)))
		spit.fire()

	owner.newtonian_move(get_angle(target, owner), instant = TRUE, drift_force = count)

	var/mob/living/basic/blood_worm/worm = src.target

	worm.adjust_worm_health(-health_cost * count)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/melt_restraints()
	var/mob/living/carbon/human/host = owner

	var/melted_something = FALSE
	var/something_to_melt = FALSE

	if (host.handcuffed)
		something_to_melt = TRUE
		melted_something |= melt_restraints_in_slot(host, ITEM_SLOT_HANDCUFFED)
	if (host.legcuffed)
		something_to_melt = TRUE
		melted_something |= melt_restraints_in_slot(host, ITEM_SLOT_LEGCUFFED)
	if (host.wear_suit?.breakouttime)
		something_to_melt = TRUE
		melted_something |= melt_restraints_in_slot(host, ITEM_SLOT_OCLOTHING)
	if (host.shoes?.tied == SHOES_KNOTTED)
		something_to_melt = TRUE
		melted_something |= melt_restraints_in_slot(host, ITEM_SLOT_FEET)
	if (istype(host.loc, /obj/structure/closet))
		something_to_melt = TRUE
		melted_something |= melt_closet(host, host.loc)
	if (istype(host.loc, /obj/structure/spider/cocoon))
		something_to_melt = TRUE
		melted_something |= melt_cocoon(host, host.loc)

	if (melted_something)
		playsound(host, SFX_SIZZLE, vol = 80, vary = TRUE, ignore_walls = FALSE)
		StartCooldown(20 SECONDS)
	if (!something_to_melt)
		host.balloon_alert(host, "Ваши руки свободны!")

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/melt_restraints_in_slot(mob/living/carbon/human/host, slot)
	var/obj/restraints = host.get_item_by_slot(slot)

	if (!istype(restraints))
		return FALSE
	if (restraints.resistance_flags & (INDESTRUCTIBLE | UNACIDABLE | ACID_PROOF))
		host.balloon_alert(host, "[capitalize(restraints.declent_ru(NOMINATIVE))] слишком крепки!")
		return FALSE

	host.visible_message(
		message = span_danger("[capitalize(host.declent_ru(NOMINATIVE))] разбрызгивает токсичную кровь на [restraints.declent_ru(ACCUSATIVE)]!"),
		self_message = span_danger("Вы разбрызгиваете токсичную кровь на [restraints.declent_ru(ACCUSATIVE)]!"),
		blind_message = span_hear("Вы слышите шипение.")
	)

	log_combat(host, restraints, "melted", addition = "(Spit Blood)")

	addtimer(CALLBACK(src, PROC_REF(finish_melting_restraints), restraints), 5 SECONDS)
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/finish_melting_restraints(obj/restraints)
	restraints.visible_message(span_danger("[capitalize(restraints.declent_ru(NOMINATIVE))] плавятся, превращаясь в сгусток крови!"))
	new /obj/effect/decal/cleanable/blood/old(get_turf(restraints))
	qdel(restraints)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/melt_closet(mob/living/carbon/human/host, obj/structure/closet/closet)
	if (closet.resistance_flags & (INDESTRUCTIBLE | UNACIDABLE | ACID_PROOF))
		host.balloon_alert(host, "[capitalize(closet.declent_ru(NOMINATIVE))] слишком крепкий!")
		return FALSE

	closet.visible_message(
		message = span_danger("Петли [closet.declent_ru(GENITIVE)] переполняются разъедающей кровью и начинают плавиться!"),
		blind_message = span_hear("Вы слышите шипение."),
		ignored_mobs = host
	)

	to_chat(host, span_danger("Вы разбрызгиваете токсичную кровь на петли [closet.declent_ru(GENITIVE)]!"))

	log_combat(host, closet, "melted", addition = "(Spit Blood)")

	addtimer(CALLBACK(src, PROC_REF(finish_melting_closet), closet), 5 SECONDS)
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/finish_melting_closet(obj/structure/closet/closet)
	closet.visible_message(span_danger("Петли [closet.declent_ru(GENITIVE)] плавятся, превращаясь в сгусток крови!"))
	new /obj/effect/decal/cleanable/blood/old(get_turf(closet))

	closet.welded = FALSE
	closet.locked = FALSE
	closet.broken = TRUE
	closet.open()

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/melt_cocoon(mob/living/carbon/human/host, obj/structure/spider/cocoon/cocoon)
	if (cocoon.resistance_flags & (INDESTRUCTIBLE | UNACIDABLE | ACID_PROOF))
		host.balloon_alert(host, "[capitalize(cocoon.declent_ru(NOMINATIVE))] слишком крепкая!")
		return FALSE

	cocoon.visible_message(
		message = span_danger("Оболочка [cocoon.declent_ru(GENITIVE)] начинает распадаться!"),
		blind_message = span_hear("Вы слышите шипение."),
		ignored_mobs = host
	)

	to_chat(host, span_danger("Вы расплескиваете токсичную кровь по всей внутренней части [cocoon.declent_ru(GENITIVE)]!"))

	log_combat(host, cocoon, "melted", addition = "(Spit Blood)")

	addtimer(CALLBACK(src, PROC_REF(finish_melting_cocoon), cocoon), 5 SECONDS)
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_worm/spit/proc/finish_melting_cocoon(obj/structure/spider/cocoon/cocoon)
	cocoon.visible_message(span_danger("[cocoon.declent_ru(NOMINATIVE)] плавится, превращаясь в кучу липкой крови!"))
	new /obj/effect/decal/cleanable/blood/old(get_turf(cocoon))
	qdel(cocoon)

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
	health_cost = 5.5 // This is enough for 20 shots in a row at full health. (keep in mind that health is VERY important)
	projectile_type = /obj/projectile/blood_worm_spit/juvenile

/obj/projectile/blood_worm_spit/juvenile
	damage = 20 // 300 damage total, assuming no armor.
	armour_penetration = 30 // So that sec cant just nullify half the kit of the blood worms with bulletproof armor.
	wound_bonus = 0 // Juveniles can afford to fix wounds on their hosts. This doesn't cause critical wounds. (at least not in testing)

/datum/action/cooldown/mob_cooldown/blood_worm/spit/adult
	desc = "Плюньте токсичной кровью в свою цель в обмен на собственное здоровье. Нажмите ПКМ, чтобы расплавить оковы, находясь в носителе, или плюнуть токсичной кровью, если вы вне носителя."
	health_cost = 6.5 // This is enough for 26 shots in a row at full health. (keep in mind that health is VERY important)
	projectile_type = /obj/projectile/blood_worm_spit/adult
	burst_projectile_type = /obj/projectile/blood_worm_spit/adult_burst

/obj/projectile/blood_worm_spit/adult
	damage = 25 // 500 damage total, assuming no armor.
	armour_penetration = 50 // Yeah no your armor isn't saving you from this.
	wound_bonus = 5 // Okay, now we're talking.

/obj/projectile/blood_worm_spit/adult_burst
	damage = 15 // 75 damage per burst if all hit.
	armour_penetration = 50 // Same armor penetration.
	wound_bonus = 2 // Slightly less wound power than normal.
