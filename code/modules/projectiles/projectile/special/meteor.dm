/obj/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 90
	paralyze = 100
	dismemberment = 90
	armour_penetration = 100
	damage_type = BRUTE
	armor_flag = BULLET
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/projectile/meteor/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_HIT && isliving(target))
		explosion(target, devastation_range = -1, light_impact_range = 2, flame_range = 0, flash_range = 1, adminlog = FALSE)
		playsound(target.loc, 'sound/effects/meteorimpact.ogg', 40, TRUE)

/obj/projectile/meteor/Bump(atom/hit_target)
	if(hit_target == firer)
		forceMove(hit_target.loc)
		return
	if(isobj(hit_target))
		SSexplosions.med_mov_atom += hit_target
	if(isturf(hit_target))
		SSexplosions.medturf += hit_target
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, TRUE)
	for(var/mob/onlookers_in_range in urange(10, src))
		if(!onlookers_in_range.stat)
			shake_camera(onlookers_in_range, 3, 1)
	qdel(src)

/obj/projectile/meteor/attack_hand(mob/user, list/modifiers)
	if(!isliving(user))
		return ..()
	var/mob/living/livinguser = user

	if(livinguser.combat_mode && livinguser.mind?.get_skill_level(/datum/skill/athletics) >= SKILL_LEVEL_LEGENDARY)
		playsound(loc, SFX_PUNCH, 50, TRUE)
		deflect(livinguser)
		return TRUE

	return ..()

/obj/projectile/meteor/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.tool_behaviour == TOOL_MINING)
		qdel(src)
		return TRUE

	else if	(istype(attacking_item, /obj/item/melee/baseball_bat))
		if(user.mind?.get_skill_level(/datum/skill/athletics) >= SKILL_LEVEL_EXPERT)
			playsound(src, 'sound/items/baseballhit.ogg', 100, TRUE)
			deflect(user)
			return TRUE
		to_chat(user, span_warning("\The [src] is too heavy for you!"))

	else if (istype(attacking_item, /obj/item/melee/powerfist))
		var/obj/item/melee/powerfist/fist = attacking_item
		if(!fist.tank)
			to_chat(user, span_warning("\The [fist] has no gas tank!"))
			return ..()
		var/datum/gas_mixture/gas_used = fist.tank.remove_air(fist.gas_per_fist * 3) // 3 is HIGH_PRESSURE setting on powerfist.
		if(!gas_used || !molar_cmp_equals(gas_used.total_moles(), fist.gas_per_fist * 3))
			to_chat(user, span_warning("\The [fist] didn't have enough gas to budge \the [src]!"))
			return ..()
		playsound(src, 'sound/items/weapons/resonator_blast.ogg', 50, TRUE)
		deflect(user)
		return TRUE

	return ..()

/obj/projectile/meteor/proc/deflect(mob/user)
	firer = user
	set_angle(get_angle(user, src) + rand(-45, 45))
