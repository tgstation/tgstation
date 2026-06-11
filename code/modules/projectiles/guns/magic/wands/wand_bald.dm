/// Makes you bald, or emphasises your baldness
/obj/item/gun/magic/wand/bald
	name = "shearing rod"
	desc = "A wand commonly used in wizard collegiate hazing, renders victims bald or draws significant attention to their baldness."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/bald
	icon_state = "shavingwand"
	base_icon_state = "shavingwand"
	fire_sound = 'sound/items/tools/welder2.ogg'
	max_charges = 12

/obj/item/gun/magic/wand/bald/zap_self(mob/living/user, suicide)
	. = ..()
	if (!suicide)
		visible_message(span_notice("[user] gives [user.p_themselves()] a quick shave."))
	var/obj/projectile/magic/bald/trimmer = new(user.drop_location())
	trimmer.firer = user
	user.projectile_hit(trimmer, BODY_ZONE_HEAD)
	qdel(trimmer)

/obj/item/gun/magic/wand/bald/do_suicide(mob/living/carbon/human/user)
	var/obj/item/bodypart/head/dome = user.get_bodypart(BODY_ZONE_HEAD)
	if (!dome || ((dome.head_flags & HEAD_HAIR) && user.hairstyle != "Bald"))
		. = ..()
		visible_message(span_suicide("[user] desperately attempts to shave [user.p_themselves()] in a cry for help."))
		return SHAME

	charges--
	user.apply_status_effect(/datum/status_effect/bald_flare)
	dome.dismember(wounding_type = WOUND_SLASH, silent = TRUE)
	visible_message(span_suicide("As the light fades, it becomes clear that [user] has shaved off [user.p_their()] entire head."))

/obj/item/gun/magic/wand/bald/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	zone_override = BODY_ZONE_HEAD // Head only
	return ..()

/obj/item/ammo_casing/magic/bald
	projectile_type = /obj/projectile/magic/bald

/// Embaldens people, or turns their bald spot into a reflective surface
/obj/projectile/magic/bald
	name = "bolt of baldness"
	icon = 'icons/obj/cosmetic.dmi'
	icon_state = "razor"
	damage = 5
	damage_type = BRUTE
	accuracy_falloff = 0

// Currently we have no facility for shaving nonhuman mobs
/obj/projectile/magic/bald/on_hit(mob/living/carbon/human/target, blocked, pierce_hit)
	if (!isliving(target))
		return ..()

	var/obj/item/bodypart/head/dome = target.get_bodypart(BODY_ZONE_HEAD)
	if (iscarbon(target) && !dome)
		return BULLET_ACT_FORCE_PIERCE // No head no shave
	. = ..()
	if (. == BULLET_ACT_BLOCK || !istype(target) || blocked >= 100)
		return

	// First look for wigs or hats
	var/obj/item/hat = target.head // Head here means what's on it, not what it is

	if (hat)
		if (!istype(hat, /obj/item/clothing/head/wig)) // If we're not a wig, check if there's a wig on our hat
			var/obj/item/clothing/head/wig/attached_wig = locate() in hat
			hat = attached_wig || hat

		if (istype(hat, /obj/item/clothing/head/wig))
			hat.forceMove(target.drop_location())
			hat.deconstruct(FALSE)
			if (QDELETED(hat)) // IDK maybe it's disagreed
				visible_message(span_warning("[target]'s \the [hat] is shredded by [src]!"))
				log_combat(firer, target, "magically destroyed wig", src)
			return

		if(hat.flags_inv & HIDEHAIR)
			var/obj/item/clothing/clothing_hat = hat // Not all hats are clothing
			if (!istype(clothing_hat) || !(clothing_hat.clothing_flags & SNUG_FIT))
				visible_message(span_warning("[hat] is knocked off [target]'s head!"))
				target.dropItemToGround(hat)
			return

	// Weird mutant hair
	var/obj/item/organ/mutant_hair = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_POD_HAIR)
	if (mutant_hair)
		mutant_hair.Remove(target, special = FALSE)
		qdel(mutant_hair)
		target.Knockdown(1 SECONDS)
		visible_message(span_warning("[target]'s hair is instantly shaved away by [src]!"))
		log_combat(firer, target, "magically shaved bald", src)
		return

	// Finally normal hair
	if ((dome?.head_flags & HEAD_HAIR) && target.hairstyle != "Bald")
		target.set_hairstyle("Bald")
		target.Knockdown(1 SECONDS)
		visible_message(span_warning("[target]'s hair is instantly shaved away by [src]!"))
		log_combat(firer, target, "magically shaved bald", src)
		return

	target.apply_status_effect(/datum/status_effect/bald_flare)

#define BALD_RAYS_FILTER "bald_ray"

/// Mostly just handles animation
/datum/status_effect/bald_flare
	id = "bald_flare"
	alert_type = null
	duration = 1.6 SECONDS

/datum/status_effect/bald_flare/on_apply()
	. = ..()
	owner.visible_message(span_warning("[owner]'s bald head releases a bright flash of light!"))
	for(var/mob/living/viewers in (viewers(3, owner) - owner))
		viewers.flash_act()

	var/mob/living/carbon/human/human_owner = owner
	var/height = max((human_owner.mob_height || 0) - 2, 0)

	owner.add_filter(name = BALD_RAYS_FILTER, priority = 1, params = list(
		type = "rays",
		y = height,
		size = 10,
		color = COLOR_VERY_SOFT_YELLOW,
		density = 20
	))

	var/ray_filter = owner.get_filter(BALD_RAYS_FILTER)
	animate(ray_filter, size = 30, time = duration * 0.85)
	animate(size = 0, time = duration * 0.15)
	animate(ray_filter, offset = 1.5, time = duration, flags = ANIMATION_PARALLEL)

/datum/status_effect/bald_flare/on_remove()
	owner.remove_filter(BALD_RAYS_FILTER)

#undef BALD_RAYS_FILTER
