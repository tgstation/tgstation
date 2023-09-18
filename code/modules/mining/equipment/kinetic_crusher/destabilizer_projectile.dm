/**
 * Destabilizer projectile
 * If it hits a mineable mineral turf, it mines it.
 * If it hits a mob larger than MOB_SIZE_LARGE, the mob gets marked with a destabilizer field, which can be popped for extra damage.
 * Destabilizer fields don't stack.
 */
/obj/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	armor_flag = BOMB
	range = 6
	log_override = TRUE
	///The crusher that fired the projectile
	var/obj/item/kinetic_crusher/hammer_synced

/obj/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/projectile/destabilizer/on_hit(atom/target, blocked = FALSE)
	if(ismineralturf(target))
		var/turf/closed/mineral/target_rock = target
		new /obj/effect/temp_visual/kinetic_blast(target_rock)
		target_rock.gets_drilled(firer)
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/victim = target
	var/had_effect = (victim.has_status_effect(/datum/status_effect/crusher_mark)) //used as a boolean
	var/datum/status_effect/crusher_mark/applied_mark = victim.apply_status_effect(/datum/status_effect/crusher_mark, hammer_synced)
	if(hammer_synced)
		for(var/obj/item/crusher_trophy/found_trophy as anything in hammer_synced.trophies)
			found_trophy.on_mark_application(target, applied_mark, had_effect)
	return ..()
