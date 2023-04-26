
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...
/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	obj_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	uses_integrity = FALSE

/obj/effect/attackby(obj/item/weapon, mob/user, params)
	if(SEND_SIGNAL(weapon, COMSIG_ITEM_ATTACK_EFFECT, src, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE

	// I'm not sure why these are snowflaked to early return but they are
	if(istype(weapon, /obj/item/mop) || istype(weapon, /obj/item/soap))
		return

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

/obj/effect/abstract/singularity_pull()
	return

/obj/effect/abstract/singularity_act()
	return

/obj/effect/abstract/has_gravity(turf/T)
	return FALSE

/obj/effect/dummy/singularity_pull()
	return

/obj/effect/dummy/singularity_act()
	return

/obj/effect/proc/overlay_for_96x96_effects()
	var/mutable_appearance/bottom = mutable_appearance(icon, icon_state)
	bottom.pixel_x = pixel_x
	bottom.pixel_w = -(pixel_x)
	bottom.add_filter("mask", 1, alpha_mask_filter(y = (pixel_y*2), icon = icon(icon, "row_mask")))
	add_overlay(bottom)
	var/mutable_appearance/middle = mutable_appearance(icon, icon_state)
	middle.pixel_x = pixel_x
	middle.pixel_w = -(pixel_x)
	// Shift physical position up a bit
	middle.pixel_y = -(pixel_y)
	middle.pixel_z = pixel_y
	// Mask out everything but the middle
	middle.add_filter("mask", 1, alpha_mask_filter(y = (pixel_y), icon = icon(icon, "row_mask")))
	add_overlay(middle)
	var/mutable_appearance/top = mutable_appearance(icon, icon_state)
	top.pixel_x = pixel_x
	top.pixel_w = -(pixel_x)
	// Shift physical position up a bit
	top.pixel_y = -(pixel_y*2)
	top.pixel_z = (pixel_y*2)
	// Mask out everything but the top
	top.add_filter("mask", 1, alpha_mask_filter(icon = icon(icon, "row_mask")))
	add_overlay(top)
	
	icon_state = ""
