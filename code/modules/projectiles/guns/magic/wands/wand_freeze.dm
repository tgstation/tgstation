/**
 * Freezing wand places you in an ice cube and creates ice turfs
 */
/obj/item/gun/magic/wand/freeze
	name = "wand of ice"
	desc = "The chilling power of this wand will stop your enemies in their tracks."
	school = SCHOOL_EVOCATION
	ammo_type = /obj/item/ammo_casing/magic/freeze
	icon_state = "telewand"
	base_icon_state = "telewand"
	fire_sound = 'sound/effects/magic/blink.ogg'
	max_charges = 8

/obj/item/gun/magic/wand/freeze/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	to_chat(user, span_warning("You freeze yourself in a block of ice!"))
	user.apply_status_effect(/datum/status_effect/ice_block_talisman, 10 SECONDS)
	var/turf/hit_turf = get_turf(user)
	if (isfloorturf(hit_turf) && !isspaceturf(hit_turf) && !isindestructiblefloor(hit_turf))
		hit_turf.ChangeTurf(/turf/open/floor/fakeice/slippery, flags = CHANGETURF_INHERIT_AIR)
	charges--

/obj/item/gun/magic/wand/freeze/do_suicide(mob/living/user)
	playsound(user, fire_sound, 50, TRUE)
	var/obj/structure/statue/snow/snowman/snover = new(user.drop_location())
	snover.name = user.real_name
	var/obj/item/organ/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if (brain)
		brain.Remove(user)
		brain.forceMove(snover)
	user.unequip_everything()
	qdel(user)
	return MANUAL_SUICIDE

/obj/item/ammo_casing/magic/freeze
	projectile_type = /obj/projectile/magic/freeze
	harmful = FALSE

/obj/projectile/magic/freeze
	name = "bolt of freezing"
	icon_state = "ice_2"

/obj/projectile/magic/freeze/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/hit_turf = get_turf(target)
	if (isfloorturf(hit_turf) && !isspaceturf(hit_turf) && !isindestructiblefloor(hit_turf))
		hit_turf.ChangeTurf(/turf/open/floor/fakeice/slippery, flags = CHANGETURF_INHERIT_AIR)

	var/mob/living/victim = target
	if (!istype(victim))
		return
	victim.apply_status_effect(/datum/status_effect/ice_block_talisman, 10 SECONDS)
