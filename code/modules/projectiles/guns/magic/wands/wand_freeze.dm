/**
 * Freezing wand places you in an ice cube and creates ice turfs
 */
/obj/item/gun/magic/wand/freeze
	name = "wand of ice"
	desc = "The chilling power of this wand will stop your enemies in their tracks."
	school = SCHOOL_EVOCATION
	ammo_type = /obj/item/ammo_casing/magic/freeze
	icon_state = "icewand"
	base_icon_state = "icewand"
	fire_sound = 'sound/effects/magic/blink.ogg'
	max_charges = 8

/obj/item/gun/magic/wand/freeze/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	to_chat(user, span_warning("You freeze yourself in a block of ice!"))
	var/obj/projectile/magic/freeze/ice = new(user.drop_location())
	ice.firer = user
	user.projectile_hit(ice, BODY_ZONE_CHEST)
	qdel(ice)
	charges--

/obj/item/gun/magic/wand/freeze/do_suicide(mob/living/user)
	charges--
	playsound(user, fire_sound, 50, TRUE)
	var/obj/structure/statue/snow/snowman/snover = new(user.drop_location())
	snover.name = user.real_name
	var/obj/item/organ/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if (brain)
		brain.Remove(user)
		brain.forceMove(snover)
	user.unequip_everything()
	user.ghostize()
	qdel(user)
	return MANUAL_SUICIDE

/obj/item/ammo_casing/magic/freeze
	projectile_type = /obj/projectile/magic/freeze
	harmful = FALSE

/obj/projectile/magic/freeze
	name = "bolt of freezing"
	icon_state = "ice_1"
	/// Temperature change to apply to hit mob
	var/temperature = -350

/obj/projectile/magic/freeze/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/hit_turf = get_turf(target)
	if (isfloorturf(hit_turf) && !isspaceturf(hit_turf) && !isindestructiblefloor(hit_turf))
		hit_turf.ChangeTurf(/turf/open/floor/fakeice/slippery, flags = CHANGETURF_INHERIT_AIR)

	if(isobj(target))
		var/obj/thingy = target

		if(thingy.reagents)
			var/datum/reagents/reagents = thingy.reagents
			reagents?.expose_temperature(temperature)
		return

	var/mob/living/victim = target
	if (!istype(victim))
		return

	victim.apply_status_effect(/datum/status_effect/ice_block_talisman, 10 SECONDS)

	var/applied_temp = (1 - blocked) * temperature
	if(iscarbon(target))
		var/mob/living/carbon/chill_dude = target
		var/thermal_protection = 1 - chill_dude.get_insulation_protection(chill_dude.bodytemperature + temperature)
		applied_temp = (thermal_protection * temperature) + temperature

	victim.adjust_bodytemperature(applied_temp)
