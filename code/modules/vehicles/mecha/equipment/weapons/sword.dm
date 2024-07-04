/obj/item/mecha_parts/mecha_equipment/sword
	name = "exosuit sword"
	desc = "Equipment for combat exosuits. This is the sword that'll pierce the SKIN!"
	icon_state = "mecha_sword"
	equip_cooldown = 15
	energy_drain = 0.02 * STANDARD_CELL_CHARGE
	force = 15
	harmful = TRUE
	range = MECHA_MELEE
	mech_flags = EXOSUIT_MODULE_WORKING | EXOSUIT_MODULE_COMBAT
	var/equipped_damage = 25

/obj/item/mecha_parts/mecha_equipment/sword/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_MOVABLE_BUMP)
	return ..()

/obj/item/mecha_parts/mecha_equipment/sword/Destroy()
	if(chassis)
		UnregisterSignal(chassis, COMSIG_MOVABLE_BUMP)
	return ..()

/obj/item/mecha_parts/mecha_equipment/sword/action(mob/source, atom/target, list/modifiers, bumped)


	if(DOING_INTERACTION_WITH_TARGET(source, target) && do_after_cooldown(target, source, DOAFTER_SOURCE_MECHADRILL))
		return

	target.visible_message(span_warning("[chassis] slashes [target]."), \
				span_userdanger("[chassis] slashes [target]..."), \
				span_hear("You hear slashing."))

	log_message("Slashed [target]", LOG_MECHA)

	if(isliving(target))
		if(!action_checks(target))
			return
		slash_mob(target, source)

		return ..()



/obj/item/mecha_parts/mecha_equipment/sword/proc/slash_mob(mob/living/target, mob/living/user)
	target.visible_message(span_danger("[chassis] slashed [target] with [src]!"), \
						span_userdanger("[chassis] slashed you with [src]!"))
	log_combat(user, target, "slashed", "[name]", "Combat mode: [user.combat_mode ? "On" : "Off"])(DAMTYPE: [uppertext(damtype)])")

	var/obj/item/bodypart/target_part = target.get_bodypart(target.get_random_valid_zone(user.zone_selected))
	target.apply_damage(equipped_damage, BRUTE, target_part, target.run_armor_check(target_part, MELEE),sharpness=1)
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	do_attack_animation(target, ATTACK_EFFECT_SLASH)

	var/splatter_dir = get_dir(chassis, target)
	if(isalien(target))
		new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target.drop_location(), splatter_dir)
	else
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(target.drop_location(), splatter_dir)

	if(target_part && prob(10))
		target_part.dismember(BRUTE)

