
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...
/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	obj_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	uses_integrity = FALSE

/obj/effect/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(SEND_SIGNAL(weapon, COMSIG_ITEM_ATTACK_EFFECT, src, user, modifiers, attack_modifiers) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return ..()

/obj/effect/attack_generic(mob/user, damage_amount, damage_type, damage_flag, sound_effect, armor_penetration)
	return

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/fire_act(exposed_temperature, exposed_volume)
	return

/obj/effect/acid_act()
	return FALSE

/obj/effect/blob_act(obj/structure/blob/B)
	return

/obj/effect/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/obj/effect/experience_pressure_difference()
	return

/obj/effect/ex_act(severity, target)
	return FALSE

/obj/effect/singularity_act()
	qdel(src)

///The abstract effect ignores even more effects and is often typechecked for atoms that should truly not be fucked with.
/obj/effect/abstract
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF

/obj/effect/abstract/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/abstract/singularity_act()
	return

/obj/effect/abstract/has_gravity(turf/gravity_turf)
	return FALSE

/obj/effect/dummy/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/dummy/singularity_act()
	return
