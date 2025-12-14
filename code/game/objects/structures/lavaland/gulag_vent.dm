/**
 * A boulder-spawning structure superficially similar to an ore vent which doesnt share any of its behaviour
 * Prisoners can haul boulders up out of it in case the actual mining area is totally spent
 */
/obj/structure/gulag_vent
	name = "work pit"
	desc = "A timeworn shaft, almost totally mined out. With a bit of effort you might be able to haul something up."
	icon = 'icons/obj/mining_zones/terrain.dmi'
	icon_state = "ore_vent_active"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //This thing will take a beating.
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_REQUIRES_DEXTERITY
	anchored = TRUE
	density = TRUE
	/// What kind of rock we got in there?
	var/spawned_boulder = /obj/item/boulder/gulag
	/// Prevents multiple people from hauling at a time
	var/occupied = FALSE

/obj/structure/gulag_vent/ice
	icon_state = "ore_vent_ice_active"

/obj/structure/gulag_vent/interact(mob/user)
	. = ..()
	if (!isliving(user))
		return
	if (occupied)
		balloon_alert(user, "occupied!")
		return
	var/mob/living/living_user = user
	occupied = TRUE
	living_user.balloon_alert_to_viewers("hauling...")

	var/boulder_lift_speed = 8 SECONDS

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = living_user.get_organ_slot(ORGAN_SLOT_SPINE)
	if(istype(potential_spine))
		boulder_lift_speed *= potential_spine.athletics_boost_multiplier

	var/succeeded = do_after(living_user, boulder_lift_speed, src)
	occupied = FALSE
	if (!succeeded)
		return
	var/stamina_damage_to_inflict = HAS_TRAIT(user, TRAIT_STRENGTH) ? 60 : 120 //Decreases the amount of stamina damage inflicted by half if you're STRONG
	living_user.mind?.adjust_experience(/datum/skill/athletics, 10)
	living_user.apply_status_effect(/datum/status_effect/exercised)

	var/obj/item/boulder/gulag_boulder = new spawned_boulder(get_turf(living_user))
	gulag_boulder.platform_lifespan = PLATFORM_LIFE_GULAG

	living_user.visible_message(span_notice("[living_user] hauls a boulder out of [src]."))
	living_user.apply_damage(stamina_damage_to_inflict, STAMINA)
	playsound(src, 'sound/items/weapons/genhit.ogg', vol = 50, vary = TRUE)
