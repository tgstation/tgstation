/**
 * Levitation wand applies anti-gravity to target.
 */
/obj/item/gun/magic/wand/levitate
	name = "lifting rod"
	desc = "The power of this rod lifts living creatures off the ground, potentially leaving them unable to move."
	school = SCHOOL_TRANSLOCATION
	ammo_type = /obj/item/ammo_casing/magic/levitate
	icon_state = "gravwand"
	base_icon_state = "gravwand"
	fire_sound = 'sound/effects/magic/repulse.ogg'
	max_charges = 12

/obj/item/gun/magic/wand/levitate/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	user.apply_status_effect(/datum/status_effect/levitate)

/obj/item/gun/magic/wand/levitate/do_suicide(mob/living/user)
	if (!iscarbon(user))
		. = ..()
		return SHAME

	charges--
	playsound(user, fire_sound, 50, TRUE)
	user.visible_message(span_suicide("[user] inverts gravity inside of [user.p_their()] body!"))
	var/mob/living/carbon/organ_haver = user
	for (var/obj/item/organ/organ as anything in organ_haver.organs)
		organ.Remove(user)
		organ.forceMove(user.drop_location())
		organ.AddElement(/datum/element/forced_gravity, -1)

	var/obj/item/bodypart/chest = user.get_bodypart(BODY_ZONE_CHEST)
	chest.dismember()

	return MANUAL_SUICIDE // I think every carbon dies if you remove all the organs from its body

/obj/item/ammo_casing/magic/levitate
	projectile_type = /obj/projectile/magic/levitate
	harmful = FALSE

/obj/projectile/magic/levitate
	name = "bolt of levitation"
	icon_state = "bluespace"

/obj/projectile/magic/levitate/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/victim = target
	if (!istype(victim))
		return
	victim.apply_status_effect(/datum/status_effect/levitate)

/datum/status_effect/levitate
	id = "levitated"
	status_type = STATUS_EFFECT_REPLACE
	duration = 2 MINUTES
	alert_type = null

/datum/status_effect/levitate/on_apply()
	owner.visible_message(span_warning("[owner] floats into the air!"))
	owner.AddElement(/datum/element/forced_gravity, 0)
	owner.add_filter("antigrav_glow", 2, list("type" = "outline", "color" = "#de3aff48", "size" = 2))
	return ..()

/datum/status_effect/levitate/on_remove()
	owner.visible_message(span_notice("[owner] gently descends to the ground"))
	owner.RemoveElement(/datum/element/forced_gravity, 0)
	owner.remove_filter("antigrav_glow")
	return ..()
